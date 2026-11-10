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
	position : [2]i32,
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

delta_time : f32

init_game_window :: proc()
{

	game.window_size = {1280,720}

	set_game_window_size()

	rl.SetConfigFlags({.WINDOW_RESIZABLE, .BORDERLESS_WINDOWED_MODE})

	rl.InitWindow(game.window_size.x, game.window_size.y,"Rondache")
	rl.SetWindowMaxSize(1920, 1080)
	rl.SetWindowMinSize(720, 480)

	rl.SetTargetFPS(60)


	//rl.ToggleFullscreen()
}


set_game_window_size :: proc()
{
	game_side_width :i32 = game.window_size.x / 4
	game.game_size.x = game_side_width * 2
	game.game_size.y = game.window_size.y

	game.position.x = game_side_width
	game.position.y = 0
}
update_game_window ::proc()
{

	//Window resize
	if rl.IsWindowResized() == true
	{
		game.window_size = {rl.GetScreenWidth(), rl.GetScreenHeight()}
		set_game_window_size()
		player_move.position = {f32(get_game_position().x + get_game_size().x / 2.0), f32(get_game_position().y + get_game_size().y / 2.0)}
	}

	if rl.IsKeyPressed(.F11) == true
	{
		game.window_size = {1920, 1080}
		rl.ToggleFullscreen()
		set_game_window_size()
		player_move.position = {f32(get_game_position().x + get_game_size().x / 2.0), f32(get_game_position().y + get_game_size().y / 2.0)}
	}

}

PlayerMovementData :: struct
{
	position : [2]f32,
	direction :[2]f32,
	speed : f32,
}

PlayerInputData :: struct
{
	leftStickXDeadzone : f32,
	leftStickYDeadzone : f32,

	input_movement : [2]f32,
}

PlayerSpriteData :: struct
{
	size : [2]f32,
	offset : [2]f32,
	color: rl.Color,
}

player_move : PlayerMovementData
player_input : PlayerInputData
player_sprite : PlayerSpriteData

init_player :: proc()
{
	start_position : [2]f32  = {f32(get_game_position().x + get_game_size().x / 2.0), f32(get_game_position().y + get_game_size().y / 2.0)}
	player_speed :int = 100

	player_move.position = start_position
	player_move.speed = 250

	//input settings
	player_input.leftStickXDeadzone = 0.4
	player_input.leftStickYDeadzone = 0.4

	//sprite

	player_sprite.size = {32,32}
	player_sprite.offset = player_sprite.size / 2
	player_sprite.color = rl.RED
}

handle_input_movement_gamepad :: proc() -> [2]f32
{
	input :[2]f32

    //Gamepad
    if rl.IsGamepadAvailable(0) == false
    {
    	return input
    }

    leftStickX : f32
    leftStickY : f32

    leftStickX = rl.GetGamepadAxisMovement(0, .LEFT_X);
    leftStickY = rl.GetGamepadAxisMovement(0, .LEFT_Y)

    //fmt.println("GamepadAxisCount : ", rl.GetGamepadAxisMovement(0, .LEFT_X))

    if leftStickX > - player_input.leftStickXDeadzone && leftStickX < player_input.leftStickXDeadzone
    {
       	leftStickX = 0.0
    }

    if leftStickY > - player_input.leftStickYDeadzone && leftStickY < player_input.leftStickYDeadzone
    {
       	leftStickY = 0.0
    }

	input.x = leftStickX
	input.y = leftStickY

	return la.normalize0(input)
}

handle_input_movement :: proc() -> [2]f32
{

    input :[2]f32

    input = handle_input_movement_gamepad()

    if rl.IsKeyDown(.UP)
    {
        input.y = -1
    }

    if rl.IsKeyDown(.DOWN)
    {
        input.y = 1
    }

    if rl.IsKeyDown(.LEFT)
    {
        input.x = -1
    }

    if rl.IsKeyDown(.RIGHT)
    {
        input.x  = 1
    }

    return la.normalize0(input)

}

handle_input :: proc()
{
	player_move.direction = handle_input_movement()
}

update_player_movement :: proc()
{
	velocity : [2]f32 = player_move.direction * player_move.speed
	new_position :  [2]f32 = player_move.position + (velocity * delta_time)

	player_move.position += (velocity * delta_time)


	player_move.position.x = clamp(player_move.position.x , f32(get_game_position().x) + player_sprite.offset.x, f32((get_game_size().x +get_game_position().x)) -  player_sprite.offset.x )
	player_move.position.y = clamp(player_move.position.y , f32(get_game_position().y) + player_sprite.offset.y, f32((get_game_size().y +get_game_position().y)) -  player_sprite.offset.y )

}

draw_player :: proc()
{
	draw_position :  [2] f32 = player_move.position
	rl.DrawRectangleV(draw_position ,player_sprite.size,player_sprite.color)
	rl.DrawPixelV(player_move.position, rl.GREEN)
}

init_game::proc()
{
	init_game_window()
}

exit_game :: proc()
{
	rl.CloseWindow()
}


main :: proc()
{

	init_game()

	init_player()

	for rl.WindowShouldClose() == false
	{

		update_game_window()

 		delta_time = rl.GetFrameTime()

		handle_input()

		update_player_movement()

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLANK)
		//Draw Game Area
		rl.DrawRectangle(get_game_position().x,get_game_position().y,get_game_size().x,get_game_size().y, rl.BLUE)

		draw_player()


		resolution_debug : cstring =fmt.ctprintf("screen size %v \ngame area position %v\ngame area size %v ",game.window_size, game.position, game.game_size)
		rl.DrawText(resolution_debug , 0 , 10, 20,rl.WHITE)

		rl.EndDrawing()
	}

	exit_game()
}
