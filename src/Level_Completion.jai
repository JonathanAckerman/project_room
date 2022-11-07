simulate_level_completion :: () {
    if input.clicked {
        game.level_index += 1;
        load_level(game.level_index);
    }
}

render_level_completion :: () {
    render_level();
    draw_level_completion_sidebar();
}

draw_level_completion_sidebar :: () {
    using game;

    DrawRectangle(xx SIDEBAR_LEFT, 0, xx (WINDOW_WIDTH-SIDEBAR_LEFT), WINDOW_HEIGHT, Color.{155, 155, 155, 150});
    text := temp_c_string(tprint("YOU BEAT\nLEVEL %", level_index+1));
    measure := MeasureTextEx(Fonts.bahnschrift, text, 64, 1);
    DrawTextPro(Fonts.bahnschrift, text, xy(SIDEBAR_LEFT + 50, 50) + measure, xx measure, 0.0, 64, 1, WHITE);
}