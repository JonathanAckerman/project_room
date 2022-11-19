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

get_cell_index :: (point: Vector2) -> int, int {
    x := cast(int) (point.x / (CELL_WIDTH + 1));
    y := cast(int) (point.y / (CELL_WIDTH + 1));

    if x < 0 || y < 0 return -1, -1;
    if x > GRID_WIDTH || y > GRID_HEIGHT return -1, -1;
    return x, y;
}

get_cell_position :: (x_index: int, y_index: int) -> Vector2 {
    x := x_index * (CELL_WIDTH + 1);
    y := y_index * (CELL_WIDTH + 1);
    return xy(x, y);
}

// rethink this, dont need bool
// get_cell :: (x: int, y: int) -> bool, *Cell {
//     if x < 0 || y < 0 || x > GRID_WIDTH-1 || y > GRID_HEIGHT-1 return false, null;
//     return true, *game.grid[y][x];
// }
get_cell :: (x: int, y: int) -> *Cell {
    assert(is_on_grid(x, y), "cell not on grid");
    return *game.grid[y][x];
}

get_neighbor :: (x: int, y: int, direction: Direction) -> bool, *Cell {
    neighbor_x := x;
    neighbor_y := y;
    if #complete direction == {
        case .NORTH;
            neighbor_y -= 1;
        case .EAST;
            neighbor_x += 1;
        case .SOUTH;
            neighbor_y += 1;
        case .WEST;
            neighbor_x -= 1;
    }

    if !is_on_grid(neighbor_x, neighbor_y) return false, null;

    result := get_cell(neighbor_x, neighbor_y);
    return is_on_grid(result.x, result.y), result;
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
    using game;

    index :: (x, y) => y * GRID_WIDTH + x;
    // Dijkstra
    Dist_With_Check :: struct { dist: int; unchecked: bool; }
    dist: [GRID_HEIGHT][GRID_WIDTH] Dist_With_Check;
    prev: [GRID_HEIGHT][GRID_WIDTH] *Cell;
    unsearched: [..] *Cell;

    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            dist[y][x] = .{S64_MAX, true};
            array_add(*unsearched, *grid[y][x]);
        }
    }
    dist[adventurers.y][adventurers.x].dist = 0;

    while unsearched.count > 0 {
        min_x := -1;
        min_y := -1;
        min_dist := S64_MAX;
        for y: 0..GRID_HEIGHT-1 {
            for x: 0..GRID_WIDTH-1 {
                if dist[y][x].unchecked && dist[y][x].dist < min_dist {
                    min_dist = dist[y][x].dist;
                    min_x = x;
                    min_y = y;
                }
            }
        }
        if min_x == -1 || min_y == -1 || min_dist == S64_MAX {
            // print("no nearest cell: %, %, %\n", min_x, min_y, min_dist);
            break;
        }

        searching: *Cell;
        for unsearched {
            if it.x == min_x && it.y == min_y {
                searching = it;
                array_unordered_remove_by_index(*unsearched, it_index);
                dist[searching.y][searching.x].unchecked = false;
                break;
            }
        }

        for searching.edges {
            if it == .EMPTY || it == .DOOR {
                dir := direction_to_offset(cast(Direction) it_index);
                neighbor_x := searching.x + (cast(int) dir.x);
                neighbor_y := searching.y + (cast(int) dir.y);
                if is_on_grid(neighbor_x, neighbor_y) {
                    neighbor_on_grid := get_cell(neighbor_x, neighbor_y);
                    if neighbor_on_grid.room != .EMPTY {
                        // find the neighbor in unsearched
                        neighbor: *Cell;
                        for unsearched if it.x == neighbor_x && it.y == neighbor_y then neighbor = it;
                        if neighbor == null continue;

                        alt := dist[searching.y][searching.x].dist + 1;
                        if alt < dist[neighbor_y][neighbor_x].dist {
                            dist[neighbor_y][neighbor_x].dist = alt;
                            prev[neighbor_y][neighbor_x] = searching;
                        }
                    }
                }
            }
        }
    }

    max_dist := 0;
    max_x := -1;
    max_y := -1;
    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            if prev[y][x] != null {
                if dist[y][x].dist > max_dist {
                    max_dist = dist[y][x].dist;
                    max_x = x;
                    max_y = y;
                }
            }
        }
    }

    kobold.x, kobold.y = max_x, max_y;
}

advance_adventurers :: () {
    using game;
    // dijkstra but add cost for walls and/or EMPTY rooms
    // ie: allow digging / busting down walls
    adventurers.y -= 1;
}