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
}