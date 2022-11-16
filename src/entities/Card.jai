Card :: struct {
    using #as entity: Entity;
    is_level_provided := true;

    type: Card_Type;
    using data: union {
        stamp: struct {
            type: Card_Stamp_Type;
            cells: [..] Card_Cell; // @Note: the cell coords will be relative
        }
        door: struct {
            type: Card_Door_Type;
            width: int;
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
Card_Stamp_Type :: enum {
    R11;
    R22;
    I11;
    M22;
}

init :: (using card: *Card) {
    if type == {
        case .MIXED;
            if stamp.type == {
                case .R11; array_copy(*stamp.cells, Cards.R11_CELLS);
                case .R22; array_copy(*stamp.cells, Cards.R22_CELLS);
                case .I11; array_copy(*stamp.cells, Cards.I11_CELLS);
                case .M22; array_copy(*stamp.cells, Cards.M22_CELLS);
            }
        case .ITEM;
            init(*item);
    }
}

// Archetypes ---------------------------------------------------------------------
Cards: struct {
    // Mixed ----------------------------------------------------------------------
    R11 :: Card.{type=.MIXED, stamp.type=.R11};
    R11_CELLS :: Card_Cell.[
        .{cell=.{coord=.{0, 0}, room=.BLANK_ROOM, edges=.[.DOOR, .WALL, .WALL, .WALL]}}
    ];

    R22 :: Card.{type=.MIXED, stamp.type=.R22};
    R22_CELLS :: Card_Cell.[
        .{cell=.{coord=.{0, 0}, room=.BLANK_ROOM, edges=.[.WALL, .EMPTY, .EMPTY, .WALL]}},
        .{cell=.{coord=.{1, 0}, room=.BLANK_ROOM, edges=.[.WALL, .WALL, .EMPTY, .EMPTY]}},
        .{cell=.{coord=.{0, 1}, room=.BLANK_ROOM, edges=.[.EMPTY, .EMPTY, .WALL, .WALL]}},
        .{cell=.{coord=.{1, 1}, room=.BLANK_ROOM, edges=.[.EMPTY, .WALL, .WALL, .EMPTY]}},
    ];

    I11 :: Card.{type=.MIXED, stamp.type=.I11};
    I11_CELLS :: Card_Cell.[
        .{cell=.{coord=.{0, 0}, room=.BLANK_ROOM, edges=.[.WALL, .DOOR, .WALL, .WALL]}, type=.INTERIOR},
    ];

    M22 :: Card.{type=.MIXED, stamp.type=.M22};
    M22_CELLS :: Card_Cell.[
        .{cell=.{coord=.{0, 0}, room=.BLANK_ROOM, edges=.[.WALL, .EMPTY, .EMPTY, .WALL]}, type=.MERGE},
        .{cell=.{coord=.{1, 0}, room=.BLANK_ROOM, edges=.[.WALL, .WALL, .EMPTY, .EMPTY]}, type=.MERGE},
        .{cell=.{coord=.{0, 1}, room=.BLANK_ROOM, edges=.[.EMPTY, .EMPTY, .WALL, .WALL]}, type=.MERGE},
        .{cell=.{coord=.{1, 1}, room=.BLANK_ROOM, edges=.[.EMPTY, .WALL, .WALL, .EMPTY]}, type=.MERGE},
    ];

    // Doors ----------------------------------------------------------------------
    D1 :: Card.{
        type=.DOOR,
        door=.{width=1}
    };
    D2 :: Card.{
        type=.DOOR,
        door=.{width=2}
    };

    // Items ----------------------------------------------------------------------
    TOILET :: Card.{
        type=.ITEM,
        item=.{type=.TOILET}
    };
}