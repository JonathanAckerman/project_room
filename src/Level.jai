HORIZ_DOOR_SIZE :: Vector2.{CELL_WIDTH, 5};
VERT_DOOR_SIZE :: Vector2.{5, CELL_WIDTH};

Level :: struct {
    width:  [4] int;
    height: [4] int;
    cards:  [..] Card;
    starting_cells: [..] Cell;
    starting_items: [..] Item;
}

#run {
    for Level_Sequence assert(it.cards.count % 3 == 0, "Level %: # of cards % 3 must == 0", it_index+1);
}

Level_Sequence: [1] Level = .[
    LEVELS.TUTORIAL_1,
    // Levels.TUTORIAL_2,
    // Levels.TUTORIAL_3,
    // Levels.TUTORIAL_4,
];

init :: (using level: *Level, index: int) {
    if index == {
        case 0;
            array_copy(*level.cards,          LEVELS.TUTORIAL_1_CARDS);
            array_copy(*level.starting_items, LEVELS.TUTORIAL_1_ITEMS);
            array_copy(*level.starting_cells, LEVELS.TUTORIAL_1_CELLS);
    }
}

// Archetypes -----------------------------------------------------------------------
LEVELS :: struct {
    TUTORIAL_1 :: Level.{
        width= .[5, 9, 15, GRID_WIDTH],
        height=.[5, 9, 15, GRID_HEIGHT],
    };

    TUTORIAL_1_CARDS :: Card.[
        Cards.R11,
        Cards.R22,
        Cards.M22,

        Cards.I11,
        Cards.R22,
        Cards.M22,

        Cards.D1,
        Cards.D1,
        Cards.TOILET,
    ];

    TUTORIAL_1_CELLS :: Cell.[
        .{.{GRID_WIDTH/2,   GRID_HEIGHT/2},   .BLANK_ROOM, .[.EMPTY, .WALL, .WALL, .WALL]},
        .{.{GRID_WIDTH/2,   GRID_HEIGHT/2-1}, .BLANK_ROOM, .[.EMPTY, .EMPTY, .EMPTY, .WALL]},
        .{.{GRID_WIDTH/2,   GRID_HEIGHT/2-2}, .BLANK_ROOM, .[.WALL, .WALL, .EMPTY, .WALL]},
        .{.{GRID_WIDTH/2+1, GRID_HEIGHT/2-1}, .BLANK_ROOM, .[.WALL, .EMPTY, .WALL, .EMPTY]},
        .{.{GRID_WIDTH/2+2, GRID_HEIGHT/2-1}, .BLANK_ROOM, .[.EMPTY, .WALL, .EMPTY, .EMPTY]},
        .{.{GRID_WIDTH/2+2, GRID_HEIGHT/2},   .BLANK_ROOM, .[.EMPTY, .WALL, .WALL, .WALL]},
        .{.{GRID_WIDTH/2+2, GRID_HEIGHT/2-2}, .BLANK_ROOM, .[.WALL, .WALL, .EMPTY, .WALL]},

        .{.{GRID_WIDTH/2-3,   GRID_HEIGHT/2+2},   .BLANK_ROOM, .[.WALL, .EMPTY, .WALL, .WALL]},
        .{.{GRID_WIDTH/2-3+1, GRID_HEIGHT/2+2},   .BLANK_ROOM, .[.EMPTY, .EMPTY, .WALL, .EMPTY]},
        .{.{GRID_WIDTH/2-3+2, GRID_HEIGHT/2+2},   .BLANK_ROOM, .[.WALL, .WALL, .WALL, .EMPTY]},
        .{.{GRID_WIDTH/2-3+1, GRID_HEIGHT/2+2-1}, .BLANK_ROOM, .[.EMPTY, .WALL, .EMPTY, .WALL]},
        .{.{GRID_WIDTH/2-3,   GRID_HEIGHT/2+2-2}, .BLANK_ROOM, .[.WALL, .EMPTY, .WALL, .WALL]},
        .{.{GRID_WIDTH/2-3+1, GRID_HEIGHT/2+2-2}, .BLANK_ROOM, .[.WALL, .EMPTY, .EMPTY, .EMPTY]},
        .{.{GRID_WIDTH/2-3+2, GRID_HEIGHT/2+2-2}, .BLANK_ROOM, .[.WALL, .WALL, .WALL, .EMPTY]},

        // test in vision
        .{.{GRID_WIDTH/2-4, GRID_HEIGHT/2-4}, .BLANK_ROOM, .[.WALL, .WALL, .WALL, .WALL]},
        // test out of vision
        .{.{GRID_WIDTH/2-6, GRID_HEIGHT/2-6}, .BLANK_ROOM, .[.WALL, .WALL, .WALL, .WALL]},
    ];

    TUTORIAL_1_ITEMS :: Item.[
        .{type=.TREE_1x1},
        .{type=.TREE_2x2},
        .{type=.TREE_3x3},
    ];
    // TUTORIAL_2 :: Level.{
    //     width= .[7, 11, 15, GRID_WIDTH],
    //     height=.[7, 11, 15, GRID_HEIGHT],
    //     cards=.[
    //         Cards.R11,
    //         Cards.R22,
    //         Cards.M22,

    //         Cards.I11,
    //         Cards.R22,
    //         Cards.M22,

    //         Cards.R11,
    //         Cards.R22,
    //         Cards.M22,

    //         Cards.I11,
    //         Cards.R22,
    //         Cards.M22,

    //         Cards.D1,
    //         Cards.D1,
    //         Cards.D1,
    //     ],
    //     starting_cells=.[
    //         Cell.{.{GRID_WIDTH/2+1, GRID_HEIGHT/2-1}, .BLANK_ROOM, .[.WALL, .EMPTY, .WALL, .WALL]},
    //         Cell.{.{GRID_WIDTH/2+2, GRID_HEIGHT/2-1}, .BLANK_ROOM, .[.EMPTY, .WALL, .EMPTY, .EMPTY]},
    //         Cell.{.{GRID_WIDTH/2+2, GRID_HEIGHT/2},   .BLANK_ROOM, .[.EMPTY, .WALL, .WALL, .WALL]},
    //         Cell.{.{GRID_WIDTH/2+2, GRID_HEIGHT/2-2}, .BLANK_ROOM, .[.WALL, .WALL, .EMPTY, .WALL]},

    //         Cell.{.{GRID_WIDTH/2-3,   GRID_HEIGHT/2+2},   .BLANK_ROOM, .[.WALL, .EMPTY, .WALL, .WALL]},
    //         Cell.{.{GRID_WIDTH/2-2, GRID_HEIGHT/2+2},   .BLANK_ROOM, .[.WALL, .WALL, .WALL, .EMPTY]},
    //         Cell.{.{GRID_WIDTH/2-2, GRID_HEIGHT/2}, .BLANK_ROOM, .[.WALL, .EMPTY, .WALL, .WALL]},
    //         Cell.{.{GRID_WIDTH/2-1, GRID_HEIGHT/2}, .BLANK_ROOM, .[.WALL, .WALL, .WALL, .EMPTY]},
    //     ],
    // };
    // TUTORIAL_3 :: Level.{
    //     width= .[7, 11, 15, GRID_WIDTH],
    //     height=.[7, 11, 15, GRID_HEIGHT],
    //     cards=.[
    //         Cards.R11,
    //         Cards.R22,
    //         Cards.M22,

    //         Cards.I11,
    //         Cards.R22,
    //         Cards.M22,

    //         Cards.R11,
    //         Cards.R22,
    //         Cards.M22,

    //         Cards.I11,
    //         Cards.R22,
    //         Cards.M22,

    //         Cards.D1,
    //         Cards.D1,
    //         Cards.D1,

    //         Cards.R11,
    //         Cards.M22,
    //         Cards.M22,

    //         Cards.I11,
    //         Cards.M22,
    //         Cards.M22,

    //         Cards.R11,
    //         Cards.M22,
    //         Cards.M22,

    //         Cards.I11,
    //         Cards.M22,
    //         Cards.M22,

    //         Cards.D1,
    //         Cards.D1,
    //         Cards.D1,
    //     ],
    //     starting_cells=.[
    //         Cell.{.{GRID_WIDTH/2+1, GRID_HEIGHT/2-1}, .BLANK_ROOM, .[.WALL, .EMPTY, .WALL, .WALL]},
    //         Cell.{.{GRID_WIDTH/2+2, GRID_HEIGHT/2-1}, .BLANK_ROOM, .[.EMPTY, .WALL, .EMPTY, .EMPTY]},
    //         Cell.{.{GRID_WIDTH/2+2, GRID_HEIGHT/2},   .BLANK_ROOM, .[.EMPTY, .WALL, .WALL, .WALL]},
    //         Cell.{.{GRID_WIDTH/2+2, GRID_HEIGHT/2-2}, .BLANK_ROOM, .[.WALL, .WALL, .EMPTY, .WALL]},

    //         Cell.{.{GRID_WIDTH/2-3,   GRID_HEIGHT/2+2},   .BLANK_ROOM, .[.WALL, .EMPTY, .WALL, .WALL]},
    //         Cell.{.{GRID_WIDTH/2-2, GRID_HEIGHT/2+2},   .BLANK_ROOM, .[.WALL, .WALL, .WALL, .EMPTY]},
    //         Cell.{.{GRID_WIDTH/2-2, GRID_HEIGHT/2}, .BLANK_ROOM, .[.WALL, .EMPTY, .WALL, .WALL]},
    //         Cell.{.{GRID_WIDTH/2-1, GRID_HEIGHT/2}, .BLANK_ROOM, .[.WALL, .WALL, .WALL, .EMPTY]},
    //     ],
    // };
}

simulate_level :: () {
    using game;

    if level.starting_cells.count > 0 then is_first_placement = false;

    // deal cards
    hand_count := count_hand();
    if hand_count == 0 && deck.count > 0 {
        for i: 0..2 {
            hand[i] = pop(*deck);
        }
    }

    if input.clicked {
        reset_highlight := true;
        // map clicked
        if is_mouse_over(game.map_top_left, map_size) && highlighted_card > -1 {
            card, gone := from_handle(hand[highlighted_card]);
            if !gone {
                if card.type == {
                    case .MIXED;
                        if is_valid_placement(card.stamp.cells) {
                            result := get_stamp_result(card.stamp.cells);
                            for result { 
                                grid[it.y][it.x] = it; 
                                for edge, e_index: it.edges if edge == .DOOR {
                                    in_bounds, neighbor := get_neighbor(it.x, it.y, cast(Direction) e_index);
                                    if in_bounds {
                                        neighbor.edges[opposite(e_index)] = .EMPTY;
                                    }
                                }
                            }
                            despawn(card);
                        }
                        else reset_highlight = false;
                    case .DOOR;
                        x, y := get_cell_index(input.mouse_position);
                        direction := get_nearest_edge(x, y);
                        if is_valid_door_placement(x, y, direction, card.door.width, card.door.type) {
                            grid[y][x].edges[cast(int) direction] = .DOOR;
                            in_bounds, neighbor := get_neighbor(x, y, direction);
                            if in_bounds {
                                opposite_direction := cast(int) opposite(direction);
                                neighbor.edges[opposite_direction] = .EMPTY;
                            }
                            despawn(card);
                        }
                        else reset_highlight = false;
                    case .ITEM;
                        x, y := get_cell_index(input.mouse_position);
                        direction := get_nearest_edge(x, y);
                        if is_valid_item_placement(x, y, direction, card.item) {
                            for * card.item.cells {
                                it.x += x;
                                it.y += y;
                            }
                            spawn(card.item);
                            despawn(card);
                        }
                }
            }
        }
        
        // hand clicked
        for hand if is_mouse_over(HAND_POS[it_index], CARD_SIZE) && exists(it) {
            reset_highlight = highlighted_card == it_index;
            highlighted_card = it_index;
        }
        
        if reset_highlight {
            highlighted_card = -1;
            intended_cursor = .CROSSHAIR;
        }
    }

    // @Note: apparently setting the cursor is jank and shouldn't be 
    //        done in a game loop, to get around this I use a flag
    if game.intended_cursor != game.mouse_cursor {
        SetMouseCursor(xx game.intended_cursor);
        game.mouse_cursor = game.intended_cursor;
    }

    check_level_success();
}

render_level :: () {
    using game;
    using context.entity_storage;

    //
    // draw grid cells
    //
    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            color := room_type_color(grid[y][x].room, x, y);
            cell := grid[y][x];
            pos := xy(1 + x * CELL_WIDTH + x, 1 + y * CELL_WIDTH + y);
            DrawRectangleV(pos, CELL_SIZE, color);
            if debug then DrawTextEx(Fonts.bahnschrift, temp_c_string(tprint("%, %", x, y)), pos, 10, 1, WHITE);
        }
    }

    // draw doors on grid
    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            if is_in_vision(x, y) {
                for grid[y][x].edges if it == {
                    case .DOOR;
                        draw_door(get_cell_position(x, y), cast(Direction) it_index);
                }
            }
        }
    }
    // draw walls on grid
    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            if is_in_vision(x, y) {
                for grid[y][x].edges if it == {
                    case .WALL;
                        draw_wall(get_cell_position(x, y), cast(Direction) it_index);
                }
            }
        }
    }

    if state == .LEVEL then draw_level_sidebar();

    for _Item render(it);

    //
    // draw ghosts
    //
    if highlighted_card > -1 {
        card, gone := from_handle(hand[highlighted_card]);
        if !gone {
            if card.type == {
                case .MIXED;
                    if is_valid_placement(card.stamp.cells) {
                        projected_result := get_stamp_result(card.stamp.cells);
                        if projected_result.count > 0 {
                            draw_cells(projected_result, 255);
                            intended_cursor = .POINTING_HAND;
                        }
                    }
                    else {
                        draw_card_cells(card.stamp.cells, input.mouse_position - CELL_SIZE/2, 100);
                        intended_cursor = .NOT_ALLOWED;
                    }
                case .DOOR;
                    using card.door;
                    x, y := get_cell_index(input.mouse_position);
                    pos := input.mouse_position;
                    direction := get_nearest_edge(x, y);
                    if is_valid_door_placement(x, y, direction, width, type) {
                        draw_door(get_cell_position(x, y), direction, 255);
                        intended_cursor = .POINTING_HAND;
                    }
                    else {
                        draw_door(pos - HORIZ_DOOR_SIZE/2, 255);
                        intended_cursor = .NOT_ALLOWED;
                    }
                case .ITEM;
                    using card.item;
                    x, y := get_cell_index(input.mouse_position);
                    pos := input.mouse_position;
                    direction := get_nearest_edge(x, y);
                    if is_valid_item_placement(x, y, direction, card.item) {
                        draw_item(x, y, direction, 255);
                        intended_cursor = .POINTING_HAND;
                    }
                    else {
                        draw_item(pos, 255);
                        intended_cursor = .NOT_ALLOWED;
                    }

            }
        }
    }

    if state == .LEVEL then DrawTextEx(Fonts.bahnschrift, "Press 'R' to restart level", xy(SIDEBAR_LEFT + 50, WINDOW_HEIGHT - 50), 24, 1, WHITE);
}

draw_level_sidebar :: () {
    using game;

    //
    // draw deck
    //
    {
        using game.level;

        color := ifx cards.count == 0 then DARKGRAY else LIGHTGRAY;
        pos := xy(SIDEBAR_LEFT + 50, 100);
        DrawTextEx(Fonts.bahnschrift, "Deck", pos - xy(0, 50), 32, 1, WHITE);
        DrawRectangleV(pos, CARD_SIZE, color);
    }

    //
    // draw hand
    //
    {
        DrawTextEx(Fonts.bahnschrift, "Hand", HAND_POS[0] - xy(0, 50), 32, 1, WHITE);

        // highlighted_card outer glow
        if highlighted_card > -1 {
            r: Rectangle;
            r.x = HAND_POS[highlighted_card].x - 4;
            r.y = HAND_POS[highlighted_card].y - 4;
            r.width = CARD_WIDTH + 8;
            r.height = CARD_HEIGHT + 8;
            DrawRectangleLinesEx(r, 8.0, BLUE);
        }

        for hand {
            // draw card background
            color := DARKGRAY;
            if exists(it) {
                color = LIGHTGRAY;
                if level_has_focus && is_mouse_over(HAND_POS[it_index], CARD_SIZE) then color = WHITE;
            }
            DrawRectangleV(HAND_POS[it_index], xy(185, 250), ifx highlighted_card == it_index then WHITE else color);

            // draw representation on cards
            card, gone := from_handle(it);
            if !gone {
                card_center := HAND_POS[it_index] + CARD_SIZE/2.0;
                if card.type == {
                    case .MIXED;
                        stamp_width := cast(int) sqrt(cast(float) card.stamp.cells.count);
                        pixel_width := CELL_WIDTH * stamp_width;
                        stamp_base_pos := card_center - xy(pixel_width/2, pixel_width/2);
                        draw_card_cells(card.stamp.cells, stamp_base_pos);
                    case .DOOR;
                        color := BLUE;
                        size := xy(100, 30);
                        DrawRectangleV(card_center - xy(50, 15), size, color);
                    case .ITEM;
                        color := WHITE;
                        radius := 40.0;
                        DrawCircleV(card_center, radius, color);
                        DrawCircleLines(xx card_center.x, xx card_center.y, radius, BLACK);
                }
            }
        }
    }
}

draw_cells :: (cells: [] Cell, opacity: u8 = 255) {
    for cells {
        color := room_type_color(it.room, it.x, it.y);
        color.a = opacity;
        pos := xy(xx it.x, xx it.y) * (CELL_WIDTH + 1) + xy(1, 1);
        DrawRectangleV(pos, CELL_SIZE, color);
        DrawRectangleLines(xx (pos.x-1), xx (pos.y-1), xx (CELL_WIDTH+2), xx (CELL_WIDTH+2), BLACK);
        // the overlapping gutters will be darker than the borders but dgaf

        for edge, edge_index: it.edges {
            if edge == .DOOR then draw_door(get_cell_position(it.x, it.y), cast(Direction) edge_index, opacity);
        }
        for edge, edge_index: it.edges {
            if edge == .WALL then draw_wall(get_cell_position(it.x, it.y), cast(Direction) edge_index);
        }
    }
}
draw_card_cells :: (cells: [] Card_Cell, position: Vector2, opacity: u8 = 255) {
    for cells {
        color := room_type_color(it.room);
        color.a = opacity;
        pos := position + xy(xx it.cell.x, xx it.cell.y) * (CELL_WIDTH + 1);
        DrawRectangleV(pos - xy(0,1), CELL_SIZE + xy(0,1), color);
        DrawRectangleLines(xx (pos.x-1), xx (pos.y-1), xx (CELL_WIDTH+2), xx (CELL_WIDTH+2), BLACK);

        for edge, edge_index: it.edges {
            if edge == .DOOR then draw_door(pos - xy(1,1), cast(Direction) edge_index);
        }
        for edge, edge_index: it.edges {
            if edge == .WALL then draw_wall(pos - xy(1,1), cast(Direction) edge_index, it.type);
        }
    }
}

draw_wall :: (cell_pos: Vector2, direction: Direction, style: Card_Cell_Type = .NORMAL) {
    cell_center := cell_pos + CELL_SIZE/2.0;
    offset := direction_to_offset(direction);
    edge := cell_center + offset * CELL_WIDTH/2;
    pieces: [..] Rectangle;

    if style == {
        case .NORMAL;
            rec: Rectangle;
            if direction == .NORTH || direction == .SOUTH {
                size := HORIZ_DOOR_SIZE + xy(2, 0);
                pos := edge - xy(size.x/2 - 1, 0);
                if direction == .SOUTH then pos -= xy(0, size.y - 2);

                rec.x = pos.x;
                rec.y = pos.y;
                rec.width = size.x;
                rec.height = size.y;
                array_add(*pieces, rec);
            }
            else {
                size := VERT_DOOR_SIZE + xy(0, 2);
                pos := edge - xy(0, size.y/2 - 1);
                if direction == .EAST then pos -= xy(size.x - 2, 0);

                rec.x = pos.x;
                rec.y = pos.y;
                rec.width = size.x;
                rec.height = size.y;
                array_add(*pieces, rec);
            }
        case .MERGE;
            piece_size :: 7;
            gutter_size :: 5;
            width: float;
            height: float;
            pos: Vector2;
            offset: Vector2;

            if direction == .NORTH || direction == .SOUTH {
                size := HORIZ_DOOR_SIZE + xy(2, 0);
                pos = edge - xy(size.x/2 - 1, 0);
                if direction == .SOUTH then pos -= xy(0, size.y - 2);
                width = piece_size;
                height = size.y;
                offset = xy(piece_size + gutter_size, 0);
            }
            else {
                size := VERT_DOOR_SIZE + xy(0, 2);
                pos = edge - xy(0, size.y/2 - 1);
                if direction == .EAST then pos -= xy(size.x - 2, 0);
                width = size.x;
                height = piece_size;
                offset = xy(0, piece_size + gutter_size);
            }

            for 0..2 {
                rec: Rectangle;
                rec.x = pos.x;
                rec.y = pos.y;
                rec.width = width;
                rec.height = height;
                array_add(*pieces, rec);
                pos += offset;
            }
        case .INTERIOR;
            beam1: Rectangle;
            beam2: Rectangle;
            wall: Rectangle;
            if direction == .NORTH || direction == .SOUTH {
                size := HORIZ_DOOR_SIZE + xy(2, 0);
                pos := edge - xy(size.x/2 - 1, 0);
                if direction == .SOUTH then pos -= xy(0, size.y);

                beam1.x = pos.x;
                beam1.y = pos.y;
                beam1.width  = size.y;
                beam1.height = size.y;
                array_add(*pieces, beam1);
                
                pos.x += beam1.width;
                if direction == .NORTH then pos.y += 3;

                wall.x = pos.x;
                wall.y = pos.y;
                wall.width  = size.x - size.y * 2;
                wall.height = 2;
                array_add(*pieces, wall);

                pos.x += wall.width;
                if direction == .NORTH then pos.y -= 3;

                beam2.x = pos.x;
                beam2.y = pos.y;
                beam2.width  = size.y;
                beam2.height = size.y;
                array_add(*pieces, beam2);
            }
            else {
                size := VERT_DOOR_SIZE + xy(0, 2);
                pos := edge - xy(0, size.y/2);
                if direction == .WEST then pos += xy(1, 0);
                if direction == .EAST then pos -= xy(size.x - 1, 0);

                beam1.x = pos.x;
                beam1.y = pos.y;
                beam1.width  = size.x;
                beam1.height = size.x;
                array_add(*pieces, beam1);
                
                pos.y += beam1.height;
                if direction == .WEST then pos.x += 3;

                wall.x = pos.x;
                wall.y = pos.y;
                wall.width  = 2;
                wall.height = size.y - size.x * 2;
                array_add(*pieces, wall);

                pos.y += wall.height;
                if direction == .WEST then pos.x -= 3;

                beam2.x = pos.x;
                beam2.y = pos.y;
                beam2.width  = size.x;
                beam2.height = size.x;
                array_add(*pieces, beam2);
            }
    }

    for pieces DrawRectangleRec(it, BLACK);
}

// used to draw doors on the map
draw_door :: (cell_pos: Vector2, direction: Direction, opacity: u8 = 255) {
    color := WHITE;
    color.a = opacity;
    cell_center := cell_pos + CELL_SIZE/2.0;
    offset := direction_to_offset(direction);
    edge := cell_center + offset * CELL_WIDTH/2;
    size: Vector2;
    pos: Vector2;

    if direction == .NORTH || direction == .SOUTH {
        size = HORIZ_DOOR_SIZE + xy(2, 0);
        pos = edge - xy(size.x/2 - 1, 0);
        if direction == .SOUTH then pos -= xy(0, size.y - 2);
    }
    else {
        size = VERT_DOOR_SIZE + xy(0, 2);
        pos = edge - xy(0, size.y/2 - 1);
        if direction == .EAST then pos -= xy(size.x - 2, 0);
    }
    DrawRectangleV(pos, size - xy(0,1), color);
    DrawRectangleLines(xx pos.x, xx pos.y, xx size.x, xx size.y, BLACK);
}

// used to draw doors on the cursor
draw_door :: (position: Vector2, opacity: u8 = 255) {
    color := BLUE;
    color.a = opacity;
    DrawRectangleV(position, HORIZ_DOOR_SIZE, color);
}

draw_item :: (x: int, y: int, direction: Direction, opacity: u8 = 255) {
    color := WHITE;
    color.a = opacity;
    cell_center := get_cell_position(x, y) + CELL_SIZE/2.0;
    DrawCircleV(cell_center, CELL_WIDTH/2 - 3.0, color);
    DrawCircleLines(xx cell_center.x, xx cell_center.y, CELL_WIDTH/2 - 3.0, BLACK);
}
draw_item :: (position: Vector2, opacity: u8 = 255) {
    color := WHITE;
    color.a = opacity;
    DrawCircleV(position, CELL_WIDTH/2 - 3.0, color);
    DrawCircleLines(xx position.x, xx position.y, CELL_WIDTH/2 - 3.0, BLACK);
}

get_stamp_result :: (stamp: [] Card_Cell) -> [] Cell {
    using game;
    result: [..] Cell;

    mouse_x, mouse_y := get_cell_index(input.mouse_position); // maybe remove this dependency
    if mouse_x == -1 || mouse_y == -1 return .[];

    for stamp_cell, stamp_index: stamp {
        cell_x := mouse_x + stamp_cell.x;
        cell_y := mouse_y + stamp_cell.y;

        result_cell := grid[cell_y][cell_x];

        // update edges
        if stamp_cell.type == {
            case .NORMAL;
                for * result_cell.edges {
                    if <<it < stamp_cell.edges[it_index] {
                        <<it = stamp_cell.edges[it_index];
                    }
                }
            case .MERGE;
                for * result_cell.edges {
                    if stamp_cell.edges[it_index] == .EMPTY {
                        <<it = .EMPTY;
                    }
                    else if <<it != .EMPTY && <<it < stamp_cell.edges[it_index] {
                        <<it = stamp_cell.edges[it_index];
                    }
                }

                if result_cell.room == .EMPTY {
                    for * result_cell.edges {
                        if <<it < stamp_cell.edges[it_index] {
                            <<it = stamp_cell.edges[it_index];
                        }
                    }
                }
            case .INTERIOR;
                for * result_cell.edges {
                    if stamp_cell.edges[it_index] == .EMPTY {
                        <<it = .EMPTY;
                    }
                    else if <<it != .EMPTY && <<it < stamp_cell.edges[it_index] {
                        <<it = stamp_cell.edges[it_index];
                    }
                    if <<it == .EMPTY {
                        <<it = stamp_cell.edges[it_index];
                    }
                }
        }

        // check neighbors for doors, if so remove wall
        for * result_cell.edges {
            in_bounds, neighbor := get_neighbor(cell_x, cell_y, cast(Direction) it_index);
            if in_bounds {
                if neighbor.edges[opposite(it_index)] == .DOOR {
                    <<it = .EMPTY;
                }
            }
        }

        // update room
        result_cell.room = stamp_cell.room;

        array_add(*result, result_cell);
    }
    return result;
}

get_nearest_edge :: (x: int, y: int) -> Direction {
    // find the nearest edge for the cell containing the mouse
    cell_center := get_cell_position(x, y) + CELL_SIZE/2.0;
    edges: [4] Vector2;
    edges[0] = cell_center - xy(0, CELL_WIDTH/2.0); // North
    edges[1] = cell_center + xy(CELL_WIDTH/2.0, 0); // East
    edges[2] = cell_center + xy(0, CELL_WIDTH/2.0); // South
    edges[3] = cell_center - xy(CELL_WIDTH/2.0, 0); // West
    min_dist: float = distance(input.mouse_position, edges[0]);
    min_index: int;
    for edges {
        dist := distance(input.mouse_position, it);
        if dist < min_dist {
            min_dist = dist;
            min_index = it_index;
        }
    }
    return cast(Direction) min_index;
}

fully_connected :: () -> bool {
    using game;
    checked: [GRID_HEIGHT][GRID_WIDTH] bool;
    coord :: struct {x: int; y: int;};
    unsearched: [..] coord;

    // find the first non-empty cell
    for row: grid {
        for cell: row {
            if cell.room != .EMPTY {
                c: coord;
                c.x = cell.x;
                c.y = cell.y;
                array_add(*unsearched, c);
                break row;
            }
        }
    }

    while unsearched.count > 0 {
        searching := pop(*unsearched);
        x, y := searching.x, searching.y;

        if grid[y][x].room != .EMPTY {
            checked[y][x] = true;
            
            for grid[y][x].edges {
                dir := direction_to_offset(cast(Direction) it_index);
                neighbor_x := x + (cast(int) dir.x);
                neighbor_y := y + (cast(int) dir.y);

                if neighbor_x < 0 && neighbor_x >= GRID_WIDTH 
                && neighbor_y < 0 && neighbor_y >= GRID_HEIGHT then continue;

                if checked[neighbor_y][neighbor_x] 
                || grid[neighbor_y][neighbor_x].room == .EMPTY
                    then continue;

                n: coord;
                n.x = neighbor_x;
                n.y = neighbor_y;
                if it == .EMPTY || it == .DOOR then array_add(*unsearched, n);
            }
        }
    }

    for y: 0..GRID_HEIGHT-1 {
        for x: 0..GRID_WIDTH-1 {
            if grid[y][x].room != .EMPTY && checked[y][x] == false
                then return false;
        }
    }
    return true;
}

check_level_success :: (force_success: bool = false) {
    level_end := game.deck.count == 0 && game.count_hand() == 0;
    win := false;
    if level_end then win = fully_connected();

    if force_success || level_end {
        game.state = .LEVEL_COMPLETION;
        game.level_has_focus = false;
        game.highlighted_card = -1;

        if force_success || win {
            game.win = true;
        }
    }

    // only grow in the final turns (should be evenly spaced?)
    if game.count_hand() == 0 {
        phase := game.level.width.count - (game.deck.count / (game.level.width.count - 1));
        if game.map_phase < phase then grow_map();
    }
}

load_level :: (index: int) {
    using game;
    win = false;
    state = .LEVEL;
    level_index = index;

    if index == Level_Sequence.count {
        print("YOU BEAT ALL % LEVELS!\n", Level_Sequence.count);
        // game.state = .LEVEL_SELECT;
        game_reset();
        return;
    }

    level_has_focus = true;
    level = Level_Sequence[index];
    init(*level, index);
    current_level_width  = level.width[0];
    current_level_height = level.height[0];

    print("LOADING LEVEL %\n", index+1);

    map_phase = 0;
    map_size.x = 1 + level.width[0] * CELL_WIDTH + level.width[0];
    map_size.y = 1 + level.height[0] * CELL_WIDTH + level.height[0];
    map_top_left = xy(1,1) + GRID_SIZE/2 - xy(map_size.x, map_size.y)/2.0;

    for context.entity_storage._Card {
        despawn(it);
    }
    for context.entity_storage._Item {
        despawn(it);
    }
    phase = .ROOM_PLACEMENT;
    intended_cursor = .CROSSHAIR;
    highlighted_card = -1;
    is_first_placement = true;

    shuffle: [..] Card;
    for level.cards array_add(*shuffle, it);
    for player_deck array_add(*shuffle, it);
    fisher_yates_shuffle(*shuffle);
    for shuffle {
        init(*it);
        array_add(*deck, spawn(it));
    }

    // init grid
    for * row, y: grid {
        for * cell, x: <<row {
            (<<cell).x = x;
            (<<cell).y = y;
            (<<cell).room = .EMPTY;
            for * cell.edges { <<it = .EMPTY; }
        }
    }

    for level.starting_cells {
        grid[it.y][it.x] = it;
    }

    for level.starting_items {
        spawn(it);
    }
}

rotate_stamp :: (cells: [] Card_Cell, counter_clockwise: bool) {

}