HORIZ_DOOR_SIZE :: Vector2.{CELL_WIDTH, 5};
VERT_DOOR_SIZE :: Vector2.{5, CELL_WIDTH};

Door :: struct {
    using #as entity: Entity;
    facing: Door_Facing;
    cell_coord: struct {
        x: int;
        y: int;
    };
}

Door_Facing :: enum {
    NORTH;
    EAST;
    SOUTH;
    WEST;
}

render :: (using door: *Door) {
    pos: Vector2;
    size: Vector2;
    cell_center := get_cell_position(cell_coord.x, cell_coord.y) + CELL_SIZE/2.0;
    if facing == {
        case .NORTH;
            size = HORIZ_DOOR_SIZE;
            pos = cell_center - xy(size.x/2, CELL_WIDTH/2.0);
        case .EAST;
            size = VERT_DOOR_SIZE;
            pos = cell_center + xy(CELL_WIDTH/2.0, -size.y/2);
        case .SOUTH;
            size = HORIZ_DOOR_SIZE;
            pos = cell_center + xy(-size.x/2, CELL_WIDTH/2.0);
        case .WEST;
            size = VERT_DOOR_SIZE;
            pos = cell_center - xy(CELL_WIDTH/2.0, -size.y/2);
    }
    DrawRectangleV(pos, size, BLUE);
}