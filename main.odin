package main

import "vendor:windows/GameInput"
import "core:fmt"

import rl "vendor:raylib"
import la "core:math/linalg"

import mu "vendor:microui"

Game :: struct
{
	window_size : [2]i32,
	game_size : [2]i32,
	position : [2]i32
}

get_game_position :: proc() -> [2]i32
{
	return game.position
}

get_game_size :: proc() -> [2]i32
{
	return game.game_size
}



game : Game

init_game::proc()
{
	game.window_size = {1920,1080}

	game_side_width :i32 = game.window_size.x / 4
	game.game_size.x = game_side_width * 2
	game.game_size.y = game.window_size.y

	game.position.x = game_side_width
	game.position.y = 0

	rl.InitWindow(game.window_size.x, game.window_size.y,"Rondache")
	rl.SetWindowMaxSize(game.window_size.x, game.window_size.y)

	rl.SetTargetFPS(60)

	//rl.SetWindowState(.WINDOW_RESIZABLE)

	rl.ToggleFullscreen()
}

exit_game :: proc()
{
	rl.CloseWindow()
}


main :: proc()
{

	init_game()

	for rl.WindowShouldClose() == false
	{

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLANK)

		//Draw Game Area
		rl.DrawRectangle(get_game_position().x,get_game_position().y,get_game_size().x,get_game_size().y, rl.BLUE)

		rl.EndDrawing()
	}

	exit_game()
}
