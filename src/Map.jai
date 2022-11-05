Level :: struct {
    width: int;
    height: int;
    deck: [..] Room;
}

// Archetypes -----------------------------------------------------------------------
Levels: struct {
    BASIC :: Level.{
        width=20,
        height=20,
        deck=.[
            Rooms.R11,
            Rooms.R12,
            Rooms.R21,
            Rooms.R22,
            Rooms.R23,
            Rooms.R32,
        ]
    };
}