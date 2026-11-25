package main

import rl "vendor:raylib"
import "core:fmt"

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

PlayerShootData :: struct
{
	shoot_offset : [2]f32,
	can_shoot : bool,
	shoot_cooldown : Timer
}

Timer::struct
{
	active: bool,
	current_time : f32,
	max_time : f32,

	end_timer_delegate : proc(),
}

shoot_cooldown : Timer

player_move : PlayerMovementData
player_sprite : PlayerSpriteData
player_shoot : PlayerShootData

init_player :: proc()
{
	start_position : [2]f32  = {f32(get_game_position().x + get_game_size().x / 2.0), f32(get_game_position().y + get_game_size().y / 2.0)}
	player_speed :int = 100

	player_move.position = start_position
	player_move.speed = 250

	//input settings
	player_input.leftStickXDeadzone = 0.6
	player_input.leftStickYDeadzone = 0.6

	//sprite
	player_sprite.size = {32,32}
	player_sprite.offset = player_sprite.size / 2
	player_sprite.color = rl.RED

	//shoot cooldown
	player_shoot.shoot_cooldown.active = false
	player_shoot.shoot_cooldown.max_time = 0.5
	player_shoot.shoot_cooldown.current_time = 0.0
	player_shoot.shoot_cooldown.end_timer_delegate = end_timer_shoot_cooldown

	player_shoot.can_shoot = true
	player_shoot.shoot_offset = {0,	-32}

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


update_player::proc(dt : f32)
{
	update_timer(&player_shoot.shoot_cooldown,dt)

	update_player_movement()
	update_player_shoot()
}

update_player_shoot :: proc()
{
	if player_input.input_shoot == true
	{
		if 	player_shoot.can_shoot == true
		{
			fmt.println("player is shooting")
			bullet_test_move.position = player_move.position + player_shoot.shoot_offset
			create_bullet(bullet_player_pool[:],bullet_test_move,bullet_test_sprite)
			player_shoot.can_shoot  = false
			launch_shoot_cool_down()
		}
	}
}

launch_shoot_cool_down::proc()
{
	launch_timer(&player_shoot.shoot_cooldown)
}

launch_timer::proc(timer : ^Timer)
{
	if timer == nil
	{
		return
	}

	timer.current_time = 0.0
	timer.active = true
}

update_timer :: proc(timer : ^Timer, dt : f32)
{
	if timer == nil
	{
		return
	}

	if timer.active == false
	{
		return
	}

	timer.current_time += dt
	if timer.current_time >= timer.max_time
	{
		end_timer(timer)
	}
}

end_timer :: proc(timer : ^Timer)
{
	if timer == nil
	{
		return
	}
	timer.active = false

	if timer.end_timer_delegate == nil
	{
		return
	}

	timer.end_timer_delegate()
}

end_timer_shoot_cooldown :: proc()
{
	player_shoot.can_shoot = true
}

draw_player :: proc()
{
	draw_position :  [2] f32 = player_move.position - player_sprite.offset
	rl.DrawRectangleV(draw_position ,player_sprite.size,player_sprite.color)
	rl.DrawPixelV(player_move.position, rl.GREEN)
}
