CELL_WIDTH    :: 29.0;
CELL_SIZE     :: Vector2.{CELL_WIDTH, CELL_WIDTH};
GRID_WIDTH    :: 41;
GRID_HEIGHT   :: 35;
GRID_SIZE     :: Vector2.{1 + GRID_WIDTH * (CELL_WIDTH+1), 1 + GRID_HEIGHT * (CELL_WIDTH+1)};
VISION_RADIUS :: 1;

CARD_WIDTH :: 185;
CARD_HEIGHT :: 250;
CARD_SIZE :: Vector2.{CARD_WIDTH, CARD_HEIGHT};

HAND_POS :: Vector2.[.{1310, 700}, .{1505, 700}, .{1700, 700}];

SIDEBAR_LEFT :: 1 + (CELL_WIDTH + 1) * GRID_WIDTH;

NEW_GAME_CARDS :: Card.[
    Cards.R11,
    Cards.R22,
    Cards.M22,

    Cards.I11,
    Cards.R22,
    Cards.M22,

    Cards.D1,
    Cards.D1,
    Cards.TOILET,
];

game: struct {
    resetting: bool;
    win: bool;
    debug: bool = false;
    state: Game_State;
    
    intended_cursor: MouseCursor = .CROSSHAIR;
    mouse_cursor: MouseCursor;

    level: Level;
    level_index: int;
    level_has_focus: bool;

    deck: [..] Handle(Card);
    player_deck: [..] Card;

    hand: [3] Handle(Card);
    count_hand :: () -> int { 
        count := 0;
        for game.hand { if exists(it) then count += 1; }
        return count;
    }
    highlighted_card := -1;
    highlighted_card_direction: Direction;

    grid: [GRID_HEIGHT][GRID_WIDTH] Cell;

    cells_in_vision: [..] Cell.coord;

    adventurers: Cell.coord;
    adventurers_visited: [..] Cell.coord;
    kobold: Cell.coord;
}

Game_State :: enum {
    LEVEL_SELECT;
    LEVEL;
    LEVEL_COMPLETION;
}

frame: struct {
    dt: float64;
}

game_loop :: inline () {
    using game;
    using context.entity_storage;
    frame.dt = GetFrameTime();

    // simulate ----------------------------------------------------------
    handle_input();

    if state == {
        case .LEVEL_SELECT;     simulate_level_select();
        case .LEVEL;            simulate_level();
        case .LEVEL_COMPLETION; simulate_level_completion();
    }

    // draw --------------------------------------------------------------
    BeginDrawing();
    ClearBackground(BLACK);

    if state == {
        case .LEVEL_SELECT;     render_level_select();
        case .LEVEL;            render_level();
        case .LEVEL_COMPLETION; render_level_completion();
    }

    EndDrawing();

    // cleanup -----------------------------------------------------------
    cleanup_despawning_entities();
    reset_temporary_storage();
}

game_reset :: () {
    using game;
    log("RESETTING GAME");
    reset_entity_storage();

    game = .{};
    frame = .{};

    array_copy(*player_deck, NEW_GAME_CARDS);
}

is_valid_placement :: (cells: [] Card_Cell) -> bool {
    mouse_x, mouse_y := get_cell_index(input.mouse_position);

    has_adjacency := false;
    for cells {
        cell_x := mouse_x + it.cell.x;
        cell_y := mouse_y + it.cell.y;
        if !is_on_grid(cell_x, cell_y) return false;

        // collides with an item that is blocking
        for context.entity_storage._Item {
            if is_blocking(it.type) {
                for it.cells {
                    if it.x == cell_x && it.y == cell_y return false;
                }
            }
        }
        
        if it.type == {
            case .NORMAL; #through;
            case .MERGE;
                // cell overlaps
                if game.grid[cell_y][cell_x].room != .EMPTY {
                    if it.type == .MERGE then has_adjacency = true;
                    else return false;
                }

                // check cell neighbors for adjacency
                for dir: enum_values_as_s64(Direction) {
                    offset := direction_to_offset(cast(Direction) dir);
                    neighbor_x := cell_x + cast(int) offset.x;
                    neighbor_y := cell_y + cast(int) offset.y;

                    // skip neighbors that are off map to prevent OOB
                    if neighbor_x < 0 || neighbor_x > GRID_WIDTH-1 
                    || neighbor_y < 0 || neighbor_y > GRID_HEIGHT-1 then continue;

                    neighbor := game.grid[neighbor_y][neighbor_x];

                    if neighbor.room != .EMPTY 
                        then has_adjacency = true;
                }
            case .INTERIOR;
                if game.grid[cell_y][cell_x].room == .EMPTY return false;
                else return true;
        }
    }

    if !has_adjacency return false;

    return true;
}

is_valid_door_placement :: (x: int, y: int, direction: Direction, width: int, type: Card_Door_Type) -> bool {
    using game;
    if !is_on_grid(x, y) return false;

    cell := grid[y][x];
    dir := direction_to_offset(direction);

    // grid boundary
    if y == 0 && direction == .NORTH
    || x == GRID_WIDTH - 1 && direction == .EAST
    || y == GRID_WIDTH - 1 && direction == .SOUTH
    || x == 0 && direction == .WEST
        return false;

    // there is no room to attach to
    if cell.room == .EMPTY return false;

    // door already exists there
    if cell.edges[cast(int) direction] == .DOOR return false;

    // there is no wall to replace
    if cell.edges[cast(int) direction] != .WALL {
        // and we are not closing off a hallway
        left := (cast(int) direction + 3) % 4;
        right := (cast(int) direction + 1) % 4;
        if cell.edges[left] != .WALL || cell.edges[right] != .WALL
            return false;
    }

    return true;    
}

is_valid_item_placement :: (x: int, y: int, direction: Direction, item: Item) -> bool {
    using game;
    if !is_on_grid(x, y) return false;

    cell := grid[y][x];

    // cannot place this item type in this room type
    if cell.room != .BLANK_ROOM && cell.room != get_room_requirement(item.type) return false;

    // item already occupies this cell
    for context.entity_storage._Item {
        for it.cells {
            if it.x == x && it.y == y return false;
        }
    }

    return true;
}

is_on_grid :: (x: int, y: int) -> bool {
    if x < 0 || x > GRID_WIDTH-1
    || y < 0 || y > GRID_HEIGHT-1
        return false;
    return true;
}

is_in_vision :: (x: int, y: int, exclude_map: bool = false) -> bool {
    for game.cells_in_vision {
        if it.x == x && it.y == y return true;
    }
    return false;
}

update_vision :: () {
    using game;
    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            if grid[y][x].room != .EMPTY {
                for j: -VISION_RADIUS..VISION_RADIUS {
                    for i: -VISION_RADIUS..VISION_RADIUS {
                        neighbor: Cell.coord;
                        neighbor.x, neighbor.y = x + i, y + j;
                        if is_on_grid(neighbor.x, neighbor.y) {
                            array_add(*cells_in_vision, neighbor);
                        }
                    }
                }
            }
        }
    }
}

recompute_kobold_position :: () {
    dist, prev := dijkstra(game.adventurers);

    max_dist := 0;
    max_x := -1;
    max_y := -1;
    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            if prev[y][x] != null {
                if dist[y][x] > max_dist && dist[y][x] != S64_MAX {
                    for game.adventurers_visited {
                        if it.x == x && it.y == y then continue x;
                    }

                    max_dist = dist[y][x];
                    max_x = x;
                    max_y = y;
                }
            }
        }
    }

    if max_x != -1 && max_y != -1 then game.kobold.x, game.kobold.y = max_x, max_y;
}

advance_adventurers :: () {
    using game;
    array_add(*adventurers_visited, adventurers);
    // dist, prev := dijkstra(adventurers);

    // for y: 0..GRID_HEIGHT-1 {
    //     for x: 0..GRID_WIDTH-1 {

    //     }
    // }
}

dijkstra :: (start: Cell.coord, is_adventurers: bool = false) -> [GRID_HEIGHT][GRID_WIDTH] int, [GRID_HEIGHT][GRID_WIDTH] *Cell{
    dist: [GRID_HEIGHT][GRID_WIDTH] int;
    prev: [GRID_HEIGHT][GRID_WIDTH] *Cell;
    unsearched: [..] *Cell;

    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            dist[y][x] = S64_MAX;
            array_add(*unsearched, *game.grid[y][x]);
        }
    }
    dist[game.adventurers.y][game.adventurers.x] = 0;

    while unsearched.count > 0 {
        nearest := unsearched[0];
        min_dist := dist[nearest.y][nearest.x];
        for unsearched {
            other_dist := dist[it.y][it.x];
            if other_dist < min_dist {
                min_dist = other_dist;
                nearest = it;
            }
        }
        array_unordered_remove_by_value(*unsearched, nearest);

        for nearest.edges {
            dir := direction_to_offset(cast(Direction) it_index);
            neighbor_x := nearest.x + (cast(int) dir.x);
            neighbor_y := nearest.y + (cast(int) dir.y);
            if is_on_grid(neighbor_x, neighbor_y) {
                // neighbor_on_grid := get_cell(neighbor_x, neighbor_y);
                neighbor: *Cell;
                for unsearched if it.x == neighbor_x && it.y == neighbor_y then neighbor = it;
                if neighbor == null continue;

                cost := traversal_cost(nearest.coords, neighbor.coords, is_adventurers);
                if cost != S64_MAX then cost += dist[nearest.y][nearest.x];
                
                if cost < dist[neighbor_y][neighbor_x] {
                    dist[neighbor_y][neighbor_x] = cost;
                    prev[neighbor_y][neighbor_x] = nearest;
                }
            }
        }
    }

    return dist, prev;
}

traversal_cost :: (from: Cell.coord, to: Cell.coord, is_adventurers: bool = false) -> int {
    cost := 1;

    direction := direction_index_between(from, to);
    from_cell := get_cell(from);
    to_cell := get_cell(to);

    if is_adventurers {
        if from_cell.room == .EMPTY then cost += 100;
        if to_cell.room   == .EMPTY then cost += 100;

        if from_cell.edges[direction] == {
            case .DOOR; cost += 2;
            case .WALL; cost += 3;
        }
        if to_cell.edges[opposite(direction)] == {
            case .DOOR; cost += 2;
            case .WALL; cost += 3;
        }
    }
    else {
        if from_cell.room == .EMPTY return S64_MAX;
        if to_cell.room   == .EMPTY return S64_MAX;
        if to.x == game.adventurers.x && to.y == game.adventurers.y return S64_MAX;
        for game.adventurers_visited if it.x == to.x && it.y == to.y return S64_MAX;

        if from_cell.edges[direction] == {
            case .WALL; return S64_MAX;
        }
        if to_cell.edges[opposite(direction)] == {
            case .WALL; return S64_MAX;
        }
    }

    return cost;
}

/* 
Adventurer logic:
- djikstra to find dist/path to all possible cells from adventurer pos
    - here every cell is possible
- choose next cell on shortest path to kobold

Kobold logic:
- djikstra to find dist/path to all possible cells from kobold pos
    - here we wont see every cell and path will be blocked by adventurers and adven_visited
- compute shortest path (A*) from adventurers to every candidate cell
- choose the max dist of those
*/

a_star :: (start: Cell.coord, goal: Cell.coord) -> [..] Cell.coord {
    reconstruct_path :: (from: Table(int, Cell.coord), goal: Cell.coord) -> [..] Cell.coord {
        path: [..] Cell.coord;
        array_add(*path, goal);
        current := goal;
        found := true;
        while true {
            current, found = table_find(*from, current.y * GRID_WIDTH + current.x);
            if !found break;
            array_insert_at(*path, current, 0);
        }
        return path;
    }

    Coord_with_f_score :: struct { using coord: Cell.coord; f: float; }
    open: Priority_Queue(Coord_with_f_score, float);
    large_to_small :: (l,r) => r.f - l.f;
    open.compare = large_to_small;

    from: Table(int, Cell.coord);

    g_score: [GRID_HEIGHT][GRID_WIDTH] int;
    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            g_score[y][x] = S64_MAX;
        }
    }
    g_score[start.y][start.x] = 0;

    f_score: [GRID_HEIGHT][GRID_WIDTH] float;
    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            f_score[y][x] = FLOAT32_INFINITY;
        }
    }
    f_start := distance(xy(xx start.x, xx start.y), xy(xx goal.x, xx goal.y));
    f_score[start.y][start.x] = f_start;

    start_node: Coord_with_f_score;
    start_node.coord, start_node.f = start, f_start;
    push(*open, start_node);

    while open.data.count > 0 {
        current := pop(*open);
        if current.coord.x == goal.x 
        && current.coord.y == goal.y return reconstruct_path(from, current.coord);

        neighbor_offsets := Cell.coord.[.{0,-1}, .{1,0}, .{0,1}, .{-1,0}];
        for neighbor_offsets {
            neighbor: Cell.coord;
            neighbor.x, neighbor.y = current.x + it.x, current.y + it.y;
            if !is_on_grid(neighbor.x, neighbor.y) continue;

            tentative_g_score := g_score[current.y][current.x] + traversal_cost(current.coord, neighbor); // @@@: here we assume kobold movement, maybe need arg?
            if tentative_g_score < g_score[neighbor.y][neighbor.x] {
                key : int = neighbor.y * GRID_WIDTH + neighbor.x;
                table_add(*from, key, current.coord);
                g_score[neighbor.y][neighbor.x] = tentative_g_score;
                neighbor_f_score := tentative_g_score + distance(xy(xx neighbor.x, xx neighbor.y), xy(xx goal.x, xx goal.y));
                f_score[neighbor.y][neighbor.x] = neighbor_f_score;
                for open.data if it.x == neighbor.x && it.y == neighbor.y {
                    neighbor_node: Coord_with_f_score;
                    neighbor_node.coord, neighbor_node.f = neighbor, neighbor_f_score;
                    array_add(*open.data, neighbor_node);
                }
            }
        }
    }
    empty: [..] Cell.coord;
    return empty;
}