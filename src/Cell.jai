Cell :: struct {
    using coords: coord;
    room: Cell_Room_Type;
    edges: [4] Border_Type;

    coord :: struct {
        x: int;
        y: int;
    }
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
direction_index_between :: (from: Cell.coord, to: Cell.coord) -> int {
    dir_x := to.x - from.x;
    dir_y := to.y - from.y;
    direction_index := -1;
    if dir_x == 0 && dir_y == -1 then direction_index = cast(int) Direction.NORTH;
    if dir_x == 1 && dir_y == 0  then direction_index = cast(int) Direction.EAST;
    if dir_x == 0 && dir_y == 1  then direction_index = cast(int) Direction.SOUTH;
    if dir_x == -1 && dir_y == 0 then direction_index = cast(int) Direction.WEST;

    return direction_index;
}

room_type_color :: (type: Cell_Room_Type, x: int, y: int) -> Color {
    color: Color;
    if #complete type == {
        case .EMPTY;
            if is_in_vision(x, y) 
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

    if type != .EMPTY {
        for game.adventurers_visited if it.x == x && it.y == y {
            color.r = cast(u8) clamp(color.r * 0.5, 0, 255);
            color.g = cast(u8) clamp(color.g * 0.5, 0, 255);
            color.b = cast(u8) clamp(color.b * 0.5, 0, 255);
        }
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
                coords := dest.coords;
                <<dest = source;
                dest.coords = coords;

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

get_cell_index :: (point: Vector2) -> int, int {
    x := cast(int) (point.x / (CELL_WIDTH + 1));
    y := cast(int) (point.y / (CELL_WIDTH + 1));

    if x < 0 || y < 0 return -1, -1;
    if x > GRID_WIDTH || y > GRID_HEIGHT return -1, -1;
    return x, y;
}

get_cell_position :: (x_index: int, y_index: int) -> Vector2 {
    x := x_index * (CELL_WIDTH + 1);
    y := y_index * (CELL_WIDTH + 1);
    return xy(x, y);
}

get_cell :: (x: int, y: int) -> *Cell {
    assert(is_on_grid(x, y), "cell not on grid");
    return *game.grid[y][x];
}
get_cell :: (coord: Cell.coord) -> *Cell {
    assert(is_on_grid(coord.x, coord.y), "cell not on grid");
    return *game.grid[coord.y][coord.x];
}

get_neighbor :: (x: int, y: int, direction: Direction) -> bool, *Cell {
    neighbor_x := x;
    neighbor_y := y;
    if #complete direction == {
        case .NORTH;
            neighbor_y -= 1;
        case .EAST;
            neighbor_x += 1;
        case .SOUTH;
            neighbor_y += 1;
        case .WEST;
            neighbor_x -= 1;
    }

    if !is_on_grid(neighbor_x, neighbor_y) return false, null;

    result := get_cell(neighbor_x, neighbor_y);
    return is_on_grid(result.x, result.y), result;
}