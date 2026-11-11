package main

import rl "vendor:raylib"
import la "core:math/linalg"
import "core:fmt"



PlayerInputData :: struct
{
	leftStickXDeadzone : f32,
	leftStickYDeadzone : f32,

	input_movement : [2]f32,
}

InputPC :: struct
{
	arrow_left : proc()->f32,
	arrow_right : proc()->f32,
	arrow_down : proc()->f32,
	arrow_up : proc()->f32,
}

InputGamepad::struct
{
	LeftStickXAxis : proc(f32)->f32,
	LeftStickYAxis: proc(f32)->f32,
}

player_input : PlayerInputData

pc_inputs : InputPC
gamepad_inputs : InputGamepad

/*PC COMMANDS*/
move_left_command::proc() -> f32
{
	return -1
}

move_right_command :: proc()->f32
{
	return 1
}

move_up_command::proc()->f32
{
	return -1
}

move_down_command::proc()->f32
{
	return 1
}

/*GAMEPAD COMMANDS*/

move_horizontal_axis_command :: proc(horizontal_axis : f32)-> f32
{
	if horizontal_axis > - player_input.leftStickXDeadzone && horizontal_axis < player_input.leftStickXDeadzone
    {
       	return 0.0
    }

	return horizontal_axis
}

move_vertical_axis_command :: proc(vertical_axis : f32)->f32
{
 	if vertical_axis > - player_input.leftStickYDeadzone && vertical_axis < player_input.leftStickYDeadzone
    {
       	return 0.0
    }
	return vertical_axis
}

init_input :: proc()
{
	//PC
	pc_inputs.arrow_left = move_left_command
	pc_inputs.arrow_right = move_right_command
	pc_inputs.arrow_down = move_down_command
	pc_inputs.arrow_up = move_up_command

	//Gamepad
	gamepad_inputs.LeftStickXAxis = move_horizontal_axis_command
	gamepad_inputs.LeftStickYAxis = move_vertical_axis_command

}

handle_input_movement_gamepad :: proc() -> [2]f32
{
	input :[2]f32

    if rl.IsGamepadAvailable(0) == false
    {
   		fmt.println("handle_input_movement_gamepad : Gamepad is not available")
    	return input
    }

    if gamepad_inputs.LeftStickXAxis == nil
    {
    	fmt.println("handle_input_movement_gamepad : Error LeftStickXAxis not bind")
    	return input
    }

    if gamepad_inputs.LeftStickYAxis == nil
    {
   		fmt.println("handle_input_movement_gamepad : Error LeftStickYAxis not bind")
    	return input
    }

    leftStickX : f32
    leftStickY : f32

    leftStickX = rl.GetGamepadAxisMovement(0, .LEFT_X);
    leftStickY = rl.GetGamepadAxisMovement(0, .LEFT_Y)

    input.x = gamepad_inputs.LeftStickXAxis(leftStickX)
    input.y = gamepad_inputs.LeftStickYAxis(leftStickY)

	return la.normalize0(input)
}

handle_input_movement :: proc() -> [2]f32
{
	player_input.input_movement = {0,0}

    input :[2]f32

    input = handle_input_movement_gamepad()

    if rl.IsKeyDown(.UP)
    {
    	if pc_inputs.arrow_up == nil
     	{
	   		fmt.println("handle_input_movement : Error Arrow_UP not bind")
     		return {0,0}
     	}

    	input.y = pc_inputs.arrow_up()
    }

    if rl.IsKeyDown(.DOWN)
    {
   		if pc_inputs.arrow_down == nil
    	{
	   		fmt.println("handle_input_movement : Error Arrow_Down not bind")
    		return {0,0}
    	}
   		input.y = pc_inputs.arrow_down()
    }

    if rl.IsKeyDown(.LEFT)
    {
	   	if pc_inputs.arrow_left == nil
	   	{
		   	fmt.println("handle_input_movement : Error Arrow_Left not bind")
	   		return {0,0}
	   	}
  		input.x = pc_inputs.arrow_left()
    }

    if rl.IsKeyDown(.RIGHT)
    {
   		if pc_inputs.arrow_right == nil
	   	{
		   	fmt.println("handle_input_movement : Error Arrow_Right not bind")
	   		return {0,0}
	   	}
  		input.x = pc_inputs.arrow_right()
    }

    return la.normalize0(input)

}

handle_input :: proc()
{
	player_input.input_movement = handle_input_movement()
}
