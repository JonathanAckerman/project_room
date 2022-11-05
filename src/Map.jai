Level :: struct {
    width: int;
    height: int;
    deck: [..] Room_Prototype;
}

Level_Sequence: [3] Level = .[
    Levels.TUTORIAL_1,
    Levels.TUTORIAL_2,
    Levels.TUTORIAL_3,
];

// Archetypes -----------------------------------------------------------------------
Levels: struct {
    TUTORIAL_1 :: Level.{
        width=5,
        height=5,
    };
    TUTORIAL_2 :: Level.{
        width=10,
        height=10,
    };
    TUTORIAL_3 :: Level.{
        width=12,
        height=3,
    };
}

// Decks --------------------------------------------------------------------------
Decks: [][] Room_Prototype = .[
    .[// TUTORIAL_1
        Rooms.R11,
        Rooms.R11,

        Rooms.R21,
        Rooms.R21,

        Rooms.R31,
        Rooms.R31,

        Rooms.R41,
        Rooms.R41,

        Rooms.R51,
    ],
    .[// TUTORIAL_2
        Rooms.R33,
        Rooms.R33,
        Rooms.R33,
        Rooms.R44,
        Rooms.R44,
        Rooms.R55,
    ],
    .[// TUTORIAL_3
        Rooms.R11,
        Rooms.R11,

        Rooms.R12,
        Rooms.R12,
        Rooms.R12,
        Rooms.R13,
        Rooms.R13,

        Rooms.R21,
        Rooms.R21,
        Rooms.R41,
        Rooms.R41,
        Rooms.R51,
        Rooms.R51,
    ]
];