Room :: struct {
    using #as entity: Entity;
    width: int;  // # cells
    height: int; // # cells
    type: Room_Type;

    is_placed: bool;
    cell_coord: struct {
        x: int;
        y: int;
    };
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

    if is_valid_placement(x, y, room.width, room.height) {
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
    // @@@: I need to rethink this
    R11 :: Room.{
        width=1,
        height=1,
    };
    R12 :: Room.{
        width=1,
        height=2,
    };
    R21 :: Room.{
        width=2,
        height=1,
    };
    R22 :: Room.{
        width=2,
        height=2,
    };
    R23 :: Room.{
        width=2,
        height=3,
    };
    R32 :: Room.{
        width=3,
        height=2,
    };
}

Hand_Slot :: struct {
    room: Room;
    exists: bool;
}