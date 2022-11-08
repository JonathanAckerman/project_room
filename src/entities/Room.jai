Room :: struct {
    using #as entity: Entity;
    width:      int; // # cells
    height:     int; // # cells
    type:       Room_Type;
    using cell_coord: struct {
        x: int;
        y: int;
    };
}

left   :: (room) => room.x;
right  :: (room) => room.x + room.width - 1;
top    :: (room) => room.y;
bottom :: (room) => room.y + room.height - 1;

Room_Type :: enum {
    EMPTY;
}

render :: (using room: *Room) {
    size := xy(width * CELL_WIDTH + (width - 1), height * CELL_WIDTH + (height - 1));
    color := YELLOW;
    DrawRectangleV(position, size, color);
}

draw_room_ghost :: (room: *Room) {
    size := xy(room.width * CELL_WIDTH + (room.width - 1), room.height * CELL_WIDTH + (room.height - 1));
    color := YELLOW;
    color.a = 100;

    x, y := get_cell_index(input.mouse_position);
    room.x = x;
    room.y = y;

    if is_valid_placement(room) {
        DrawRectangleV(get_cell_position(x, y), size, color);
        game.intended_cursor = .POINTING_HAND;
    } else {
        DrawRectangleV(input.mouse_position - size/2, size, color);
        game.intended_cursor = .NOT_ALLOWED;
    }
}

draw_room_representation :: (room: Room, position: Vector2, opacity: u8 = 255) {
    size := xy(room.width * CELL_WIDTH + (room.width - 1), room.height * CELL_WIDTH + (room.height - 1));
    color := YELLOW;
    color.a = opacity;

    for i: 0..room.width - 1 {
        for j: 0..room.height - 1 {
            pos := position + xy(xx i, xx j) * (CELL_WIDTH + 1);
            DrawRectangleV(pos, CELL_SIZE, color);
            DrawRectangleLines(xx (pos.x-1), xx (pos.y-1), xx (CELL_WIDTH+2), xx (CELL_WIDTH+2), BLACK);
        }
    }
}

room_at_coord :: (x: int, y: int) -> *Room {
    for context.entity_storage._Room {
        for i: 0..it.width-1 {
            for j: 0..it.height-1 {
                cell_x := it.x + i;
                cell_y := it.y + j;

                if x == cell_x && y == cell_y {
                    return it;
                }
            }
        }
    }
    return null;
}