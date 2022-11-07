simulate_level_completion :: () {
    if input.clicked {
        game.level_index += 1;
        load_level(game.level_index);
    }
}

render_level_completion :: () {
    using game;
    using context.entity_storage;

    render_level();

    DrawRectangle(50, 50, WINDOW_WIDTH-100, WINDOW_HEIGHT-100, Color.{155, 155, 155, 200});
    text := temp_c_string(tprint("YOU BEAT LEVEL %", level_index+1));
    measure := MeasureTextEx(Fonts.bahnschrift, text, 64, 1);
    DrawTextPro(Fonts.bahnschrift, text, xy(54, 54) + xy(WINDOW_WIDTH-100, WINDOW_HEIGHT-100)/2 + xy(measure.x/2, measure.y/2), xx measure, 0.0, 64, 1, BLACK);
    DrawTextPro(Fonts.bahnschrift, text, xy(50, 50) + xy(WINDOW_WIDTH-100, WINDOW_HEIGHT-100)/2 + xy(measure.x/2, measure.y/2), xx measure, 0.0, 64, 1, WHITE);
}