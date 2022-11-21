WINDOW_WIDTH :: 1920;
WINDOW_HEIGHT :: 1080;
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

exists :: (using handle: Handle($T)) -> bool {
    if id == 0 || ptr.despawning || ptr.id != id return false;
    return true;
}

Fonts: struct {
    bahnschrift: Font;
}

#load "Game.jai";
#load "Entity.jai";
#load "Input.jai";
#load "Level.jai";
#load "Level_Select.jai";
#load "Level_Completion.jai";
#load "Utils.jai";
#load "Cell.jai";

#import "Math";
#import "Basic";
#import "PCG";
#import "Sort";

#load "Priority_Queue.jai";
#import "Entity_Storage";
#import "Raylib-Jai";
