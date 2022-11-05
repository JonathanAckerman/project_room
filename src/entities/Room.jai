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

}

// Archetypes -----------------------------------------------------------------------
Rooms: struct {
    BASIC :: Room.{
        width=2,
        height=2,
    };
}