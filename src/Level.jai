Level :: struct {
    width: int;
    height: int;
    room_cards: [] Card;
    door_cards: [] Card;
    starting_rooms: [] Room; // should this be Room_Prototype?
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
        room_cards=.[
            Cards.R11,
            Cards.R11,
            Cards.R21,
            Cards.R21,
            Cards.R41,
            Cards.R41,
        ],
        door_cards=.[
            Cards.D1,
            Cards.D1,
            Cards.D1,
        ],
        starting_rooms=.[
            Room.{width=2, height=2, cell_coord=.{1, 1}},
        ],
    };
    TUTORIAL_2 :: Level.{
        width=11,
        height=11,
        room_cards=.[
            Cards.R33,
            Cards.R33,
            Cards.R33,
            Cards.R44,
            Cards.R44,
            Cards.R55,
        ],
        starting_rooms=.[
            Room.{width=4, height=1, cell_coord=.{3, 3}},
        ],
    };
    TUTORIAL_3 :: Level.{
        width=13,
        height=3,
        room_cards=.[
            Cards.R11,
            Cards.R11,
            Cards.R12,
            Cards.R12,
            Cards.R12,
            Cards.R13,
            Cards.R13,
            Cards.R21,
            Cards.R21,
            Cards.R41,
            Cards.R41,
            Cards.R51,
        ],
        starting_rooms=.[
            Room.{width=1, height=2, cell_coord=.{2, 1}},
        ],
    };
    TUTORIAL_4 :: Level.{
        width=31,
        height=31,
        room_cards=.[
            Cards.R11,
            Cards.R11,
            Cards.R12,
            Cards.R12,
            Cards.R12,
            Cards.R13,
            Cards.R13,
            Cards.R21,
            Cards.R21,
            Cards.R41,
            Cards.R41,
            Cards.R51,
        ],
        starting_rooms=.[
            Room.{width=1, height=2, cell_coord=.{2, 1}},
        ],
    };
}

simulate_level :: () {
    using game;

    if level.starting_rooms.count > 0 then is_first_placement = false;

    // deal cards
    hand_count := count_hand();
    if hand_count == 0 {
        deck: *[..] Handle(Card);
        if phase == {
            case .ROOM_PLACEMENT;
                deck = *room_deck;
            case .DOOR_PLACEMENT;
                deck = *door_deck;
        }
        if deck.count > 0 {
            for i: 0..2 {
                hand[i] = pop(deck);
            }
        }
    }

    if input.clicked {
        reset_highlight := true;
        // map clicked
        if is_mouse_over(game.map_top_left, map_size) && highlighted_card > -1 {
            if phase == {
                case .DOOR_PLACEMENT;
                    card, gone := from_handle(hand[highlighted_card]);
                    if !gone {
                        assert(card.type == .DOOR, "Card must be a door card\n");
                        if is_valid_placement(card.door) {
                            print("pos at spawn: %\n", card.door.position);
                            spawn(card.door);
                            despawn(card);
                            if count_hand() == 0 then phase = .ROOM_PLACEMENT;
                        }
                        else reset_highlight = false;
                    }
                case .ROOM_PLACEMENT;
                    card, gone := from_handle(hand[highlighted_card]);
                    if !gone {
                        assert(card.type == .ROOM, "Card must be a room card\n");
                        if is_valid_placement(card.room) {
                            card.room.position = get_cell_position(card.room.x, card.room.y);
                            spawn(card.room);
                            despawn(card);
                            if count_hand() == 0 then phase = .DOOR_PLACEMENT;
                        }
                        else reset_highlight = false;
                    }
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
}

render_level :: () {
    using game;
    using context.entity_storage;

    //
    // draw background grid
    //
    for i: 0..GRID_WIDTH-1 {
        for j: 0..GRID_HEIGHT-1 {
            pos := xy(1 + i * CELL_WIDTH + i, 1 + j * CELL_WIDTH + j);
            DrawRectangleV(pos, CELL_SIZE, DARKGRAY);
        }
    }

    //
    // draw map
    //
    {
        using game.level;
        for i: 0..width-1 {
            for j: 0..height-1 {
                pos := game.map_top_left + xy(i * CELL_WIDTH + i, j * CELL_WIDTH + j);
                DrawRectangleV(pos, CELL_SIZE, GRAY);
            }
        }
    }

    if state == .LEVEL then draw_level_sidebar();

    for _Room render(it);
    for _Door render(it);

    // draw ghosts
    if highlighted_card > -1 {
        card, gone := from_handle(hand[highlighted_card]);
        if !gone {
            if phase == {
                case .ROOM_PLACEMENT;
                    draw_room_ghost(*card.room);
                case .DOOR_PLACEMENT;
                    draw_door_ghost(*card.door);
            }
        }
    }

    if state == .LEVEL then DrawTextEx(Fonts.bahnschrift, "Press 'R' to restart level", xy(SIDEBAR_LEFT + 50, WINDOW_HEIGHT - 50), 24, 1, WHITE);
}

check_level_success :: (force_success: bool = false) {
    beat_level := game.room_deck.count == 0 && game.door_deck.count == 0 && game.count_hand() == 0;
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

    print("LOADING LEVEL %\n", index+1);
    assert(level.width <= GRID_WIDTH && level.height <= GRID_HEIGHT, "\nGrid dimensions: %,%\nMax dimensions:  %,%", GRID_WIDTH, GRID_HEIGHT, level.width, level.height);
    assert(level.width % 2 == 1 && level.height % 2 == 1, "\nSince we want to center the map on an odd size grid, the dimensions of the map should also be odd");

    map_size.x = 1 + level.width * CELL_WIDTH + level.width;
    map_size.y = 1 + level.height * CELL_WIDTH + level.height;
    map_top_left = xy(1,1) + GRID_SIZE/2 - xy(map_size.x, map_size.y)/2.0;
    for context.entity_storage._Room {
        despawn(it);
    }
    for context.entity_storage._Door {
        despawn(it);
    }
    for context.entity_storage._Card {
        despawn(it);
    }
    phase = .ROOM_PLACEMENT;
    intended_cursor = .CROSSHAIR;
    highlighted_card = -1;
    is_first_placement = true;

    deck: [..] Card;
    assert(level.room_cards.count % 3 == 0, "Level % has the wrong # of room cards\n", index+1);
    assert(player_room_deck.count % 3 == 0, "Player has the wrong # of room cards\n");
    for level.room_cards array_add(*deck, it);
    for player_room_deck array_add(*deck, it);
    fisher_yates_shuffle(*deck);
    for deck array_add(*room_deck, spawn(it));
    array_reset(*deck);
    assert(level.door_cards.count % 3 == 0, "Level % has the wrong # of door cards\n", index+1);
    assert(player_door_deck.count % 3 == 0, "Player has the wrong # of door cards\n");
    for level.door_cards array_add(*deck, it);
    for player_door_deck array_add(*deck, it);
    fisher_yates_shuffle(*deck);
    for deck array_add(*door_deck, spawn(it));

    for level.starting_rooms {
        room := it;
        room.position = get_cell_position(it.x, it.y);
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

        color := ifx room_deck.count == 0 then DARKGRAY else LIGHTGRAY;
        DrawRectangleV(DECK_POS - xy(50, 0), xy(185, 250), color);
        color = ifx door_deck.count == 0 then DARKGRAY else LIGHTGRAY;
        DrawRectangleV(DECK_POS + xy(50, 0), xy(185, 250), color);
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
                case .ROOM;
                    room := card.room;
                    room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
                    draw_room_representation(room, card_center - room_size/2.0, 255);
                case .DOOR;
            }
        }
        card, gone = from_handle(hand[1]);
        if !gone {
            card_center := HAND_POS[1] + CARD_SIZE/2.0;
            if card.type == {
                case .ROOM;
                    room := card.room;
                    room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
                    draw_room_representation(room, card_center - room_size/2.0, 255);
                case .DOOR;
            }
        }
        card, gone = from_handle(hand[2]);
        if !gone {
            card_center := HAND_POS[2] + CARD_SIZE/2.0;
            if card.type == {
                case .ROOM;
                    room := card.room;
                    room_size := xy(xx room.width * (CELL_WIDTH + 1), xx room.height * (CELL_WIDTH + 1));
                    draw_room_representation(room, card_center - room_size/2.0, 255);
                case .DOOR;
            }
        }
    }
}