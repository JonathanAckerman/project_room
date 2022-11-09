Cell :: struct {
    using coord: struct {
        x: int;
        y: int;
    }
    room: Cell_Room_Type;
    edges: [4] Border_Type;
}

Cell_Room_Type :: enum {
    EMPTY;
    BLANK_ROOM;
}

Border_Type :: enum {
    EMPTY;
    WALL;
    DOOR;
}

Direction :: enum {
    NORTH;
    EAST;
    SOUTH;
    WEST;
}

direction_to_offset :: (dir: Direction) -> Vector2 {
    if #complete dir == {
        case .NORTH; return .{0, -1};
        case .EAST;  return .{1, 0};
        case .SOUTH; return .{0, 1};
        case .WEST;  return .{-1, 0};
    }
}

opposite :: (dir: Direction) -> Direction {
    i := (cast(int) dir) + 2;
    return cast(Direction)(i % 4);
}