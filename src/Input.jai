input: struct {
    mouse_position: Vector2;
    clicked: bool;
}

handle_input :: () {
    using input;

    mouse_position = xy(xx GetMouseX(), xx GetMouseY());

    if IsMouseButtonPressed(xx MouseButton.LEFT) {
        input.clicked = true;
    } 
    else input.clicked = false;

    if IsKeyPressed(xx KeyboardKey.F5) {
        game.resetting = true;
    }
    if IsKeyPressed(xx KeyboardKey.R) {
        if game.state != .LEVEL return;
        load_level(game.level_index);
    }
    if IsKeyPressed(xx KeyboardKey.F9) {
        game.debug = !game.debug;
    }
    if IsKeyPressed(xx KeyboardKey.F10) {
        if game.state == .LEVEL {
            grow_map();
        }
    }
    if IsKeyPressed(xx KeyboardKey.F11) {
        if game.state == .LEVEL {
            check_level_success(true);
        }
        else if game.state == .LEVEL_COMPLETION {
            game.level_index += 1;
            load_level(game.level_index);
        }
    }
    if IsKeyPressed(xx KeyboardKey.ESCAPE) {
        if game.state != .LEVEL return;
        game.highlighted_card = -1;
        game.intended_cursor = .CROSSHAIR;
    }
}

is_mouse_over :: (topleft: Vector2, size: Vector2) -> bool {
    return (input.mouse_position.x >= topleft.x && 
            input.mouse_position.x <= topleft.x + size.x &&
            input.mouse_position.y >= topleft.y && 
            input.mouse_position.y <= topleft.y + size.y);
}