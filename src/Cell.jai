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
clockwise :: (dir: Direction) -> Direction {
    i := (cast(int) dir) + 1;
    return cast(Direction)(i % 4);
}
counter_clockwise :: (dir: Direction) -> Direction {
    i := (cast(int) dir) + 3;
    return cast(Direction)(i % 4);
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

rotate_stamp :: (cells: *[] Card_Cell) {
    N := cast(int) sqrt(cast(float) cells.count);
    
    cycle_width := N;
    row_number := 0;
    while cycle_width > 0 { // row loop
        index := N * row_number + row_number;
        for i: 0..cycle_width-2 { // col loop
            source := (<<cells)[index];
            source_index := index;
            for 0..3 { // cycle loop
                // find dest
                dest_x, dest_y := (N-1) - (source_index / N), source_index % N;
                dest := *(<<cells)[dest_y * N + dest_x];

                // replaced = dest (copy out dest)
                replaced := (<<cells)[dest_y * N + dest_x];
                replaced_index := dest_y * N + dest_x;

                // dest = source, except their coords
                coord := dest.coord;
                <<dest = source;
                dest.coord = coord;

                // rotate dest walls
                edge_source := dest.edges[0];
                for 0..3 {
                    edge_dest := (it + 1) % 4;
                    edge_replaced := dest.edges[edge_dest];
                    dest.edges[edge_dest] = edge_source;
                    edge_source = edge_replaced;
                }

                // source = replaced
                source = replaced;
                source_index = replaced_index;
            }
            index += 1;
        }

        // rotate the center cell
        if cycle_width == 1 {
            index = N * row_number + row_number;
            center_cell := *(<<cells)[index].cell;
            edge_source := center_cell.edges[0];
            for 0..3 {
                edge_dest := (it + 1) % 4;
                edge_replaced := center_cell.edges[edge_dest];
                center_cell.edges[edge_dest] = edge_source;
                edge_source = edge_replaced;
            }
            return;
        }

        row_number += 1;
        cycle_width -= 2;
    }
}