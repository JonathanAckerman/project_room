Room :: struct {
    using #as entity: Entity;
    width:      int; // # cells
    height:     int; // # cells
    type:       Room_Type;
    is_placed:  bool;
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

simulate :: (using room: *Room) {

}

render :: (using room: *Room) {
    size := xy(width * CELL_WIDTH + (width - 1), height * CELL_WIDTH + (height - 1));
    color := YELLOW;
    DrawRectangleV(position, size, color);
}

draw_room_ghost :: (room: *Room, position: Vector2) {
    size := xy(room.width * CELL_WIDTH + (room.width - 1), room.height * CELL_WIDTH + (room.height - 1));
    color := YELLOW;
    color.a = 100;

    x, y := get_cell_index(position);
    room.x = x;
    room.y = y;

    if is_valid_placement(x, y, room) {
        DrawRectangleV(get_cell_position(x, y), size, color);
        game.intended_cursor = .POINTING_HAND; // @Jank: drawing a ghost shouldnt set the cursor
    } else {
        DrawRectangleV(position, size, color);
        game.intended_cursor = .NOT_ALLOWED;
    }
}
draw_room_representation :: (room: Room, position: Vector2, opacity: u8) {
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