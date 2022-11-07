CELL_WIDTH :: 29.0;
CELL_SIZE  :: Vector2.{CELL_WIDTH, CELL_WIDTH};
GRID_WIDTH :: 41;
GRID_HEIGHT :: 35;

CARD_WIDTH :: 185;
CARD_HEIGHT :: 250;
CARD_SIZE :: Vector2.{CARD_WIDTH, CARD_HEIGHT};

DECK_POS  :: Vector2.{1505, 100};
HAND_POS :: Vector2.[.{1310, 700}, .{1505, 700}, .{1700, 700}];

MAP_TOP_LEFT :: Vector2.{94, 95};
SIDEBAR_LEFT :: 1 + (CELL_WIDTH + 1) * GRID_WIDTH;

game: struct {
    resetting: bool;
    state: Game_State;
    phase: Game_Phase;
    intended_cursor: MouseCursor = .CROSSHAIR;
    mouse_cursor: MouseCursor;

    level: Level;
    level_index: int;

    hand: [3] Hand_Slot;
    count_hand :: () -> int { 
        count := 0;
        for game.hand { if it.exists then count += 1; }
        return count;
    }
    highlighted_card := -1;

    is_map_hovered: bool;
    map_size: Vector2;

    is_first_placement := true;
    door_placement := false;
    door_ghost: struct {
        room: Handle(Room);
        position: Vector2;
        size: Vector2;
    }

    level_has_focus: bool;
}

Game_State :: enum {
    LEVEL_SELECT;
    LEVEL;
    LEVEL_COMPLETION;
}

Game_Phase :: enum {
    ROOM;
    DOOR;
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

is_mouse_over :: (topleft: Vector2, size: Vector2) -> bool {
    return (input.mouse_position.x >= topleft.x && 
            input.mouse_position.x <= topleft.x + size.x &&
            input.mouse_position.y >= topleft.y && 
            input.mouse_position.y <= topleft.y + size.y);
}

get_cell_index :: (point: Vector2) -> int, int{
    map_coord := point - MAP_TOP_LEFT - xy(1,2);
    x := cast(int) (map_coord.x / (CELL_WIDTH + 1));
    y := cast(int) (map_coord.y / (CELL_WIDTH + 1));

    if x < 0 || y < 0 return -1, -1;
    if x >= game.level.width || y >= game.level.height return -1, -1;
    return x, y;
}

get_cell_position :: (x_index: int, y_index: int) -> Vector2 {
    x := MAP_TOP_LEFT.x + x_index * (CELL_WIDTH + 1);
    y := MAP_TOP_LEFT.y + y_index * (CELL_WIDTH + 1);
    return xy(x, y);
}

is_valid_placement :: (x: int, y: int, room: Room) -> bool {
    fits_horizontally := x + room.width <= game.level.width;
    fits_vertically   := y + room.height <= game.level.height;
    if x >= 0 && fits_horizontally && y >= 0 && fits_vertically {
        overlaps_existing_room := false;
        for context.entity_storage._Room {
            if x + room.width - 1 >= it.cell_coord.x 
            && x < it.cell_coord.x + it.width
            && y + room.height - 1 >= it.cell_coord.y 
            && y < it.cell_coord.y + it.height {
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

shuffle :: (arr: [..] int) -> [..] int {
    return fisher_yates_shuffle(arr);
}