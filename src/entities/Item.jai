Item :: struct {
    using #as entity: Entity;
    type: Item_Type;
    cells: [..] coord;

    coord :: struct {
        x: int;
        y: int;
    }
}

Item_Type :: enum {
    // Blocking items
    TREE;

    // Non-blocking items (but room rules still apply)
    TOILET;
    BED;
    FIREPLACE;
}

init :: (using item: *Item) {
    if item.type == {
        case .TOILET;
            array_copy(*item.cells, TOILET_CELLS);
    }
}

render :: (using item: *Item) {
    if type == {
        case .TREE;
            for cells if is_in_vision(it.x, it.y) { // if any cell is in vision we need to draw it
                color := Color.{ 0, 70, 10, 255 };
                for cells if is_on_map(it.x, it.y) { color = DARKGREEN; break; }

                on_grid, base_cell := get_cell(cells[0].x, cells[0].y);
                width := sqrt(cast(float) cells.count);
                base_pos := get_cell_position(base_cell.x, base_cell.y);
                radius := (width/2) * CELL_WIDTH + width/2;
                DrawCircleV(base_pos + (width/2) * CELL_SIZE + xy(1,1), radius, color);
                break;
            }
        case .TOILET;
            on_grid, base_cell := get_cell(cells[0].x, cells[0].y);
            color := LIGHTGRAY;
            for cells if is_on_map(it.x, it.y) then color = WHITE;
            base_pos := get_cell_position(base_cell.x, base_cell.y);
            draw_pos := base_pos + CELL_SIZE/2 + xy(1,1);
            DrawCircleV(draw_pos, CELL_WIDTH/2 - 3.0, color);
            DrawCircleLines(xx draw_pos.x, xx draw_pos.y, CELL_WIDTH/2 - 3.0, BLACK);
    }
}

is_blocking :: (type: Item_Type) -> bool {
    if type == {
        case .TREE; return true;
        case;
            return false;
    }
}
// ???: should use enum_flags to allow multiple room types?
get_room_requirement :: (type: Item_Type) -> Cell_Room_Type {
    if type == {
        case .TREE;   return .EMPTY;
        case .TOILET; return .BATHROOM;
        case;         return .BLANK_ROOM;
    }
}

TOILET_CELLS :: Item.coord.[.{0,0}];