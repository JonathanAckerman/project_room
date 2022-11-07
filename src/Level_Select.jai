simulate_level_select :: () {
    tile_width :: 100;
    gutter :: 50;
    margin :: Vector2.{tile_width, tile_width};

    pos := margin;
    if input.clicked {
        for i: 1..Level_Sequence.count {
            if is_mouse_over(pos, xy(tile_width, tile_width)) {
                load_level(i-1);
                return;
            }

            pos += xy(tile_width + gutter, 0);
            if i % 12 == 0 {
                pos.x = margin.x;
                pos.y += tile_width + gutter;
            }
        }
    }
}

render_level_select :: () {
    tile_width :: 100;
    gutter :: 50;
    margin :: Vector2.{tile_width, tile_width};

    pos := margin;
    for i: 1..Level_Sequence.count {
        color := WHITE;
        color2 := GRAY;

        if is_mouse_over(pos, xy(tile_width, tile_width)) {
            color = DARKGRAY;
            color2 = WHITE;
            DrawRectangle(xx pos.x, xx pos.y, 100, 100, color);
        }
        else {
            DrawRectangleLines(xx pos.x, xx pos.y, 100, 100, color);
        }

        // label
        label := temp_c_string(tprint("%", i));
        measure := MeasureTextEx(Fonts.bahnschrift, label, 64, 1);
        DrawTextPro(Fonts.bahnschrift, label, pos + xy(tile_width, tile_width)/2 + xy(measure.x/2, measure.y/2), xx measure, 0.0, 64, 1, color2);

        pos += xy(tile_width + gutter, 0);
        if i % 12 == 0 {
            pos.x = margin.x;
            pos.y += tile_width + gutter;
        }
    }
}