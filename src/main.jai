WINDOW_WIDTH :: 1920;  //64 cells
WINDOW_HEIGHT :: 1080; //36 cells
WINDOW_CENTER :: Vector2.{WINDOW_WIDTH/2.0, WINDOW_HEIGHT/2.0};

main :: () {
    window_title := to_c_string("Project Room");
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, window_title);
    SetTargetFPS(60);
    SetExitKey(0);
    SetTraceLogLevel(xx TraceLogLevel.LOG_NONE);
    Fonts.bahnschrift = LoadFont("assets/fonts/bahnschrift.ttf");

    game.resetting = true;
    while game.resetting {
        game_reset();
        while !WindowShouldClose() && !game.resetting game_loop();
    }
    CloseWindow();
}

Fonts: struct {
    bahnschrift: Font;
}

#load "Game.jai";
#load "Entity.jai";
#load "Input.jai";
#load "Map.jai";
#load "Utils.jai";

#import "Math";
#import "Basic";

#import "Entity_Storage";
#import "Raylib-Jai";
