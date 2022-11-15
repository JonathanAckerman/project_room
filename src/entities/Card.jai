Card :: struct {
    using #as entity: Entity;
    is_level_provided := true;

    type: Card_Type;
    using data: union {
        cells: [] Card_Cell; // @Note: the cell coords will be relative, not absolute
        door: struct {
            width: int;
            type: Card_Door_Type;
        }
        item: Item;
    }
}

Card_Cell :: struct {
    using cell: Cell;
    type: Card_Cell_Type;
}

Card_Cell_Type :: enum {
    NORMAL;
    MERGE;
    INTERIOR;
}

Card_Type :: enum {
    MIXED;
    DOOR;
    ITEM;
}

Card_Door_Type :: enum {
    NORMAL;
}

// Archetypes ---------------------------------------------------------------------
Cards: struct {
    // Mixed ----------------------------------------------------------------------
    R11 :: Card.{
        type=.MIXED,
        cells=.[
            Card_Cell.{cell=.{coord=.{0, 0}, room=.BLANK_ROOM, edges=.[.DOOR, .WALL, .WALL, .WALL]}},
        ],
    };
    I11 :: Card.{
        type=.MIXED,
        cells=.[
            Card_Cell.{.{coord=.{0, 0}, room=.BLANK_ROOM, edges=.[.WALL, .DOOR, .WALL, .WALL]}, .INTERIOR},
        ],
    };
    R22 :: Card.{
        type=.MIXED,
        cells=.[
            Card_Cell.{cell=.{coord=.{0, 0}, room=.BLANK_ROOM, edges=.[.WALL, .EMPTY, .EMPTY, .WALL]}},
            Card_Cell.{cell=.{coord=.{1, 0}, room=.BLANK_ROOM, edges=.[.WALL, .WALL, .EMPTY, .EMPTY]}},
            Card_Cell.{cell=.{coord=.{0, 1}, room=.BLANK_ROOM, edges=.[.EMPTY, .EMPTY, .WALL, .WALL]}},
            Card_Cell.{cell=.{coord=.{1, 1}, room=.BLANK_ROOM, edges=.[.EMPTY, .WALL, .WALL, .EMPTY]}},
        ],
    };
    M22 :: Card.{
        type=.MIXED,
        cells=.[
            Card_Cell.{.{coord=.{0, 0}, room=.BLANK_ROOM, edges=.[.WALL, .EMPTY, .EMPTY, .WALL]}, .MERGE},
            Card_Cell.{.{coord=.{1, 0}, room=.BLANK_ROOM, edges=.[.WALL, .WALL, .EMPTY, .EMPTY]}, .MERGE},
            Card_Cell.{.{coord=.{0, 1}, room=.BLANK_ROOM, edges=.[.EMPTY, .EMPTY, .WALL, .WALL]}, .MERGE},
            Card_Cell.{.{coord=.{1, 1}, room=.BLANK_ROOM, edges=.[.EMPTY, .WALL, .WALL, .EMPTY]}, .MERGE},
        ],
    };

    // Doors ----------------------------------------------------------------------
    D1 :: Card.{
        type=.DOOR,
        door=.{
            width=1,
        }
    };
    D2 :: Card.{
        type=.DOOR,
        door=.{
            width=2,
        }
    };

    // Items ----------------------------------------------------------------------
    TOILET :: Card.{
        type=.ITEM,
        item=.{
            type=.TOILET, cells=.[
                .{0, 0}, // @Note: these are relative positions
            ],
        }
    };
}