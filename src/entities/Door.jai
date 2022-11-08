HORIZ_DOOR_SIZE :: Vector2.{CELL_WIDTH, 5};
VERT_DOOR_SIZE :: Vector2.{5, CELL_WIDTH};

// Door :: struct {
//     using #as entity: Entity;
//     alignment: Door_Alignment;
//     using cell_coord: struct {
//         x: int;
//         y: int;
//     };
//     width: int;
// }

// Door_Alignment :: enum {
//     NORTH;
//     EAST;
//     SOUTH;
//     WEST;
// }

// render :: (using door: *Door) {
//     pos:    Vector2;
//     size:   Vector2;
//     gutter: Vector2;
//     cell_center := get_cell_position(x, y) + CELL_SIZE/2.0;
//     if alignment == {        
//         case .NORTH;
//             gutter = xy(0, -1);
//             size = HORIZ_DOOR_SIZE + xy(2, 0);
//             pos = cell_center - xy(0, CELL_WIDTH/2.0);
//         case .EAST;
//             gutter = xy(1, 0);
//             size = VERT_DOOR_SIZE + xy(0, 2);
//             pos = cell_center + xy(CELL_WIDTH/2.0, 0);
//         case .SOUTH;
//             gutter = xy(0, 0);
//             size = HORIZ_DOOR_SIZE + xy(2, 0);
//             pos = cell_center + xy(0, CELL_WIDTH/2.0);
//         case .WEST;
//             gutter = xy(0, 0);
//             size = VERT_DOOR_SIZE + xy(0, 2);
//             pos = cell_center - xy(CELL_WIDTH/2.0, 0);
//     }
//     pos -= size/2;
//     pos += gutter;
//     DrawRectangleV(pos, size, BLACK);
// }

// draw_door_ghost :: (door: *Door) {
//     size := HORIZ_DOOR_SIZE;
//     color := BLUE;
//     color.a = 100;

//     x, y := get_cell_index(input.mouse_position);
//     door.x = x;
//     door.y = y;

//     // find the nearest edge for the cell containing the mouse
//     cell_center := get_cell_position(x, y) + CELL_SIZE/2.0;
//     edges: [4] Vector2;
//     edges[0] = cell_center - xy(0, CELL_WIDTH/2.0); // North
//     edges[1] = cell_center + xy(CELL_WIDTH/2.0, 0); // East
//     edges[2] = cell_center + xy(0, CELL_WIDTH/2.0); // South
//     edges[3] = cell_center - xy(CELL_WIDTH/2.0, 0); // West
//     min_dist: float = distance(input.mouse_position, edges[0]);
//     min_index: int;
//     for edges {
//         dist := distance(input.mouse_position, it);
//         if dist < min_dist {
//             min_dist = dist;
//             min_index = it_index;
//         }
//     }
//     door.alignment = cast(Door_Alignment) min_index;

//     if is_valid_placement(door) {
//         position := edges[min_index];
//         gutter: Vector2;
//         if min_index == {
//             case 0;
//                 gutter = xy(0, -1);
//             case 1;
//                 gutter = xy(1, 0);
//                 size = VERT_DOOR_SIZE;
//             case 2;
//                 gutter = xy(0, 0);
//             case 3;
//                 gutter = xy(0, 0);
//                 size = VERT_DOOR_SIZE;
//         }
//         position -= size/2;
//         position += gutter;
//         door.position = position;
//         DrawRectangleV(position, size, color);
//         game.intended_cursor = .POINTING_HAND;
//     } else {
//         DrawRectangleV(input.mouse_position - size/2, size, color);
//         game.intended_cursor = .NOT_ALLOWED;
//     }
// }