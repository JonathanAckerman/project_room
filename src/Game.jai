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
    state: Game_State;
    phase: Game_Phase;
    
    intended_cursor: MouseCursor = .CROSSHAIR;
    mouse_cursor: MouseCursor;

    level: Level;
    level_index: int;
    level_has_focus: bool;
    current_level_width:  int;
    current_level_height: int;

    room_deck: [..] Handle(Card);
    door_deck: [..] Handle(Card);

    player_room_deck: [..] Card;
    player_door_deck: [..] Card;

    hand: [3] Handle(Card);
    count_hand :: () -> int { 
        count := 0;
        for game.hand { if exists(it) then count += 1; }
        return count;
    }
    highlighted_card := -1;
    is_first_placement := true;

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

get_cell_index :: (point: Vector2) -> int, int{
    map_coord := point - game.map_top_left - xy(1,2);
    x := cast(int) (map_coord.x / (CELL_WIDTH + 1));
    y := cast(int) (map_coord.y / (CELL_WIDTH + 1));

    if x < 0 || y < 0 return -1, -1;
    if x >= game.current_level_width || y >= game.current_level_height return -1, -1;
    return x, y;
}

get_cell_position :: (x_index: int, y_index: int) -> Vector2 {
    x := game.map_top_left.x + x_index * (CELL_WIDTH + 1);
    y := game.map_top_left.y + y_index * (CELL_WIDTH + 1);
    return xy(x, y);
}
get_absolute_cell_position :: (x_index: int, y_index: int) -> Vector2 {
    x := 1 + x_index * (CELL_WIDTH + 1);
    y := 1 + y_index * (CELL_WIDTH + 1);
    return xy(x, y);
}

is_valid_placement :: (using room: Room) -> bool {
    fits_horizontally := x + room.width <= game.current_level_width;
    fits_vertically   := y + room.height <= game.current_level_height;
    if x >= 0 && fits_horizontally && y >= 0 && fits_vertically {
        overlaps_existing_room := false;
        for context.entity_storage._Room {
            if x + room.width - 1 >= it.x 
            && x < it.x + it.width
            && y + room.height - 1 >= it.y 
            && y < it.y + it.height {
                overlaps_existing_room = true;
                break;
            }
        }
        if !overlaps_existing_room {
            // test adjacency to other rooms
            if game.is_first_placement return true;
            for context.entity_storage._Room {
                on_right := left(room) == right(it) + 1;
                on_left := right(room) == left(it) - 1;
                on_bottom := top(room) == bottom(it) + 1;
                on_top := bottom(room) == top(it) - 1;
                
                if (on_left   && top(room) <= bottom(it) && bottom(room) >= top(it))
                || (on_right  && top(room) <= bottom(it) && bottom(room) >= top(it))
                || (on_top    && right(room) >= left(it) && left(room) <= right(it))
                || (on_bottom && right(room) >= left(it) && left(room) <= right(it)) {
                    return true;
                }
            }
        }
    }
    return false;
}

is_valid_placement :: (using door: Door) -> bool {
    using context.entity_storage;

    // door is outside of map
    if x < 0 || x > game.current_level_width
    || y < 0 || y > game.current_level_height return false;

    // door already exists there
    for _Door {
        if it.x == x && it.y == y && it.alignment == alignment return false;
    }

    // @Note: there can be incosistency when mixing is_mouse_over and get_cell_index for border conditions
    //        thus we use cell index to match the alignment logic in draw_ghost

    room := room_at_coord(x, y);
    if room {
        neighbor_x := x;
        neighbor_y := y;
        if alignment == {
            case .NORTH;
                neighbor_y -= 1;
            case .EAST;
                neighbor_x += 1;
            case .SOUTH;
                neighbor_y += 1;
            case .WEST;
                neighbor_x -= 1;
        }
        neighbor := room_at_coord(neighbor_x, neighbor_y);
        if neighbor && neighbor != room {
            // door already exists there (but is in neighbor cell)
            for _Door {
                same_cell := it.x == neighbor_x && it.y == neighbor_y;
                same_alignment := (cast(int) it.alignment + 2) % 4 == cast(int) alignment;
                if same_cell && same_alignment return false;
            }
            return true;
        }
    }
    return false;
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

    top_left_cell_displacement_x := ((current_level_width-1)/2) - ((old_level_width-1)/2);
    top_left_cell_displacement_y := ((current_level_height-1)/2) - ((old_level_height-1)/2);
    for context.entity_storage._Room {
        it.x += top_left_cell_displacement_x;
        it.y += top_left_cell_displacement_y;
    }
    for context.entity_storage._Door {
        it.x += top_left_cell_displacement_x;
        it.y += top_left_cell_displacement_y;
    }
}

is_on_map :: () -> bool {
    using game;
    map_left := (GRID_WIDTH-1)/2 - (current_level_width-1)/2;
    map_top  := (GRID_HEIGHT-1)/2 - (current_level_height-1)/2;

    if i >= map_left && i < map_left + current_level_width
    && j >= map_top && j < map_top + current_level_height
        return true;
    else return false;
}

is_in_vision :: (exclude_map: bool = false) -> bool {
    vision_width  := ifx map_phase == level.width.count-1  then GRID_WIDTH  else level.width[map_phase+1];
    vision_height := ifx map_phase == level.height.count-1 then GRID_HEIGHT else level.height[map_phase+1];
    vision_left := (GRID_WIDTH-1)/2 - (vision_width-1)/2;
    vision_top  := (GRID_HEIGHT-1)/2 - (vision_height-1)/2;

    map_left := ifx exclude_map then (GRID_WIDTH-1)/2 - (current_level_width-1)/2 else 0;
    map_top  := ifx exclude_map then (GRID_HEIGHT-1)/2 - (current_level_height-1)/2 else 0;

    if i >= vision_left && i < vision_left + vision_width 
    && j >= vision_top && j < vision_top + vision_height
        if exclude_map {
            if i >= map_left && i < map_left + current_level_width
            && j >= map_top && j < map_top + current_level_height
                return false; // in vision, but on map
            else return true; // in vision, and not on map
        }
        else return true; // in vision
    else return false; // out of vision
}