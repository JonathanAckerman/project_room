CELL_WIDTH  :: 29.0;
CELL_SIZE   :: Vector2.{CELL_WIDTH, CELL_WIDTH};
GRID_WIDTH  :: 41;
GRID_HEIGHT :: 35;
GRID_SIZE   :: Vector2.{1 + GRID_WIDTH * (CELL_WIDTH+1), 1 + GRID_HEIGHT * (CELL_WIDTH+1)};

CARD_WIDTH :: 185;
CARD_HEIGHT :: 250;
CARD_SIZE :: Vector2.{CARD_WIDTH, CARD_HEIGHT};

HAND_POS :: Vector2.[.{1310, 700}, .{1505, 700}, .{1700, 700}];

SIDEBAR_LEFT :: 1 + (CELL_WIDTH + 1) * GRID_WIDTH;

game: struct {
    resetting: bool;
    win: bool;
    debug: bool = false;
    state: Game_State;
    phase: Game_Phase;
    
    intended_cursor: MouseCursor = .CROSSHAIR;
    mouse_cursor: MouseCursor;

    level: Level;
    level_index: int;
    level_has_focus: bool;
    current_level_width:  int;
    current_level_height: int;

    deck: [..] Handle(Card);

    player_deck: [..] Card;

    hand: [3] Handle(Card);
    count_hand :: () -> int { 
        count := 0;
        for game.hand { if exists(it) then count += 1; }
        return count;
    }
    highlighted_card := -1;
    is_first_placement := true;

    grid: [GRID_HEIGHT][GRID_WIDTH] Cell;
    map_top_left: Vector2;
    map_size: Vector2;
    map_phase: int;
}

Game_State :: enum {
    LEVEL_SELECT;
    LEVEL;
    LEVEL_COMPLETION;
}

Game_Phase :: enum {
    ROOM_PLACEMENT;
    DOOR_PLACEMENT;
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
// get_absolute_cell_position :: (x_index: int, y_index: int) -> Vector2 {
//     x := 1 + x_index * (CELL_WIDTH + 1);
//     y := 1 + y_index * (CELL_WIDTH + 1);
//     return xy(x, y);
// }

get_cell :: (x: int, y: int) -> bool, *Cell {
    if x < 0 || y < 0 || x > GRID_WIDTH-1 || y > GRID_HEIGHT-1 return false, null;
    return true, *game.grid[y][x];
}

get_neighbor :: (x: int, y: int, direction: Direction) -> bool, *Cell {
    n_x := x;
    n_y := y;
    if #complete direction == {
        case .NORTH;
            n_y -= 1;
        case .EAST;
            n_x += 1;
        case .SOUTH;
            n_y += 1;
        case .WEST;
            n_x -= 1;
    }
    in_bounds, result := get_cell(n_x, n_y);
    return in_bounds, result;
}

is_valid_placement :: (cells: [] Card_Cell) -> bool {
    mouse_x, mouse_y := get_cell_index(input.mouse_position);

    has_adjacency := false;
    for cells {
        cell_x := mouse_x + it.cell.x;
        cell_y := mouse_y + it.cell.y;
        // cell is off map
        if !is_on_map(cell_x, cell_y) return false;
        
        // cell overlaps
        if game.grid[cell_y][cell_x].room != .EMPTY {
            if it.can_merge then has_adjacency = true;
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

            if is_on_map(neighbor.x, neighbor.y) && neighbor.room != .EMPTY 
                then has_adjacency = true;
        }
    }

    if !has_adjacency return false;

    return true;
}

is_valid_door_placement :: (x: int, y: int, direction: Direction, width: int, type: Card_Door_Type) -> bool {
    using game;
    // door is outside of map
    if !is_on_map(x, y) return false;

    cell := grid[y][x];
    dir := direction_to_offset(direction);

    // map boundary
    if y == 0 && direction == .NORTH
    || x == GRID_WIDTH - 1 && direction == .EAST
    || y == GRID_WIDTH - 1 && direction == .SOUTH
    || x == 0 && direction == .WEST
        return false;

    neighbor := grid[cast(int)dir.y + y][cast(int)dir.x + x];

    // there is no room to attach to
    if cell.room == .EMPTY && neighbor.room == .EMPTY return false;

    // door already exists there
    if cell.edges[cast(int) direction] == .DOOR return false;
    if neighbor.edges[cast(int) opposite(direction)] == .DOOR return false;

    // there is no wall to replace
    if neighbor.edges[cast(int) opposite(direction)] != .WALL 
    && cell.edges[cast(int) direction] != .WALL {
        // and we are not closing off a hallway
        left := (cast(int) direction + 3) % 4;
        right := (cast(int) direction + 1) % 4;
        if (cell.edges[left] != .WALL || cell.edges[right] != .WALL)
        && (neighbor.edges[left] != .WALL || neighbor.edges[right] != .WALL)
            return false;
    }

    return true;    
}

grow_map :: () {
    using game;
    if current_level_width == GRID_WIDTH && current_level_height == GRID_HEIGHT return;

    old_level_width  := current_level_width;
    old_level_height := current_level_height;
    map_phase += 1;
    current_level_width  = level.width[map_phase];
    current_level_height = level.height[map_phase];

    // recompute map size/position
    map_size.x = 1 + current_level_width * CELL_WIDTH + current_level_width;
    map_size.y = 1 + current_level_height * CELL_WIDTH + current_level_height;
    map_top_left = xy(1,1) + GRID_SIZE/2 - xy(map_size.x, map_size.y)/2.0;
}

is_on_map :: (x: int, y: int) -> bool {
    using game;
    map_left := (GRID_WIDTH-1)/2 - (current_level_width-1)/2;
    map_top  := (GRID_HEIGHT-1)/2 - (current_level_height-1)/2;

    if x >= map_left && x < map_left + current_level_width
    && y >= map_top && y < map_top + current_level_height
        return true;
    else return false;
}

is_in_vision :: (x: int, y: int, exclude_map: bool = false) -> bool {
    using game;
    vision_width  := ifx map_phase == level.width.count-1  then GRID_WIDTH  else level.width[map_phase+1];
    vision_height := ifx map_phase == level.height.count-1 then GRID_HEIGHT else level.height[map_phase+1];
    vision_left := (GRID_WIDTH-1)/2 - (vision_width-1)/2;
    vision_top  := (GRID_HEIGHT-1)/2 - (vision_height-1)/2;

    map_left := ifx exclude_map then (GRID_WIDTH-1)/2 - (current_level_width-1)/2 else 0;
    map_top  := ifx exclude_map then (GRID_HEIGHT-1)/2 - (current_level_height-1)/2 else 0;

    if x >= vision_left && x < vision_left + vision_width 
    && y >= vision_top && y < vision_top + vision_height
        if exclude_map {
            if x >= map_left && x < map_left + current_level_width
            && y >= map_top && y < map_top + current_level_height
                return false; // in vision, but on map
            else return true; // in vision, and not on map
        }
        else return true; // in vision
    else return false; // out of vision
}