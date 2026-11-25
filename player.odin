package main

import rl "vendor:raylib"

PlayerMovementData :: struct
{
	position : [2]f32,
	direction :[2]f32,
	speed : f32,
}

PlayerSpriteData :: struct
{
	size : [2]f32,
	offset : [2]f32,
	color: rl.Color,
}

player_move : PlayerMovementData
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

update_player_movement :: proc()
{
	player_move.direction = player_input.input_movement

	velocity : [2]f32 = player_move.direction * player_move.speed
	new_position :  [2]f32 = player_move.position + (velocity * delta_time)

	player_move.position += (velocity * delta_time)

	player_move.position.x = clamp(player_move.position.x , f32(get_game_position().x) + player_sprite.offset.x, f32((get_game_size().x +get_game_position().x)) -  player_sprite.offset.x )
	player_move.position.y = clamp(player_move.position.y , f32(get_game_position().y) + player_sprite.offset.y, f32((get_game_size().y +get_game_position().y)) -  player_sprite.offset.y )
}

draw_player :: proc()
{
	draw_position :  [2] f32 = player_move.position - player_sprite.offset
	rl.DrawRectangleV(draw_position ,player_sprite.size,player_sprite.color)
	rl.DrawPixelV(player_move.position, rl.GREEN)
}
