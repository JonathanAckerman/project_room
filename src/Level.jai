Level :: struct {
    width: int;
    height: int;
    deck: [..] Room_Prototype;
    starting_rooms: [..] Room;
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
        starting_rooms= .[
            .{room_prototype=Rooms.R22, is_placed=true, cell_coord=.{1, 1}},
        ],
    };
    TUTORIAL_2 :: Level.{
        width=10,
        height=10,
        starting_rooms= .[
            .{room_prototype=Rooms.R41, is_placed=true, cell_coord=.{3, 3}},
        ],
    };
    TUTORIAL_3 :: Level.{
        width=12,
        height=3,
        starting_rooms= .[
            .{room_prototype=Rooms.R12, is_placed=true, cell_coord=.{2, 1}},
        ],
    };
}

// Decks --------------------------------------------------------------------------
Decks: [][] Room_Prototype = .[
    .[// TUTORIAL_1
        Rooms.R11,
        Rooms.R11,

        Rooms.R21,
        Rooms.R21,

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