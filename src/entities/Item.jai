Item :: struct {
    using #as entity: Entity;
    type: Item_Type;
    cells: [] coord;

    coord :: struct {
        x: int;
        y: int;
    }
}

Item_Type :: enum {
    TREE;

    TOILET;
    BED;
    FIREPLACE;
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
    }
}