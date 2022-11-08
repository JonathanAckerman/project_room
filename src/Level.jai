Level :: struct {
    width:  [] int;
    height: [] int;
    cards:  [] Card;
    starting_cells: [] Cell;
}

#run {
    for Level_Sequence assert(it.cards.count % 3 == 0);
}

Level_Sequence: [1] Level = .[
    Levels.TUTORIAL_1,
    // Levels.TUTORIAL_2,
    // Levels.TUTORIAL_3,
    // Levels.TUTORIAL_4,
];

// Archetypes -----------------------------------------------------------------------
Levels: struct {
    TUTORIAL_1 :: Level.{
        width= .[5, 9, 15, GRID_WIDTH],
        height=.[5, 9, 15, GRID_HEIGHT],
        cards=.[
            Cards.R11,
            Cards.R11,
            Cards.R22,
            Cards.R22,
            Cards.D1,
            Cards.D1,
        ],
        starting_cells=.[
            Cell.{.{1, 1}, .BLANK_ROOM, .[.WALL, .EMPTY, .EMPTY, .WALL]},
            Cell.{.{2, 1}, .BLANK_ROOM, .[.WALL, .WALL, .EMPTY, .EMPTY]},
            Cell.{.{1, 2}, .BLANK_ROOM, .[.EMPTY, .EMPTY, .WALL, .WALL]},
            Cell.{.{2, 2}, .BLANK_ROOM, .[.EMPTY, .WALL, .WALL, .EMPTY]},

            Cell.{.{GRID_WIDTH/2, GRID_HEIGHT/2}, .BLANK_ROOM, .[.WALL, .WALL, .WALL, .WALL]},
            Cell.{.{GRID_WIDTH/2-3, GRID_HEIGHT/2-3}, .BLANK_ROOM, .[.WALL, .WALL, .WALL, .WALL]},
            Cell.{.{0, 0}, .BLANK_ROOM, .[.WALL, .WALL, .WALL, .WALL]},
        ],
    };
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
                    case .DOOR;
                        x, y := get_cell_index(input.mouse_position);
                        direction := get_nearest_edge(x, y);
                        if is_valid_door_placement(x, y, direction, card.door.width, card.door.type) {
                            grid[y][x].edges[cast(int) direction] = .DOOR;
                        }
                }
                // if is_valid_placement(card.room) {
                //     card.room.position = get_cell_position(card.room.x, card.room.y);
                //     spawn(card.room);
                //     despawn(card);
                //     if count_hand() == 0 then phase = .DOOR_PLACEMENT;
                // }
                // else reset_highlight = false;
            }
        }
        
        // hand clicked
        if is_mouse_over(HAND_POS[0], CARD_SIZE) && exists(hand[0]) {
            reset_highlight = highlighted_card == 0;
            highlighted_card = 0;
        }
        if is_mouse_over(HAND_POS[1], CARD_SIZE) && exists(hand[1]) {
            reset_highlight = highlighted_card == 1;
            highlighted_card = 1;
        }
        if is_mouse_over(HAND_POS[2], CARD_SIZE) && exists(hand[2]) {
            reset_highlight = highlighted_card == 2;
            highlighted_card = 2;
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
    for j: 0..GRID_HEIGHT-1 {
        for i: 0..GRID_WIDTH-1 {
            // out of vision
            color := Color.{10, 10, 10, 255};
            
            cell := grid[j][i];
            if is_on_map(i, j) {
                if cell.room == {
                    case .EMPTY;
                        color = GRAY;
                    case .BLANK_ROOM;
                        color = YELLOW;
                }
            }
            else if is_in_vision(i, j) {
                if cell.room == {
                    case .EMPTY;
                        color = DARKGRAY;
                    case .BLANK_ROOM;
                        color = YELLOW;
                        color.r -= 120;
                        color.g -= 120;
                }
            }

            pos := xy(1 + i * CELL_WIDTH + i, 1 + j * CELL_WIDTH + j);
            DrawRectangleV(pos, CELL_SIZE, color);

            for cell.edges if it == .DOOR {
                draw_door(i, j, cast(Direction) it_index);
            }
        }
    }

    if state == .LEVEL then draw_level_sidebar();

    // draw ghosts
    if highlighted_card > -1 {
        card, gone := from_handle(hand[highlighted_card]);
        if !gone {
            if card.type == {
                case .MIXED;
                case .DOOR;
                    using card.door;
                    x, y := get_cell_index(input.mouse_position);
                    pos := input.mouse_position;
                    direction := get_nearest_edge(x, y);
                    if is_valid_door_placement(x, y, direction, width, type) {
                        draw_door(x, y, direction, 100);
                        intended_cursor = .POINTING_HAND;
                    }
                    else {
                        draw_door(pos - HORIZ_DOOR_SIZE/2, 100);
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
    
        color0 := DARKGRAY;
        if exists(hand[0]) {
            color0 = LIGHTGRAY;
            if level_has_focus && is_mouse_over(HAND_POS[0], CARD_SIZE) then color0 = WHITE;
        }

        color1 := DARKGRAY;
        if exists(hand[1]) {
            color1 = LIGHTGRAY;
            if level_has_focus && is_mouse_over(HAND_POS[1], CARD_SIZE) then color1 = WHITE;
        }

        color2 := DARKGRAY;
        if exists(hand[2]) {
            color2 = LIGHTGRAY;
            if level_has_focus && is_mouse_over(HAND_POS[2], CARD_SIZE) then color2 = WHITE;
        }

        // highlighted_card outer glow
        if highlighted_card > -1 {
            r: Rectangle;
            r.x = HAND_POS[highlighted_card].x - 4;
            r.y = HAND_POS[highlighted_card].y - 4;
            r.width = CARD_WIDTH + 8;
            r.height = CARD_HEIGHT + 8;
            DrawRectangleLinesEx(r, 8.0, BLUE);
        }

        DrawRectangleV(HAND_POS[0], xy(185, 250), ifx highlighted_card == 0 then WHITE else color0);
        DrawRectangleV(HAND_POS[1], xy(185, 250), ifx highlighted_card == 1 then WHITE else color1);
        DrawRectangleV(HAND_POS[2], xy(185, 250), ifx highlighted_card == 2 then WHITE else color2);

        // @@@: Factor this to not have to check twice
        // draw room representation on card
        card, gone := from_handle(hand[0]);
        if !gone {
            card_center := HAND_POS[0] + CARD_SIZE/2.0;
            if card.type == {
                case .MIXED;
                    // room := card.room;
                    // room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
                    // draw_room_representation(room, card_center - room_size/2.0);
                case .DOOR;
                    draw_door_representation(card.door.width, card.door.type, card_center - xy(50, 15));
            }
        }
        card, gone = from_handle(hand[1]);
        if !gone {
            card_center := HAND_POS[1] + CARD_SIZE/2.0;
            if card.type == {
                case .MIXED;
                    // room := card.room;
                    // room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
                    // draw_room_representation(room, card_center - room_size/2.0);
                case .DOOR;
                    draw_door_representation(card.door.width, card.door.type, card_center - xy(50, 15));
            }
        }
        card, gone = from_handle(hand[2]);
        if !gone {
            card_center := HAND_POS[2] + CARD_SIZE/2.0;
            if card.type == {
                case .MIXED;
                    // room := card.room;
                    // room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
                    // draw_room_representation(room, card_center - room_size/2.0);
                case .DOOR;
                    draw_door_representation(card.door.width, card.door.type, card_center - xy(50, 15));
            }
        }
    }
}

draw_door_representation :: (width: int, type: Card_Door_Type, position: Vector2, opacity: u8 = 255) {
    size := xy(100, 30);
    color := BLUE;
    color.a = opacity;

    DrawRectangleV(position, size, color);
}

draw_door :: (x: int, y: int, direction: Direction, opacity: u8 = 255) {
    color := BLUE;
    color.a = opacity;
    cell_center := get_cell_position(x, y) + CELL_SIZE/2.0;
    offset := direction_to_offset(direction);
    edge := cell_center + offset * CELL_WIDTH/2;
    size          := ifx direction == .NORTH || direction == .SOUTH then HORIZ_DOOR_SIZE else VERT_DOOR_SIZE;
    gutter_offset := ifx direction == .NORTH || direction == .SOUTH then xy(2,0) else xy(0,2);
    pos := edge - size/2;
    if direction == .EAST || direction == .SOUTH then pos += offset; // aligns doors on opposite sides
    DrawRectangleV(pos, size + gutter_offset, color);
}
draw_door :: (position: Vector2, opacity: u8 = 255) {
    color := BLUE;
    color.a = opacity;
    DrawRectangleV(position, HORIZ_DOOR_SIZE, color);
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

check_level_success :: (force_success: bool = false) {
    // beat_level := game.room_deck.count == 0 && game.door_deck.count == 0 && game.count_hand() == 0;
    // if force_success || beat_level {
    //     game.state = .LEVEL_COMPLETION;
    //     game.level_has_focus = false;
    //     game.highlighted_card = -1;
    // }
}

load_level :: (index: int) {
    using game;
    state = .LEVEL;
    level_index = index;

    if index == Level_Sequence.count {
        print("YOU BEAT ALL % LEVELS!\n", Level_Sequence.count);
        game.state = .LEVEL_SELECT;
        return;
    }

    level_has_focus = true;
    level = Level_Sequence[index];
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
    phase = .ROOM_PLACEMENT;
    intended_cursor = .CROSSHAIR;
    highlighted_card = -1;
    is_first_placement = true;

    shuffle: [..] Card;
    for level.cards array_add(*shuffle, it);
    for player_deck array_add(*shuffle, it);
    fisher_yates_shuffle(*shuffle);
    for shuffle array_add(*deck, spawn(it));

    for level.starting_cells {
        grid[it.y][it.x] = it;
        // room := it;
        // room.position = get_absolute_cell_position(it.x, it.y);
        // spawn(room);
    }
}