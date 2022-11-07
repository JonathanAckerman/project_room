CELL_WIDTH  :: 29.0;
CELL_SIZE   :: Vector2.{CELL_WIDTH, CELL_WIDTH};
GRID_WIDTH  :: 41;
GRID_HEIGHT :: 35;
GRID_SIZE   :: Vector2.{1 + GRID_WIDTH * (CELL_WIDTH+1), 1 + GRID_HEIGHT * (CELL_WIDTH+1)};

CARD_WIDTH :: 185;
CARD_HEIGHT :: 250;
CARD_SIZE :: Vector2.{CARD_WIDTH, CARD_HEIGHT};

DECK_POS  :: Vector2.{1505, 100};
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
    if x >= game.level.width || y >= game.level.height return -1, -1;
    return x, y;
}

get_cell_position :: (x_index: int, y_index: int) -> Vector2 {
    x := game.map_top_left.x + x_index * (CELL_WIDTH + 1);
    y := game.map_top_left.y + y_index * (CELL_WIDTH + 1);
    return xy(x, y);
}

is_valid_placement :: (using room: Room) -> bool {
    fits_horizontally := x + room.width <= game.level.width;
    fits_vertically   := y + room.height <= game.level.height;
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
    if x < 0 || x > game.level.width 
    || y < 0 || y > game.level.height return false;

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