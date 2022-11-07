Level :: struct {
    width: int;
    height: int;
    deck: [..] Room_Prototype;
    starting_rooms: [..] Room;
}

Level_Sequence: [4] Level = .[
    Levels.TUTORIAL_1,
    Levels.TUTORIAL_2,
    Levels.TUTORIAL_3,
    Levels.TUTORIAL_4,
];

// Archetypes -----------------------------------------------------------------------
Levels: struct {
    TUTORIAL_1 :: Level.{
        width=5,
        height=5,
        starting_rooms= .[
            .{room_prototype=Rooms.R22, is_placed=true, cell_coord=.{1, 1}},
        ],
    };
    TUTORIAL_2 :: Level.{
        width=10,
        height=10,
        starting_rooms= .[
            .{room_prototype=Rooms.R41, is_placed=true, cell_coord=.{3, 3}},
        ],
    };
    TUTORIAL_3 :: Level.{
        width=12,
        height=3,
        starting_rooms= .[
            .{room_prototype=Rooms.R12, is_placed=true, cell_coord=.{2, 1}},
        ],
    };
    TUTORIAL_4 :: Level.{
        width=30,
        height=30,
        starting_rooms= .[
            .{room_prototype=Rooms.R12, is_placed=true, cell_coord=.{2, 1}},
        ],
    };
}

// Decks --------------------------------------------------------------------------
Decks: [][] Room_Prototype = .[
    .[// TUTORIAL_1
        Rooms.R11,
        Rooms.R11,

        Rooms.R21,
        Rooms.R21,

        Rooms.R41,
        Rooms.R41,

        Rooms.R51,
    ],
    .[// TUTORIAL_2
        Rooms.R33,
        Rooms.R33,
        Rooms.R33,
        Rooms.R44,
        Rooms.R44,
        Rooms.R55,
    ],
    .[// TUTORIAL_3
        Rooms.R11,
        Rooms.R11,

        Rooms.R12,
        Rooms.R12,
        Rooms.R12,
        Rooms.R13,
        Rooms.R13,

        Rooms.R21,
        Rooms.R21,
        Rooms.R41,
        Rooms.R41,
        Rooms.R51,
        Rooms.R51,
    ],
    .[// TUTORIAL_4
        Rooms.R11,
        Rooms.R11,

        Rooms.R12,
        Rooms.R12,
        Rooms.R12,
        Rooms.R13,
        Rooms.R13,

        Rooms.R21,
        Rooms.R21,
        Rooms.R41,
        Rooms.R41,
        Rooms.R51,
        Rooms.R51,
    ]
];

simulate_level :: () {
    using game;

    if level.starting_rooms.count > 0 then is_first_placement = false;

    if input.clicked {
        reset_highlight := true;

        // map clicked
        if is_mouse_over(MAP_TOP_LEFT, map_size) {
            if door_placement {
                cell_x, cell_y := get_cell_index(input.mouse_position);
                print("door attempted: %, %\n", cell_x, cell_y);
                room, gone := from_handle(door_ghost.room);
                if !gone {
                    print("room exists\n");
                    is_valid_cell := false;
                    for i: 0..room.width-1 {
                        for j: 0..room.height-1 {
                            x := room.cell_coord.x + i;
                            y := room.cell_coord.y + j;
                            print("room: (%, %)\n", x, y);
                            if cell_x == x && cell_y == y {
                                print("is_valid_cell = true\n");
                                is_valid_cell = true;
                                break i;
                            }
                        }
                    }

                    if is_valid_cell {
                        cell_center := get_cell_position(cell_x, cell_y) + CELL_SIZE/2.0;
                        door: Door;
                        door.cell_coord.x = cell_x;
                        door.cell_coord.y = cell_y;

                        faces: [4] Vector2;
                        faces[0] = cell_center - xy(0, CELL_WIDTH/2.0); // North
                        faces[1] = cell_center + xy(CELL_WIDTH/2.0, 0); // East
                        faces[2] = cell_center + xy(0, CELL_WIDTH/2.0); // South
                        faces[3] = cell_center - xy(CELL_WIDTH/2.0, 0); // West
                        min_dist: float = distance(input.mouse_position, faces[0]);
                        min_index: int;
                        for faces {
                            dist := distance(input.mouse_position, it);
                            if dist < min_dist {
                                min_dist = dist;
                                min_index = it_index;
                            }
                        }
                        if min_index == {
                            case 0; door.facing = .NORTH;
                            case 1; door.facing = .EAST;
                            case 2; door.facing = .SOUTH;
                            case 3; door.facing = .WEST;
                        }
                        
                        spawn(door);
                        door_placement = false;

                        intended_cursor = .CROSSHAIR;
                        is_first_placement = false;
                        check_level_success();
                    }
                }
            }
            else if highlighted_card > -1 {
                room := hand[highlighted_card].room;
                cell_x, cell_y := get_cell_index(input.mouse_position);
                room.cell_coord.x = cell_x;
                room.cell_coord.y = cell_y;

                if is_valid_placement(cell_x, cell_y, room) {
                    room.position = get_cell_position(cell_x, cell_y);
                    room.is_placed = true;
                    room.cell_coord.x = cell_x;
                    room.cell_coord.y = cell_y;
                    door_ghost.room = spawn(room);

                    if !is_first_placement then door_placement = true;
                }
                else reset_highlight = false;

                hand[highlighted_card].exists = false;
            }
        }
        
        // hand clicked
        if is_mouse_over(HAND_POS[0], CARD_SIZE) && hand[0].exists {
            reset_highlight = highlighted_card == 0;
            highlighted_card = 0;
        }
        if is_mouse_over(HAND_POS[1], CARD_SIZE) && hand[1].exists {
            reset_highlight = highlighted_card == 1;
            highlighted_card = 1;
        }
        if is_mouse_over(HAND_POS[2], CARD_SIZE) && hand[2].exists {
            reset_highlight = highlighted_card == 2;
            highlighted_card = 2;
        }

        // deck clicked
        if is_mouse_over(DECK_POS, CARD_SIZE) {
            hand_count := count_hand();
            if level.deck.count > 0 && hand_count < 3 {
                open_slots := (3 - hand_count) - 1;
                for i: 0..open_slots {
                    room: Room;
                    room.room_prototype = pop(*level.deck);
                    index := first_empty_index(hand); // @@@: check -1?
                    hand[index].room = room;
                    hand[index].exists = true;
                    if level.deck.count == 0 break;
                }
            }
        }
        
        if reset_highlight {
            highlighted_card = -1;
            intended_cursor = .CROSSHAIR;
        }
    }

    if is_mouse_over(MAP_TOP_LEFT, map_size) {
        if door_placement {
            cell_x, cell_y := get_cell_index(input.mouse_position);
            room, gone := from_handle(door_ghost.room);
            if !gone {
                is_valid_cell := false;
                for i: 0..room.width-1 {
                    for j: 0..room.height-1 {
                        x := room.cell_coord.x + i;
                        y := room.cell_coord.y + j;
                        if cell_x == x && cell_y == y {
                            is_valid_cell = true;
                            break i;
                        }
                    }
                }

                if is_valid_cell {
                    cell_center := get_cell_position(cell_x, cell_y) + CELL_SIZE/2.0;
                    position: Vector2;
                    faces: [4] Vector2;
                    faces[0] = cell_center - xy(HORIZ_DOOR_SIZE.x/2, CELL_WIDTH/2.0); // North
                    faces[1] = cell_center + xy(CELL_WIDTH/2.0, -VERT_DOOR_SIZE.y/2); // East
                    faces[2] = cell_center + xy(-HORIZ_DOOR_SIZE.x/2, CELL_WIDTH/2.0); // South
                    faces[3] = cell_center - xy(CELL_WIDTH/2.0, -VERT_DOOR_SIZE.y/2); // West
                    min_dist: float = distance(input.mouse_position, faces[0]);
                    min_index: int;
                    for faces {
                        dist := distance(input.mouse_position, it);
                        if dist < min_dist {
                            min_dist = dist;
                            min_index = it_index;
                        }
                    }
                    door_ghost.position = faces[min_index];
                    door_ghost.size = ifx min_index == 0 || min_index == 2 then HORIZ_DOOR_SIZE else VERT_DOOR_SIZE;
                }
            }
        }
    }

    // @Note: apparently setting the cursor is jank and shouldn't be 
    //        done in a game loop, to get around this I use a flag
    if game.intended_cursor != game.mouse_cursor {
        SetMouseCursor(xx game.intended_cursor);
        game.mouse_cursor = game.intended_cursor;
    }
}

render_level :: () {
    using game;
    using context.entity_storage;

    //
    // draw background grid
    //
    for i: 0..GRID_WIDTH-1 {
        for j: 0..GRID_HEIGHT-1 {
            pos := xy(1 + i * CELL_WIDTH + i, 2 + j * CELL_WIDTH + j);
            color := ifx i == GRID_WIDTH/2 || j == 31 then WHITE else DARKGRAY;
            DrawRectangleV(pos, CELL_SIZE, color);
        }
    }

    //
    // draw map
    //
    {
        using game.level;
        cell_offset :: 3;
        pixel_offset :: cell_offset * CELL_WIDTH + 3;
        for i: 0..width-1 {
            for j: 0..height-1 {
                pos := xy(1 + pixel_offset + i * CELL_WIDTH + i, 2 + pixel_offset + j * CELL_WIDTH + j);
                DrawRectangleV(pos, CELL_SIZE, GRAY);
            }
        }
    }

    if state == .LEVEL then draw_level_sidebar();

    for _Room render(it);
    for _Door render(it);
    if door_placement DrawRectangleV(door_ghost.position, door_ghost.size, .{0, 0, 255, 100});

    if state == .LEVEL then DrawTextEx(Fonts.bahnschrift, "Press 'R' to restart level", xy(SIDEBAR_LEFT + 50, WINDOW_HEIGHT - 50), 24, 1, WHITE);
}

check_level_success :: (force_success: bool = false) {
    beat_level := game.level.deck.count == 0 && game.count_hand() == 0;
    if force_success || beat_level {
        game.state = .LEVEL_COMPLETION;
        game.level_has_focus = false;
        game.highlighted_card = -1;
    }
}

// @@@: rework this, eg: hand should maybe be separate struct from game
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
    map_size.x = 1 + level.width * CELL_WIDTH + level.width;
    map_size.y = 2 + level.height * CELL_WIDTH + level.height;
    for context.entity_storage._Room {
        despawn(it);
    }
    for context.entity_storage._Door {
        despawn(it);
    }
    door_placement = false;
    intended_cursor = .CROSSHAIR;
    highlighted_card = -1;
    is_first_placement = true;
    for * hand it.exists = false;

    // clean this up at some point
    indices: [..] int;
    for Decks[index] {
        array_add(*indices, it_index);
    }
    for shuffle(indices) {
        array_add(*level.deck, Decks[index][it]);
    }

    for level.starting_rooms {
        room := it;
        room.position = get_cell_position(it.cell_coord.x, it.cell_coord.y);
        spawn(room);
    }
}

draw_level_sidebar :: () {
    using game;
    
    //
    // draw deck
    //
    {
        using game.level;

        DrawTextEx(Fonts.bahnschrift, "Deck", DECK_POS - xy(0, 50), 32, 1, WHITE);

        color := DARKGRAY;
        if deck.count > 0 {
            if level_has_focus && is_mouse_over(DECK_POS, CARD_SIZE) then color = WHITE;
            else color = LIGHTGRAY;
        }
        DrawRectangleV(DECK_POS, xy(185, 250), color);
    }

    //
    // draw hand
    //
    {
        DrawTextEx(Fonts.bahnschrift, "Hand", HAND_POS[0] - xy(0, 50), 32, 1, WHITE);
    
        color0 := DARKGRAY;
        if hand[0].exists {
            color0 = LIGHTGRAY;
            if level_has_focus && is_mouse_over(HAND_POS[0], CARD_SIZE) then color0 = WHITE;
        }

        color1 := DARKGRAY;
        if hand[1].exists {
            color1 = LIGHTGRAY;
            if level_has_focus && is_mouse_over(HAND_POS[1], CARD_SIZE) then color1 = WHITE;
        }

        color2 := DARKGRAY;
        if hand[2].exists  {
            color2 = LIGHTGRAY;
            if level_has_focus && is_mouse_over(HAND_POS[2], CARD_SIZE) then color2 = WHITE;
        }

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
        if hand[0].exists {
            card_center := HAND_POS[0] + CARD_SIZE/2.0;
            room := hand[0].room;
            room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
            draw_room_representation(room, card_center - room_size/2.0, 255);
        }
        if hand[1].exists {
            card_center := HAND_POS[1] + CARD_SIZE/2.0;
            room := hand[1].room;
            room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
            draw_room_representation(room, card_center - room_size/2.0, 255);
        }
        if hand[2].exists {
            card_center := HAND_POS[2] + CARD_SIZE/2.0;
            room := hand[2].room;
            room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
            draw_room_representation(room, card_center - room_size/2.0, 255);
        }
    }

    if highlighted_card > -1 {
        if input.mouse_position.x <= SIDEBAR_LEFT {
            draw_room_ghost(*hand[highlighted_card].room, input.mouse_position);
        } else {
            intended_cursor = .CROSSHAIR;
        }
    }
}