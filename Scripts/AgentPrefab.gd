extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var type=""
var subType=""
var spriteColor=Color(0,0,0,255)
var spriteColorDefault=Color(0,0,0,255)
var spriteAtlas
var spriteAtlasRegion=Vector2()
var spriteResource
var gridPosition=Vector2()
var condition=0
var readyToStart=0
var spriteSize=0
var gridSize=0
var spriteScale=0
var currentSpriteSheetName=""
var gridScaleRatio
var agentName=""
var currentState={}

var stepEnabled=false

#subtype specific vars
	#human
var data= {
	"stats":{
		"survival":{
			"hunger":{
				"baseAmount":100,
				"emptyThreshold":20,
				"fullThreshhold":100
			},
			"thirst":{
				"baseAmount":100,
				"emptyThreshold":20,
				"fullThreshhold":100
			}
		}
	}
}

onready var mainNode=get_tree().get_root().get_child(0)
onready var worldManager=mainNode.find_node("WorldManager")
onready var agentManager=mainNode.find_node("AgentMaster")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	visible=false
	set_process(true)
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if readyToStart==1:
		gridScaleRatio=worldManager.gridScaleRatio
		spriteSize=worldManager.originalGridSize
		gridSize=worldManager.gridSize
		spriteScale=gridSize/spriteSize
		currentSpriteSheetName=worldManager.currentSpriteSheetName
		spriteAtlasRegion.x*=worldManager.originalGridSize
		spriteAtlasRegion.y*=worldManager.originalGridSize
		var spriteAtlasCopy=worldManager.currentSpriteSheetAtlas.duplicate()
		spriteAtlas=AtlasTexture.new()
		spriteAtlas.atlas=spriteAtlasCopy.atlas
		spriteAtlas.region=Rect2(spriteAtlasRegion,Vector2(worldManager.originalGridSize,worldManager.originalGridSize))
		spriteResource=spriteAtlas
		texture=spriteResource
		self_modulate=spriteColor
		scale=Vector2(spriteScale,spriteScale)
		visible=true
		worldManager.connect("worldStep", self, "OnWorldStep")
		
		name=String(gridPosition.x)+","+String(gridPosition.y)+"-"+type+"_"+subType
		
		#end
		readyToStart=2
		pass
	elif readyToStart==2:
		if stepEnabled:
#			CheckSurvival()
			pass
		pass
	pass
	
func OnWorldStep():
	if stepEnabled!=true:
		stepEnabled=true
	pass
	
func CheckSurvival():
	for stats in data["stats"]["survival"].keys():
		var statCurrent=data["stats"]["survival"][stats]["baseAmount"]
		var statEmpty=data["stats"]["survival"][stats]["emptyThreshold"]
		var statFull=data["stats"]["survival"][stats]["fullThreshold"]
		if statCurrent<=statEmpty:
			currentState={"consume":stats}
			pass
		pass
	pass
	
func RunState():
	if currentState.size()!=0:
		match currentState:
			"consume":
				match currentState["consume"]:
					"hunger":
						
						pass
					"thirst":
						tileChecks=CheckForResource("water")
						if tileChecks.size()>0:
							checkList=GetNearest(tileChecks)
							if agentManager.jobs.size()==0:
								
								pass
							else:
								for x in checkedDistances.size()-1:
									
									pass
							pass
#						var previousCheck=null
#						var previousDistance=null
#						var nearestCheck=null
#						var nearestDistance=null
#						for check in tileChecks.size():
#							var checkDistance=GetDistance(gridPosition.x,gridPosition.y,check.x,check.y)
#							if previousCheck==null:
#								previousCheck=check
#								previousDistance=checkDistance
#								nearestCheck=currentCheck
#								nearestDistance=checkDistance
#							else:
#								if checkDistance<nearestDistance:
#									nearestCheck=check
#									nearestDistance=checkDistance
#									pass
#								previousCheck=check
#								previousDistance=checkDistance
#								pass
#							pass
#						pass
				pass
		pass
	pass
	
func GetDistance(x1,y1,x2,y2):
	return sqrt(pow(x2-x1,2)+pow(y2-y1,2)*1.0)
	pass
	

func GetNearest(tileChecks):
	var previousCheck=null
	var previousDistance=null
	var nearestCheck=null
	var nearestDistance=null
	var distances=[]
	var checkedTiles=[]
	for check in tileChecks.size():
		var checkedDistances=GetDistance(gridPosition.x,gridPosition.y,check.x,check.y)
		distances.append(checkDistance)
		checkedTiles.append(check)
#		if previousCheck==null:
#			previousCheck=check
#			previousDistance=checkDistance
#			nearestCheck=currentCheck
#			nearestDistance=checkDistance
#		else:
#			if checkDistance<nearestDistance:
#				nearestCheck=check
#				nearestDistance=checkDistance
#				pass
#			previousCheck=check
#			previousDistance=checkDistance
#			pass
		pass
	pass
	distances.sort()
	return distances

func CheckForResource(type):
	var checks=[]
	for z in worldManager.worldArray.size()-1:
		for y in worldManager.worldHeight-1:
			for x in worldManager.worldWidth-1:
				if worldManager.worldArray[z][x][y]==type:
					checks.append(Vector2(x,y))
					pass
				pass
			pass
	return checks
	pass