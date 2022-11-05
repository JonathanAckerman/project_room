CELL_WIDTH :: 30.0;
CELL_SIZE  :: Vector2.{CELL_WIDTH, CELL_WIDTH};

CARD_WIDTH :: 185;
CARD_HEIGHT :: 250;
CARD_SIZE :: Vector2.{CARD_WIDTH, CARD_HEIGHT};

DECK_POS  :: Vector2.{1505, 100};
HAND_POS :: Vector2.[.{1310, 700}, .{1505, 700}, .{1700, 700}];

MAP_TOP_LEFT :: Vector2.{94, 95};
SIDEBAR_LEFT :: 1241;

game: struct {
    resetting: bool;
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

    if input.clicked {
        reset_highlight := true;

        // map clicked
        if is_mouse_over(MAP_TOP_LEFT, map_size) {
            if highlighted_card > -1 {
                room := hand[highlighted_card].room;
                cell_x, cell_y := get_cell_index(input.mouse_position);
                room.cell_coord.x = cell_x;
                room.cell_coord.y = cell_y;

                if is_valid_placement(cell_x, cell_y, room) {
                    room.position = get_cell_position(cell_x, cell_y);
                    room.is_placed = true;
                    room.cell_coord.x = cell_x;
                    room.cell_coord.y = cell_y;
                    spawn(room);

                    hand[highlighted_card].exists = false;
                    intended_cursor = .CROSSHAIR;
                    is_first_placement = false;

                    check_level_success();
                }
                else reset_highlight = false;
            }
        }
        
        // hand clicked
        if is_mouse_over(HAND_POS[0], CARD_SIZE) && hand[0].exists {
            reset_highlight = highlighted_card == 0;
            highlighted_card = 0;
        }
        if is_mouse_over(HAND_POS[1], CARD_SIZE) && hand[1].exists {
            reset_highlight = highlighted_card == 1;
            highlighted_card = 1;
        }
        if is_mouse_over(HAND_POS[2], CARD_SIZE) && hand[2].exists {
            reset_highlight = highlighted_card == 2;
            highlighted_card = 2;
        }

        // deck clicked
        if is_mouse_over(DECK_POS, CARD_SIZE) {
            hand_count := count_hand();
            if level.deck.count > 0 && hand_count < 3 {
                open_slots := (3 - hand_count) - 1;
                for i: 0..open_slots {
                    room := pop(*level.deck);
                    index := first_empty_index(hand); // @@@: check -1?
                    hand[index].room = room;
                    hand[index].exists = true;
                    if level.deck.count == 0 break;
                }
            }
        }
        
        if reset_highlight {
            highlighted_card = -1;
            intended_cursor = .CROSSHAIR;
        }
    }

    // @Note: apparently setting the cursor is jank and shouldn't be 
    //        done in a game loop, to get around this I use a flag
    if game.intended_cursor != game.mouse_cursor {
        SetMouseCursor(xx game.intended_cursor);
        game.mouse_cursor = game.intended_cursor;
    }

    // draw --------------------------------------------------------------
    BeginDrawing();

    ClearBackground(BLACK);

    draw_background_grid();
    draw_map();
    draw_deck();
    draw_hand();

    if highlighted_card > -1 {
        if input.mouse_position.x <= SIDEBAR_LEFT {
            draw_room_ghost(*hand[highlighted_card].room, input.mouse_position);
        } else {
            intended_cursor = .CROSSHAIR;
        }
    }

    for _Room render(it);

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

    load_level(0);
}

draw_background_grid :: () {
    for i: 0..40 {
        for j: 0..34 {
            pos := xy(1 + i * CELL_WIDTH + i, 2 + j * CELL_WIDTH + j);
            DrawRectangleV(pos, CELL_SIZE, DARKGRAY);
        }
    }
}

draw_map :: () {
    using game.level;

    cell_offset :: 3;
    pixel_offset :: cell_offset * CELL_WIDTH + 3;
    for i: 0..width-1 {
        for j: 0..height-1 {
            pos := xy(1 + pixel_offset + i * CELL_WIDTH + i, 2 + pixel_offset + j * CELL_WIDTH + j);
            DrawRectangleV(pos, CELL_SIZE, GRAY);
        }
    }
}

draw_deck :: () {
    using game.level;

    DrawTextEx(Fonts.bahnschrift, "Deck", DECK_POS - xy(0, 50), 32, 1, WHITE);

    color := DARKGRAY;
    if deck.count > 0 {
        if is_mouse_over(DECK_POS, CARD_SIZE) then color = WHITE;
        else color = LIGHTGRAY;
    }
    DrawRectangleV(DECK_POS, xy(185, 250), color);
}

draw_hand :: () {
    using game;

    DrawTextEx(Fonts.bahnschrift, "Hand", HAND_POS[0] - xy(0, 50), 32, 1, WHITE);
    
    color0 := DARKGRAY;
    if hand[0].exists {
        color0 = LIGHTGRAY;
        if is_mouse_over(HAND_POS[0], CARD_SIZE) then color0 = WHITE;
    }

    color1 := DARKGRAY;
    if hand[1].exists {
        color1 = LIGHTGRAY;
        if is_mouse_over(HAND_POS[1], CARD_SIZE) then color1 = WHITE;
    }

    color2 := DARKGRAY;
    if hand[2].exists  {
        color2 = LIGHTGRAY;
        if is_mouse_over(HAND_POS[2], CARD_SIZE) then color2 = WHITE;
    }

    if highlighted_card > -1 {
        r: Rectangle;
        r.x = HAND_POS[highlighted_card].x - 4;
        r.y = HAND_POS[highlighted_card].y - 4;
        r.width = CARD_WIDTH + 8;
        r.height = CARD_HEIGHT + 8;
        DrawRectangleLinesEx(r, 8.0, BLUE);
    }

    DrawRectangleV(HAND_POS[0], xy(185, 250), ifx highlighted_card == 0 then WHITE else color0);
    DrawRectangleV(HAND_POS[1], xy(185, 250), ifx highlighted_card == 1 then WHITE else color1);
    DrawRectangleV(HAND_POS[2], xy(185, 250), ifx highlighted_card == 2 then WHITE else color2);

    // @@@: Factor this to not have to check twice
    if hand[0].exists {
        card_center := HAND_POS[0] + CARD_SIZE/2.0;
        room := hand[0].room;
        room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
        draw_room_representation(room, card_center - room_size/2.0, 255);
    }
    if hand[1].exists {
        card_center := HAND_POS[1] + CARD_SIZE/2.0;
        room := hand[1].room;
        room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
        draw_room_representation(room, card_center - room_size/2.0, 255);
    }
    if hand[2].exists {
        card_center := HAND_POS[2] + CARD_SIZE/2.0;
        room := hand[2].room;
        room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
        draw_room_representation(room, card_center - room_size/2.0, 255);
    }
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

check_level_success :: () {
    using game;
    if level.deck.count == 0 && count_hand() == 0 {
        level_index += 1;
        load_level(level_index);
    }
}

// @@@: rework this, eg: hand should maybe be separate struct from game
load_level :: (index: int) {
    using game;
    if index == Level_Sequence.count {
        print("YOU BEAT ALL % LEVELS!\n", Level_Sequence.count);
        game.resetting = true;
        return;
    }

    level = Level_Sequence[level_index];
    map_size.x = 1 + level.width * CELL_WIDTH + level.width;
    map_size.y = 2 + level.height * CELL_WIDTH + level.height;
    for context.entity_storage._Room {
        despawn(it);
    }
    intended_cursor = .CROSSHAIR;
    highlighted_card = -1;
    is_first_placement = true;
    for * hand it.exists = false;
}