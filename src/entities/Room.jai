Room :: struct {
    using #as entity: Entity;
    width: int;  // # cells
    height: int; // # cells
    type: Room_Type;
}

Room_Type :: enum {
    EMPTY;
}

simulate :: (using room: *Room) {

}

render :: (using room: *Room) {
    size := xy(width * CELL_WIDTH + (width - 1), height * CELL_WIDTH + (height - 1));
    color := YELLOW;
    DrawRectangleV(position, size, color);
}

draw_room_ghost :: (room: Room, position: Vector2) {
    size := xy(room.width * CELL_WIDTH + (room.width - 1), room.height * CELL_WIDTH + (room.height - 1));
    color := YELLOW;
    color.a = 100;

    x, y := get_cell_index(position);

    fits_horizontally := x + room.width <= game.level.width;
    fits_vertically   := y + room.height <= game.level.height;
    if x >= 0 && fits_horizontally && y >= 0 && fits_vertically {
        DrawRectangleV(get_cell_position(x, y), size, color);
        SetMouseCursor(xx MouseCursor.POINTING_HAND);
        game.should_reset_cursor = true;
    }
    else {
        DrawRectangleV(position, size, color);
        SetMouseCursor(xx MouseCursor.NOT_ALLOWED);
        game.should_reset_cursor = true;
    }
}

// Archetypes -----------------------------------------------------------------------
Rooms: struct {
    BASIC :: Room.{
        width=2,
        height=2,
    };
}

Hand_Slot :: struct {
    room: Room;
    exists: bool;
}