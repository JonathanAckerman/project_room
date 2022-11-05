Map :: struct {
    width: int;
    height: int;
    deck: [..] Room;
}

// Archetypes -----------------------------------------------------------------------
Maps: struct {
    BASIC :: Map.{
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