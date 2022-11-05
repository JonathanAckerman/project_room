CELL_WIDTH :: 30.0;
CELL_SIZE  :: Vector2.{CELL_WIDTH, CELL_WIDTH};

CARD_WIDTH :: 185;
CARD_HEIGHT :: 250;
CARD_SIZE :: Vector2.{CARD_WIDTH, CARD_HEIGHT};

DECK_POS  :: Vector2.{1505, 100};
HAND_POS :: Vector2.[.{1310, 700}, .{1505, 700}, .{1700, 700}];

MAP_TOP_LEFT :: Vector2.{94, 95};

game: struct {
    resetting: bool;
    should_reset_cursor: bool;

    level: Level;

    hand: [3] Hand_Slot;
    count_hand :: () -> int { 
        count := 0;
        for game.hand { if it.exists then count += 1; }
        return count;
    }
    highlighted_card := -1;

    is_map_hovered: bool;
    map_size: Vector2;
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

                fits_horizontally := cell_x + room.width <= level.width;
                fits_vertically   := cell_y + room.height <= level.height;
                if fits_horizontally && fits_vertically {
                    overlaps_existing_room := false;
                    // for _Room {
                    //     if it.
                    // }

                    if !overlaps_existing_room {
                        room.position = get_cell_position(cell_x, cell_y);
                        spawn(room);
                        hand[highlighted_card].exists = false;
                    }
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
        
        if reset_highlight then highlighted_card = -1;
    }

    // draw --------------------------------------------------------------
    BeginDrawing();

    ClearBackground(BLACK);

    draw_background_grid();
    draw_map();
    draw_deck();
    draw_hand();

    if highlighted_card > -1 {
        draw_room_ghost(hand[highlighted_card].room, input.mouse_position);
    } else if should_reset_cursor {
        // @Note: apparently setting the cursor is jank and shouldn't be 
        //        done in a game loop, to get around this I use a flag
        SetMouseCursor(xx MouseCursor.CROSSHAIR);
        should_reset_cursor = false;
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

    level = Levels.BASIC;
    map_size.x = 1 + level.width * CELL_WIDTH + level.width;
    map_size.y = 2 + level.height * CELL_WIDTH + level.height;
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

    DrawRectangleV(HAND_POS[0], xy(185, 250), color0);
    DrawRectangleV(HAND_POS[1], xy(185, 250), color1);
    DrawRectangleV(HAND_POS[2], xy(185, 250), color2);
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