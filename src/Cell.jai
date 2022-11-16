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
    BLANK_ROOM; // any furniture (closet, den, living, dining)
    HALLWAY;    // no furniture
    BEDROOM;    // bed, endtable, lamp, fireplace, etc.
    KITCHEN;    // fridge, laundry, sink, trash, etc.
    BATHROOM;   // toilet, sink, bath, etc.
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
opposite :: (dir_index: int) -> int {
    i := dir_index + 2;
    return i % 4;
}

room_type_color :: (type: Cell_Room_Type, x: int, y: int) -> Color {
    color: Color;
    if #complete type == {
        case .EMPTY;
            if is_on_map(x, y)
                return Color.{150,  150,  150,  255};
            else if is_in_vision(x, y) 
                return Color.{100,  100,  100,  255};
            else 
                return Color.{50,   50,   50,   255};

        case .BLANK_ROOM;   color = YELLOW;
        case .HALLWAY;      color = GREEN;
        case .BEDROOM;      color = BEIGE;
        case .KITCHEN;      color = ORANGE;
        case .BATHROOM;     color = WHITE;
    }

    if !is_in_vision(x, y) 
        return Color.{50, 50, 50, 255};
    if !is_on_map(x, y) {
        color.r = cast(u8) clamp(color.r * 0.5, 0, 255);
        color.g = cast(u8) clamp(color.g * 0.5, 0, 255);
        color.b = cast(u8) clamp(color.b * 0.5, 0, 255);
    }
    
    return color;
}

room_type_color :: (type: Cell_Room_Type) -> Color {
    color: Color;
    if type == {
        case .BLANK_ROOM;   color = YELLOW;
        case .HALLWAY;      color = GREEN;
        case .BEDROOM;      color = BEIGE;
        case .KITCHEN;      color = ORANGE;
        case .BATHROOM;     color = WHITE;
    }
    return color;
}