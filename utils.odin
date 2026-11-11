package main

lerp::proc(min : f32, max :f32, t :f32) -> f32
{
	return (1.0 - t ) * min + max * t
}

inv_lerp::proc(min : f32, max : f32, value : f32) -> f32
{
	return (value - min) / (max - min)
}
