extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

static func create_2d_array(width, height, value=null):
    var a = []

    a.resize(width)
    for x in range(width):
        a[x] = []
        a[x].resize(height)

        if value != null:
            for y in range(height):
                a[x][y] = value

    return a

func create_random_id():
	randomize()
	var tempInt=randi()%8999+1000
	return tempInt
	pass
	
