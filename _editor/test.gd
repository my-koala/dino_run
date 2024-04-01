@tool
extends EditorScript

func _run() -> void:
	var foo: float = -0.49
	print(fmod(foo, 1.0))
	
	return
	
	print(9223372036854775807 + 1)
	print(9223372036854775807 + 2)
	print(9223372036854775807 + 3)
	print(9223372036854775807 + 4)
	
	return
	print(":::")
	var fnl: FastNoiseLite = FastNoiseLite.new()
	fnl.noise_type = FastNoiseLite.TYPE_SIMPLEX
	fnl.frequency = 1.0
	fnl.fractal_type = FastNoiseLite.FRACTAL_NONE
	fnl.seed = hash("foobar")
	print(fnl.get_noise_1d(float(340282346638528859811704183484538.0)))
	print(fnl.get_noise_1d(float(340282346638528859811704183484539.0)))
	
	print(":::")
	
