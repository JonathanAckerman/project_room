Cell :: struct {
    using #as entity: Entity;

}

left   :: (cell) => cell.position.x - cell.size.x/2.0;
right  :: (cell) => cell.position.x + cell.size.x/2.0;
top    :: (cell) => cell.position.y - cell.size.y/2.0;
bottom :: (cell) => cell.position.y - cell.size.y/2.0;

simulate :: (using cell: *Cell) {

}

render :: (using cell: *Cell) {

}