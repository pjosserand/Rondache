package main

import rl "vendor:raylib"
import la "core:math/linalg"
import "core:fmt"

PlayerInputData :: struct
{
	leftStickXDeadzone : f32,
	leftStickYDeadzone : f32,

	input_movement : [2]f32,
	input_shoot : bool
}

InputPC :: struct
{
	arrow_left : proc(),
	arrow_right : proc(),
	arrow_down : proc(),
	arrow_up : proc(),
}

InputGamepad::struct
{
	LeftStickXAxis : proc(f32),
	LeftStickYAxis: proc(f32),
	RightTrigger : proc(),
}

player_input : PlayerInputData

pc_inputs : InputPC
gamepad_inputs : InputGamepad

/*PC COMMANDS*/
move_left_command::proc()
{
	player_input.input_movement.x = -1
}

move_right_command :: proc()
{
	player_input.input_movement.x = 1
}

move_up_command::proc()
{
	player_input.input_movement.y = -1
}

move_down_command::proc()
{
	player_input.input_movement.y = 1
}

/*GAMEPAD COMMANDS*/

move_horizontal_axis_command :: proc(horizontal_axis : f32)
{
	new_input_horizontal : f32 = horizontal_axis

	if horizontal_axis > - player_input.leftStickXDeadzone && horizontal_axis < player_input.leftStickXDeadzone
    {
       	new_input_horizontal =  0.0
    }

    player_input.input_movement.x = new_input_horizontal
}

move_vertical_axis_command :: proc(vertical_axis : f32)
{
	new_input_vertical : f32 = vertical_axis
 	if vertical_axis > - player_input.leftStickYDeadzone && vertical_axis < player_input.leftStickYDeadzone
    {
       	new_input_vertical =  0.0
    }

	player_input.input_movement.y = new_input_vertical
}

shoot_command::proc()
{
	player_input.input_shoot = true
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
	gamepad_inputs.RightTrigger = shoot_command

}

handle_input_gamepad_left_stick_XAxis::proc()
{
	if gamepad_inputs.LeftStickXAxis == nil
    {
   		fmt.println("handle_input_gamepad_left_stick : Error LeftStickXAxis not bind")
     	return
    }

    leftStickX : f32
    leftStickX = rl.GetGamepadAxisMovement(0, .LEFT_X)

   	gamepad_inputs.LeftStickXAxis(leftStickX)
}

handle_input_gamepad_left_stick_YAxis::proc()
{
	if gamepad_inputs.LeftStickYAxis == nil
    {
  		fmt.println("handle_input_gamepad_left_stick : Error LeftStickYAxis not bind")
     	return
    }

    leftStickY : f32
    leftStickY = rl.GetGamepadAxisMovement(0, .LEFT_Y)

	gamepad_inputs.LeftStickYAxis(leftStickY)
}

handle_input_gamepad_left_stick :: proc()
{
	handle_input_gamepad_left_stick_XAxis()
	handle_input_gamepad_left_stick_YAxis()
}

handle_input_gamepad_trigger :: proc()
{
	//Right Trigger
    if rl.IsGamepadButtonDown(0,.RIGHT_TRIGGER_2)
    {
    	if gamepad_inputs.RightTrigger != nil
		{
			gamepad_inputs.RightTrigger()
		}
    }
}

handle_input_gamepad :: proc()
{

    handle_input_gamepad_left_stick()
    handle_input_gamepad_trigger()
}

handle_input_pc_zqsd :: proc()
{
	if rl.IsKeyDown(.UP)
    {
    	if pc_inputs.arrow_up == nil
     	{
      		fmt.println("handle_input_pc : Error Arrow_UP not bind")
     	}
      	pc_inputs.arrow_up()
    }

    if rl.IsKeyDown(.DOWN)
    {
   		if pc_inputs.arrow_down == nil
    	{
	   		fmt.println("handle_input_movement : Error Arrow_Down not bind")
    	}
   		pc_inputs.arrow_down()
    }

    if rl.IsKeyDown(.LEFT)
    {
	   	if pc_inputs.arrow_left == nil
	   	{
		   	fmt.println("handle_input_movement : Error Arrow_Left not bind")
	   	}
  		pc_inputs.arrow_left()
    }

    if rl.IsKeyDown(.RIGHT)
    {
   		if pc_inputs.arrow_right == nil
	   	{
		   	fmt.println("handle_input_movement : Error Arrow_Right not bind")
	   	}
  		pc_inputs.arrow_right()
    }
}

handle_input_pc::proc()
{
	handle_input_pc_zqsd()
}


handle_input :: proc()
{
	player_input.input_movement = {0,0}
	player_input.input_shoot = false

	if rl.IsGamepadAvailable(0) == true
	{
		handle_input_gamepad()
	}

	handle_input_pc()

	//End of input
	player_input.input_movement = la.normalize0(player_input.input_movement)
}
