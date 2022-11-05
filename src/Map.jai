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
            Rooms.BASIC,
            Rooms.BASIC,
            Rooms.BASIC,
            Rooms.BASIC,
        ]
    };
}