Cell :: struct {
    using coord: struct {
        x: int;
        y: int;
    }
    room: Cell_Room_Type;
    edges: [4] Border_Type;
}

Cell_Room_Type :: enum {
    EMPTY;
    BLANK_ROOM;
}

Border_Type :: enum {
    EMPTY;
    WALL;
    DOOR;
}