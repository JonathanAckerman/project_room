CELL_WIDTH :: 30.0;
CELL_SIZE  :: Vector2.{CELL_WIDTH, CELL_WIDTH};

CARD_WIDTH :: 185;
CARD_HEIGHT :: 250;
CARD_SIZE :: Vector2.{CARD_WIDTH, CARD_HEIGHT};

DECK_POS  :: Vector2.{1505, 100};
HAND_POS :: Vector2.[.{1310, 700}, .{1505, 700}, .{1700, 700}];

game: struct {
    resetting: bool;

    current_map: Map;
    hand: [3] Hand_Slot;
    count_hand :: () -> int { 
        count := 0;
        for game.hand { if it.exists then count += 1; }
        return count;
    }
    highlighted_card := -1;

    deck_hovered: bool;
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

    // deck clicked
    if input.clicked {
        if is_mouse_over(DECK_POS, CARD_SIZE) {
            hand_count := count_hand();
            if current_map.deck.count > 0 && hand_count < 3 {
                open_slots := (3 - hand_count) - 1;
                for i: 0..open_slots {
                    room := pop(*current_map.deck);
                    index := first_empty_index(hand); // @@@: check -1?
                    hand[index].room = room;
                    hand[index].exists = true;
                    if current_map.deck.count == 0 break;
                }
            }
        }
        else if is_mouse_over(HAND_POS[0], CARD_SIZE) && hand[0].exists {
            if highlighted_card == 0 then highlighted_card = -1;
            else highlighted_card = 0;
        }
        else if is_mouse_over(HAND_POS[1], CARD_SIZE) && hand[1].exists {
            if highlighted_card == 1 then highlighted_card = -1;
            else highlighted_card = 1;
        }
        else if is_mouse_over(HAND_POS[2], CARD_SIZE) && hand[2].exists {
            if highlighted_card == 2 then highlighted_card = -1;
            else highlighted_card = 2;
        }
        else highlighted_card = -1;
    }

    // draw --------------------------------------------------------------
    BeginDrawing();

    ClearBackground(BLACK);

    draw_background_grid();
    draw_map();
    draw_deck();
    draw_hand();

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

    current_map = Maps.BASIC;
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
    using game.current_map;

    cell_offset :: 3;
    pixel_offset :: cell_offset * CELL_WIDTH + 3; 
    for i: 0..width {
        for j: 0..height {
            pos := xy(1 + pixel_offset + i * CELL_WIDTH + i, 2 + pixel_offset + j * CELL_WIDTH + j);
            DrawRectangleV(pos, CELL_SIZE, GRAY);
        }
    }
}

draw_deck :: () {
    using game.current_map;

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