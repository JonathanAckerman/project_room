CELL_WIDTH :: 30.0;
CELL_SIZE  :: Vector2.{CELL_WIDTH, CELL_WIDTH};

game: struct {
    resetting: bool;

    current_map: Map;
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

    // for _Cell simulate(it);

    // draw --------------------------------------------------------------
    BeginDrawing();

    ClearBackground(BLACK);

    draw_background_grid();
    draw_map();

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

    game.current_map = Maps.BASIC;
}

draw_background_grid :: () {
    for i: 0..43 {
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
    
}