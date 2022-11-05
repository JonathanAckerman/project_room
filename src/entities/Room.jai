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