package main

import rl "vendor:raylib"
import "core:fmt"


BulletMovementData :: struct
{
	position: [2]f32,
	direction : [2]f32,
	speed : [2]f32,
}

BulletSpriteData:: struct
{
	size : [2]f32,
	offset : [2]f32,
	color: rl.Color,
}

Bullet :: struct
{
	index : int,
	active : bool,
	movement_data : BulletMovementData,
	sprite_data : BulletSpriteData
}

bullet_test_move : BulletMovementData
bullet_test_sprite : BulletSpriteData

init_bullet_test::proc()
{
	bullet_test_sprite.size = {16,16}
	bullet_test_sprite.offset = bullet_test_sprite.size / 2
	bullet_test_sprite.color = rl.GREEN

	bullet_test_move.direction = {0,-1}
	bullet_test_move.speed = 300
}

bullet_player_pool : [500]Bullet

init_bullet_pool :: proc(bullet_pool : []Bullet)
{
	i : int = 0
	for &bullet in bullet_pool
	{
		bullet.index = i
		bullet.active = false
		i+=1
	}
}

get_bullet::proc(bullet_pool : []Bullet) -> int
{
	for &bullet in bullet_pool
	{
		if bullet.active == false
		{
			return bullet.index
		}
	}
	return -1
}

create_bullet::proc(bullet_pool : []Bullet, bullet_move_data : BulletMovementData, bullet_sprite_data: BulletSpriteData)
{
	new_bullet_index : int = get_bullet(bullet_pool)

	if new_bullet_index == -1
	{
		fmt.println("Create_bullet : no bullet found")
		return
	}

	new_bullet : ^Bullet = 	&bullet_pool[new_bullet_index]
	new_bullet.movement_data = bullet_move_data
	new_bullet.sprite_data = bullet_sprite_data

	new_bullet.active = true
}

remove_bullet::proc(bullet_pool : []Bullet, bullet_index : int )
{
	if bullet_index ==-1
	{
		return
	}

	if bullet_index >= len(bullet_pool)
	{
		return
	}

	fmt.println("Remove Bullet")

	bullet_pool[bullet_index].active = false
}


update_all_bullet_movement::proc(bullet_pool : []Bullet, dt :f32)
{
	for &bullet in bullet_pool
	{
		if bullet.active == true
		{
			bullet.movement_data.position = bullet.movement_data.position + (bullet.movement_data.direction * bullet.movement_data.speed * dt )
			if( bullet.movement_data.position.x <= f32(get_game_horizontal_boundary().x)
				|| bullet.movement_data.position.x >= f32(get_game_horizontal_boundary().y)
				|| bullet.movement_data.position.y <= f32(get_game_vertical_boundary().x)
				|| bullet.movement_data.position.y >= f32(get_game_vertical_boundary().y) )
			{
				remove_bullet(bullet_pool,bullet.index)
			}
		}
	}
}

draw_bullet::proc(bullet_pool : []Bullet)
{
	for &bullet in bullet_pool
	{
		if bullet.active == true
		{
			draw_position :  [2] f32 = bullet.movement_data.position - bullet.sprite_data.offset
			rl.DrawRectangleV(draw_position ,bullet.sprite_data.size,bullet.sprite_data.color)
			//rl.DrawPixelV(player_move.position, rl.GREEN)
		}
	}
}
