Card :: struct {
    using #as entity: Entity;
    is_level_provided := true;

    type: Card_Type;
    using data: union {
        room: Room;
    }
}

Card_Type :: enum {
    ROOM;
    DOOR;
}

// Archetypes ---------------------------------------------------------------------
Cards: struct {
    R11 :: Card.{
        type=.ROOM,
        room=Room.{
            width =1,
            height=1,
        }
    };
    R22 :: Card.{
        type=.ROOM,
        room=Room.{
            width =2,
            height=2,
        }
    };
    R33 :: Card.{
        type=.ROOM,
        room=Room.{
            width =3,
            height=3,
        }
    };
    R44 :: Card.{
        type=.ROOM,
        room=Room.{
            width =4,
            height=4,
        }
    };
    R55 :: Card.{
        type=.ROOM,
        room=Room.{
            width =5,
            height=5,
        }
    };

    R12 :: Card.{
        type=.ROOM,
        room=Room.{
            width =1,
            height=2,
        }
    };
    R21 :: Card.{
        type=.ROOM,
        room=Room.{
            width =2,
            height=1,
        }
    };
    R13 :: Card.{
        type=.ROOM,
        room=Room.{
            width =1,
            height=3,
        }
    };
    R31 :: Card.{
        type=.ROOM,
        room=Room.{
            width =3,
            height=1,
        }
    };
    R14 :: Card.{
        type=.ROOM,
        room=Room.{
            width =1,
            height=4,
        }
    };
    R41 :: Card.{
        type=.ROOM,
        room=Room.{
            width =4,
            height=1,
        }
    };
    R15 :: Card.{
        type=.ROOM,
        room=Room.{
            width =1,
            height=5,
        }
    };
    R51 :: Card.{
        type=.ROOM,
        room=Room.{
            width =5,
            height=1,
        }
    };

    R23 :: Card.{
        type=.ROOM,
        room=Room.{
            width =2,
            height=3,
        }
    };
    R32 :: Card.{
        type=.ROOM,
        room=Room.{
            width =3,
            height=2,
        }
    };
    R24 :: Card.{
        type=.ROOM,
        room=Room.{
            width =2,
            height=4,
        }
    };
    R42 :: Card.{
        type=.ROOM,
        room=Room.{
            width =4,
            height=2,
        }
    };
    R25 :: Card.{
        type=.ROOM,
        room=Room.{
            width =2,
            height=5,
        }
    };
    R52 :: Card.{
        type=.ROOM,
        room=Room.{
            width =5,
            height=2,
        }
    };

    R34 :: Card.{
        type=.ROOM,
        room=Room.{
            width =3,
            height=4,
        }
    };
    R43 :: Card.{
        type=.ROOM,
        room=Room.{
            width =4,
            height=3,
        }
    };
    R35 :: Card.{
        type=.ROOM,
        room=Room.{
            width =3,
            height=5,
        }
    };
    R53 :: Card.{
        type=.ROOM,
        room=Room.{
            width =5,
            height=3,
        }
    };

    R45 :: Card.{
        type=.ROOM,
        room=Room.{
            width =4,
            height=5,
        }
    };
    R54 :: Card.{
        type=.ROOM,
        room=Room.{
            width =5,
            height=4,
        }
    };
}