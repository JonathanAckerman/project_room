Level :: struct {
    width: int;
    height: int;
    deck: [..] Room;
}

Level_Sequence: [2] Level = .[
    Levels.TUTORIAL_1,
    Levels.TUTORIAL_2,
];

// Archetypes -----------------------------------------------------------------------
Levels: struct {
    TUTORIAL_1 :: Level.{
        width=5,
        height=5,
        deck=.[
            Rooms.R11,
            Rooms.R11,

            Rooms.R21,
            Rooms.R21,

            Rooms.R31,
            Rooms.R31,

            Rooms.R41,
            Rooms.R41,

            Rooms.R51,
        ]
    };
    TUTORIAL_2 :: Level.{
        width=15,
        height=15,
        deck=.[
            Rooms.R11,
            Rooms.R11,

            Rooms.R21,
            Rooms.R21,

            Rooms.R31,
            Rooms.R31,

            Rooms.R41,
            Rooms.R41,

            Rooms.R51,
        ]
    };
}