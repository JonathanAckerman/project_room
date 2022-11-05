Room :: struct {
    using #as entity: Entity;
    width: int;  // # cells
    height: int; // # cells
    type: Room_Type;

    is_placed: bool;
    cell_coord: struct {
        x: int;
        y: int;
    };
}

left   :: (room) => room.cell_coord.x;
right  :: (room) => room.cell_coord.x + room.width - 1;
top    :: (room) => room.cell_coord.y;
bottom :: (room) => room.cell_coord.y + room.height - 1;

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
    room.cell_coord.x = x;
    room.cell_coord.y = y;

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

// Archetypes -----------------------------------------------------------------------
Rooms: struct {
    // @@@: I maybe need to rethink this

    //
    // Squares
    //
    R11 :: Room.{
        width=1,
        height=1,
    };
    R22 :: Room.{
        width=2,
        height=2,
    };
    R33 :: Room.{
        width=3,
        height=3,
    };
    R44 :: Room.{
        width=4,
        height=4,
    };
    R55 :: Room.{
        width=5,
        height=5,
    };
    
    //
    // 1xN
    //
    R12 :: Room.{
        width=1,
        height=2,
    };
    R21 :: Room.{
        width=2,
        height=1,
    };
    R13 :: Room.{
        width=1,
        height=3,
    };
    R31 :: Room.{
        width=3,
        height=1,
    };
    R14 :: Room.{
        width=1,
        height=4,
    };
    R41 :: Room.{
        width=4,
        height=1,
    };
    R15 :: Room.{
        width=1,
        height=5,
    };
    R51 :: Room.{
        width=5,
        height=1,
    };
    
    //
    // 2xN
    //
    R23 :: Room.{
        width=2,
        height=3,
    };
    R32 :: Room.{
        width=3,
        height=2,
    };
    R24 :: Room.{
        width=2,
        height=4,
    };
    R42 :: Room.{
        width=4,
        height=2,
    };
    R25 :: Room.{
        width=2,
        height=5,
    };
    R52 :: Room.{
        width=5,
        height=2,
    };

    //
    // 3xN
    //
    R34 :: Room.{
        width=3,
        height=4,
    };
    R43 :: Room.{
        width=4,
        height=3,
    };
    R35 :: Room.{
        width=3,
        height=5,
    };
    R53 :: Room.{
        width=5,
        height=3,
    };

    //
    // 4xN
    //
    R45 :: Room.{
        width=4,
        height=5,
    };
    R54 :: Room.{
        width=5,
        height=4,
    };
}

Hand_Slot :: struct {
    room: Room;
    exists: bool;
}