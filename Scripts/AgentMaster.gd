extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var selfStep=false
var agentList=[]
var movementRegistry=[]
var agentsToSpawn=4
var mainNode

func _ready():
	mainNode=get_tree().get_root().get_child(0)
#	while agentsToSpawn>0:
#		var newAgent=agentPrefab.instance()
#		newAgent.name="Agent"+String(mainNode.create_random_id())
#		add_child(newAgent)
#		agentsToSpawn-=1
#	pass
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
#	if selfStep:
#		if movementRegistry.size()>0:
#			movementRegistry.clear()
#			pass
#		#end
#		selfStep=false
#		pass
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass




func _on_WorldManager_worldStep():
#	if selfStep==false:
#		selfStep=true
	pass # replace with function body
