extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var mainNode
var worldArray=[]
var isWorldRunning=true
var isWorldGenerated=false
var worldWidth=32
var worldHeight=32
var gridSize=32
var gridScaleRatio=0
signal worldStep
var worldStepActivated=false
var stepTimeCurrent=0
var stepTimeMax=0.9
var entityContainer
var containerLevel0
var containerLevel1
var containerLevel2
var centerPosition=Vector2(0,0)
var startingPosition=Vector2(0,0)
var windowSize
var currentSpriteSheetAtlas=AtlasTexture.new()
var currentSpriteSheetName="Aesomatica"
var originalGridSize=16
var tileSheetWidth=16
var hasLoaded=false
var config
var gridFileDebug

#pathfinding shit, Thanks to the Godot team
onready var aStarNode = AStar.new()
var pointPath=[]
var obstacleType=!"blank"
var obstacles=[]
var halfGridSize=gridSize/2

#Prefab List:
onready var prefabResource=preload("res://Prefabs//ResourcePrefab.tscn")
onready var prefabAgent=preload("res://Prefabs//AgentPrefab.tscn")
onready var prefabArchitecture=preload("res://Prefabs//ArchitecturePrefab.tscn")

#Debug
	#SpawnPackets, will be able to select these in a GUI menu later on 
var spawnPacketDefault000={}
var spawnPacketResource={}
var spawnPacketArchitecture={}
var spawnPacketAgent={}

func _ready():
	#debug
	gridFileDebug=File.new()
	if !gridFileDebug.file_exists("res://gridFileDebug.txt"):
		gridFileDebug.open("res://gridFileDebug.txt", File.WRITE)
		gridFileDebug.close()
		pass
	#debug
	mainNode=get_tree().get_root().get_child(0)
	config=mainNode.find_node("ConfigManager")
	currentSpriteSheetAtlas.atlas=load("res://Sprites//rogueSheet_"+currentSpriteSheetName+".png")
	set_process(true)
	set_process_input(true)
	hasLoaded=false
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if !hasLoaded:
		windowSize=config.resolution
		startingPosition=Vector2(config.displayWidthOffset,config.displayHeightOffset)
		originalGridSize=currentSpriteSheetAtlas.atlas.get_width()/tileSheetWidth
		entityContainer=mainNode.find_node("EntityContainer")
		containerLevel0=entityContainer.find_node("Level0")
		containerLevel1=entityContainer.find_node("Level1")
		containerLevel2=entityContainer.find_node("Level2")
		
		gridScaleRatio=Vector2(windowSize.x/worldWidth/gridSize,windowSize.y/worldHeight/gridSize)
		#Init Spawn Packets
		spawnPacketDefault000= {
			"architecture":{
				"house":{
					"sizeAmount":{
						
					}
				},
				"ruin":{
					"sizeAmount":{
							
					}
				}
			},
			"resource":{
				"tree":{
					"amount":0,
				},
				"bush":{
					"amount":0
				}
			},
			"agent":{
				"humanoid":{
					"subtype":"neutral",
					"amount":0
				},
				"creature":{
					"subtype":"neutral",
					"amount":0
				}
			}
		}
	#	centerPosition=Vector2(get_viewport().size.x/4,get_viewport().size.y/4)
	#	startingPosition=Vector2(centerPosition.x-((worldWidth*gridSize)/2),centerPosition.y-((worldHeight*gridSize)/2))
		
		#Debug
		#Spawn Packets
		spawnPacketDefault000["resource"]["tree"]["amount"]=65
		spawnPacketDefault000["resource"]["bush"]["amount"]=5
		spawnPacketDefault000["agent"]["humanoid"]["amount"]=6
		for a in spawnPacketDefault000["agent"]["humanoid"]["amount"]:
			if spawnPacketDefault000["architecture"]["house"]["sizeAmount"].size()==0:
				var amount=spawnPacketDefault000["agent"]["humanoid"]["amount"]
				var maxArchSize=Vector2(5,5)
				var newArchSize=Vector2(int(rand_range(4,9)),int(rand_range(4,9)))
				var newArchSizeText=String(newArchSize.x)+"x"+String(newArchSize.y)
				spawnPacketDefault000["architecture"]["house"]["sizeAmount"][newArchSizeText]=1
			else:
				var amount=spawnPacketDefault000["agent"]["humanoid"]["amount"]
				var maxArchSize=Vector2(5,5)
				var newArchSize=Vector2(int(rand_range(4,9)),int(rand_range(4,9)))
				var newArchSizeText=String(newArchSize.x)+"x"+String(newArchSize.y)
				if spawnPacketDefault000["architecture"]["house"]["sizeAmount"].has(newArchSizeText):
					spawnPacketDefault000["architecture"]["house"]["sizeAmount"][newArchSizeText]+=1
					pass
				else:
					spawnPacketDefault000["architecture"]["house"]["sizeAmount"][newArchSizeText]=1
					pass
				pass
		#spawnPacketDefault000["agent"]["creature"]["amount"]=1
		#spawnPacketDefault000["architecture"]["ruin"]["sizeAmount"]["3x5"]=spawnPacketDefault000["agent"]["creature"]["amount"]
		#end
		hasLoaded=true
		pass
	if isWorldRunning:
		if isWorldGenerated==false:
			worldArray=GenerateWorldArray(worldWidth,worldHeight, false, 15).duplicate()
			GenerateBottomLevelPrefabs(worldArray)
			SpawnObjectsByPacket(spawnPacketDefault000, worldArray)
			isWorldGenerated=true
			pass
		if worldStepActivated==false:
			stepTimeCurrent+=delta
			if stepTimeCurrent>=stepTimeMax:
				worldStepActivated=true
				stepTimeCurrent=0
				pass
		else:
			emit_signal("worldStep")
#			if windowSize!=OS.window_size:
#				var newScale=ScaleGridToWindow(worldWidth, worldHeight)
#				if gridSize!=newScale:
#					windowSize=OS.window_size
#					gridSize=newScale
#				pass
#			get_tree().reload_current_scene()
			worldStepActivated=false
			pass
		pass
	pass
	
func _input(event):
	if event.is_action_released("ActionSpace"):
		get_tree().reload_current_scene()
		#RestartGameState()
		pass
	pass

func GenerateWorldArray(var w, var h, var blank=false, var waterLevel=50):
	var hasGeneratedLayer0=false
	var hasGeneratedOtherLayers=false
	var hasGeneratedLayer2=false
	var newWorldArray=[[],[],[]]
	var waterChance
	var waterStepsCurrent=0
	newWorldArray[0]=mainNode.create_2d_array(w,h)
	newWorldArray[1]=mainNode.create_2d_array(w,h,"blank")
	newWorldArray[2]=mainNode.create_2d_array(w,h,"blank")
	if blank==false:
		if !hasGeneratedLayer0:
			#Generate ground layer (water, dirt. plants, etc later on)
			var hasStartedWaterChunk=false
			var randPosX
			var randPosY
			while waterLevel>0:
				var waterTestChance
				waterChance=100-((randi() % 7)*waterStepsCurrent)
				if waterChance>0:
					waterTestChance=randi() % waterChance
				else:
					waterTestChance=0
				if waterTestChance>0:
					if hasStartedWaterChunk==false:
						randomize()
						randPosX=randi() % w-1
						randomize()
						randPosY=randi() % h-1
						while newWorldArray[0][randPosX][randPosY]=="water":
							randomize()
							randPosX=randi() % w-1
							randomize()
							randPosY=randi() % h-1
						newWorldArray[0][randPosX][randPosY]="water"
						hasStartedWaterChunk=true
					#Check if water can be placed in chosen random direction
					if randPosY==0:
						if randPosX==0:
							randomize()
							var randDir=randi() % 1
							if randDir==0:
								if newWorldArray[0][randPosX+1][randPosY]!="water":
									newWorldArray[0][randPosX+1][randPosY]="water"
									randPosX=randPosX+1
									waterStepsCurrent+=1
								pass
							else:
								if newWorldArray[0][randPosX][randPosY+1]!="water":
									newWorldArray[0][randPosX][randPosY+1]="water"
									randPosY=randPosY+1
									waterStepsCurrent+=1
								pass
							pass
						elif randPosX>0 && randPosX<w-1:
							randomize()
							var randDir=randi() % 3
							if randDir==0:
								if newWorldArray[0][randPosX+1][randPosY]!="water":
									newWorldArray[0][randPosX+1][randPosY]="water"
									randPosX=randPosX+1
									waterStepsCurrent+=1
								pass
							elif randDir==1:
								if newWorldArray[0][randPosX][randPosY+1]!="water":
									newWorldArray[0][randPosX][randPosY+1]="water"
									randPosY=randPosY+1
									waterStepsCurrent+=1
								pass
							elif randDir==2:
								if newWorldArray[0][randPosX-1][randPosY]!="water":
									newWorldArray[0][randPosX-1][randPosY]="water"
									randPosX=randPosX-1
									waterStepsCurrent+=1
								pass
							pass
						elif randPosX==w-1:
							randomize()
							var randDir=randi() % 1
							if randDir==0:
								if newWorldArray[0][randPosX-1][randPosY]!="water":
									newWorldArray[0][randPosX-1][randPosY]="water"
									randPosX=randPosX-1
									waterStepsCurrent+=1
								pass
							else:
								if newWorldArray[0][randPosX][randPosY+1]!="water":
									newWorldArray[0][randPosX][randPosY+1]="water"
									randPosY=randPosY+1
									waterStepsCurrent+=1
								pass
							pass
						pass
					elif randPosY>0 && randPosY<h-1:
						if randPosX==0:
							randomize()
							var randDir=randi() % 2
							if randDir==0:
								if newWorldArray[0][randPosX+1][randPosY]!="water":
									newWorldArray[0][randPosX+1][randPosY]="water"
									randPosX=randPosX+1
									waterStepsCurrent+=1
								pass
							elif randDir==1:
								if newWorldArray[0][randPosX][randPosY-1]!="water":
									newWorldArray[0][randPosX][randPosY-1]="water"
									randPosY=randPosY-1
									waterStepsCurrent+=1
								pass
							elif randDir==2:
								if newWorldArray[0][randPosX][randPosY+1]!="water":
									newWorldArray[0][randPosX][randPosY+1]="water"
									randPosY=randPosY+1
									waterStepsCurrent+=1
								pass
							pass
						elif randPosX>0 && randPosX<w-1:
							randomize()
							var randDir=randi() % 3
							if randDir==0:
								if newWorldArray[0][randPosX+1][randPosY]!="water":
									newWorldArray[0][randPosX+1][randPosY]="water"
									randPosX=randPosX+1
									waterStepsCurrent+=1
								pass
							elif randDir==1:
								if newWorldArray[0][randPosX][randPosY-1]!="water":
									newWorldArray[0][randPosX][randPosY-1]="water"
									randPosY=randPosY-1
									waterStepsCurrent+=1
								pass
							elif randDir==2:
								if newWorldArray[0][randPosX][randPosY+1]!="water":
									newWorldArray[0][randPosX][randPosY+1]="water"
									randPosY=randPosY+1
									waterStepsCurrent+=1
								pass
							elif randDir==3:
								if newWorldArray[0][randPosX-1][randPosY]!="water":
									newWorldArray[0][randPosX-1][randPosY]="water"
									randPosX=randPosX-1
									waterStepsCurrent+=1
								pass
							pass
						elif randPosX==w-1:
							randomize()
							var randDir=randi() % 2
							if randDir==0:
								if newWorldArray[0][randPosX-1][randPosY]!="water":
									newWorldArray[0][randPosX-1][randPosY]="water"
									randPosX=randPosX-1
									waterStepsCurrent+=1
								pass
							elif randDir==1:
								if newWorldArray[0][randPosX][randPosY-1]!="water":
									newWorldArray[0][randPosX][randPosY-1]="water"
									randPosY=randPosY-1
									waterStepsCurrent+=1
								pass
							elif randDir==2:
								if newWorldArray[0][randPosX][randPosY+1]!="water":
									newWorldArray[0][randPosX][randPosY+1]="water"
									randPosY=randPosY+1
									waterStepsCurrent+=1
								pass
							pass
						pass
					elif randPosY==h-1:
						if randPosX==0:
							randomize()
							var randDir=randi() % 1
							if randDir==0:
								if newWorldArray[0][randPosX+1][randPosY]!="water":
									newWorldArray[0][randPosX+1][randPosY]="water"
									randPosX=randPosX+1
									waterStepsCurrent+=1
								pass
							else:
								if newWorldArray[0][randPosX][randPosY-1]!="water":
									newWorldArray[0][randPosX][randPosY-1]="water"
									randPosY=randPosY-1
									waterStepsCurrent+=1
								pass
							pass
						elif randPosX>0 && randPosX<w-1:
							randomize()
							var randDir=randi() % 2
							if randDir==0:
								if newWorldArray[0][randPosX+1][randPosY]!="water":
									newWorldArray[0][randPosX+1][randPosY]="water"
									randPosX=randPosX+1
									waterStepsCurrent+=1
								pass
							elif randDir==1:
								if newWorldArray[0][randPosX][randPosY-1]!="water":
									newWorldArray[0][randPosX][randPosY-1]="water"
									randPosY=randPosY-1
									waterStepsCurrent+=1
								pass
							elif randDir==2:
								if newWorldArray[0][randPosX-1][randPosY]!="water":
									newWorldArray[0][randPosX-1][randPosY]="water"
									randPosX=randPosX-1
									waterStepsCurrent+=1
								pass
							pass
						elif randPosX==w-1:
							randomize()
							var randDir=randi() % 1
							if randDir==0:
								if newWorldArray[0][randPosX-1][randPosY]!="water":
									newWorldArray[0][randPosX-1][randPosY]="water"
									randPosX=randPosX-1
									waterStepsCurrent+=1
								pass
							else:
								if newWorldArray[0][randPosX][randPosY-1]!="water":
									newWorldArray[0][randPosX][randPosY-1]="water"
									randPosY=randPosY-1
									waterStepsCurrent+=1
								pass
							pass
						pass
					pass
				else:
					if waterLevel>=1:
						hasStartedWaterChunk=false
						pass
					waterLevel-=1
					pass
				pass
			if waterLevel<=0:
				for y in h:
					for x in w:
						if newWorldArray[0][x][y]!="water":
							newWorldArray[0][x][y]="dirt"
							pass
						pass
					pass
				pass
			hasGeneratedLayer0=true
			pass
#		if !hasGeneratedOtherLayers:
#			for y in h:
#				for x in w:
#					newWorldArray[1][x][y]=="blank"
#					newWorldArray[2][x][y]=="blank"
#					pass
#				pass
#			pass
	return newWorldArray

func GenerateBottomLevelPrefabs(var array):
	#Undeground Level
	var newWorldArray=[[],[],[]]
	for y in worldHeight:
		for x in worldWidth:
			if array[0][x][y]=="blank":
				# Throw an error into the log, Tile[x][y] empty/null space
				pass
			elif array[0][x][y]=="dirt":
				var newAgent=prefabResource.instance()
				newAgent.type="dirt"
				newAgent.spriteAtlasRegion=Vector2(11,2)
				#Color(119,65,20,255)
				newAgent.spriteColor=NewColor(166,65,20,255)
				newAgent.gridPosition=Vector2(x,y)
				newAgent.amount=100
				newAgent.position=Vector2((startingPosition.x+(x*gridSize)),(startingPosition.y+(y*gridSize)))
				containerLevel0.add_child(newAgent)
				newAgent.readyToStart=1
				#debug
#				newAgent.visible=false
				pass
			elif array[0][x][y]=="water":
				var newAgent=prefabResource.instance()
				newAgent.type="water"
				newAgent.spriteAtlasRegion=Vector2(2,11)
				newAgent.spriteColor=NewColor(61,102,164,255)
				newAgent.gridPosition=Vector2(x,y)
				newAgent.amount=100
				newAgent.position=Vector2((startingPosition.x+(x*gridSize)),(startingPosition.y+(y*gridSize)))
				containerLevel0.add_child(newAgent)
				newAgent.readyToStart=1

				#debug
#				newAgent.visible=false
				pass
			pass
		pass
#	for y in newWorldArray[1].size():
#		for x in newWorldArray[1][y].size():
#			if newWorldArray[1][x][y]==null:
#				pass
#			if newWorldArray[1][x][y]=="blank":
#				# Pass, we cool
#				pass
#			if newWorldArray[1][x][y]=="bush":
#				var newAgent=prefabResource.instance()
#				newAgent.type="bush"
#				newAgent.spriteIndex=7
#				newAgent.spriteColor=NewColor(81,141,57,255)
#				newAgent.gridPosition=Vector2(x,y)
#				newAgent.amount=100
#				newAgent.position=Vector2(startingPosition.x+(x*gridSize),startingPosition.y+(y*gridSize))
#				containerLevel1.add_child(newAgent)
#				newAgent.readyToStart=1
#
#				obstacles.append(Vector2(x,y))
#				pass
#			if newWorldArray[1][x][y]=="tree":
#				var newAgent=prefabResource.instance()
#				newAgent.type="tree"
#				newAgent.spriteIndex=25
#				newAgent.spriteColor=NewColor(98,105,24,255)
#				newAgent.gridPosition=Vector2(x,y)
#				newAgent.amount=100
#				newAgent.position=Vector2(startingPosition.x+(x*gridSize),startingPosition.y+(y*gridSize))
#				containerLevel1.add_child(newAgent)
#				newAgent.readyToStart=1
#
#				obstacles.append(Vector2(x,y))
#				pass
#			pass
#		pass
#	return newWorldArray
	pass
	
func WorldStep():
	emit_signal("worldStep")
	pass
	
func UpdateArray(var x, var y, var value):
	
	pass
	
func NewColor(var r, var g, var b, var a):
	var newColor=Color()
	newColor.a8=a
	newColor.b8=b
	newColor.g8=g
	newColor.r8=r
	return newColor
	pass

func PrepareAStarPoints():
	var walkablePoints=AStarAddAvailablePoints(obstacles)
	AStarConnectAvailablePoints(walkablePoints)
	pass
	
func AStarAddAvailablePoints(obstacles=[]):
	var pointsArray=[]
	for y in worldHeight-1:
		for x in worldWidth-1:
			var point=Vector2(x,y)
			if point in obstacles:
				continue
			pointsArray.append(point)
			var pointIndex=CalculatePointIndex(point, worldWidth)
			aStarNode.add_point(pointIndex, Vector3(point.x, point.y, 0.0))
			
	return pointsArray
	pass
	
func AStarConnectAvailablePoints(pointsArray):
	for point in pointsArray:
		var pointIndex=CalculatePointIndex(point, worldWidth)
		var pointsRelative=PoolVector2Array([
		Vector2(point.x-1, point.y),
		Vector2(point.x+1, point.y),
		Vector2(point.x, point.y-1),
		Vector2(point.x, point.y+1)])
		for pointRelative in pointsRelative:
			var pointRelativeIndex=CalculatePointIndex(pointRelative)
			if IsOutsideMap(pointRelative):
				continue
			if not aStarNode.has_point(pointRelativeIndex):
				continue
			aStarNode.connect_points(pointIndex, pointRelativeIndex, false)
			pass
		pass
	pass
	
func CalculatePointIndex(point, wrldWidth):
	return point.x + wrldWidth * point.y
	
func IsOutsideMap(point, wrldWidth, wrldHeight):
	return point.x < 0 or point.y < 0 or point.x >= wrldWidth or point.y >= wrldHeight

func ScaleGridToWindow(wrldWidth, wrldHeight):
	var scaledGridSize
	var windowSize=OS.window_size
	scaledGridSize=windowSize.x/wrldWidth
	return scaledGridSize
	
func SpawnObjectsByPacket(spawnPacket, array):
	var arrayArchitecture=spawnPacket["architecture"]
	var arrayResource=spawnPacket["resource"]
	var arrayAgent=spawnPacket["agent"]
	var currentArchCount=0
	var currentArchX=0
	var currentArchY=0
	var currentPos=Vector2(0,0)
	var isAreaClear=false
	
	var timesRun=0
	
	if !arrayArchitecture.size()==0:
		var totalArchs=0
		var totalArchSize=Vector2(0,0)
		var availableSpaceTotal=Vector2(0,0)
		var availableSpaceCurrent=Vector2(0,0)
		var archSizeGapX=[]
		var archSizeGapY=[]
		var archIndex=-1
		for arch in arrayArchitecture.keys():
			if arrayArchitecture[arch]["sizeAmount"].size()==0:
				break
			for sizes in arrayArchitecture[arch]["sizeAmount"].keys():
				for amount in arrayArchitecture[arch]["sizeAmount"][sizes]:
					var sizeArray=sizes.split("x",false)
					totalArchSize.x+=int(sizeArray[0])
					totalArchSize.y+=int(sizeArray[1])
					totalArchs+=1
						
			if arrayArchitecture[arch]["sizeAmount"].size()>0:
				availableSpaceTotal.x=worldWidth-totalArchSize.x-1
				availableSpaceTotal.y=worldHeight-totalArchSize.y-1
				availableSpaceCurrent=availableSpaceTotal
				for archs in totalArchs:
					if availableSpaceCurrent.x>0:
						randomize()
						archSizeGapX.append(int(rand_range(0,availableSpaceCurrent.x/totalArchs)))
						availableSpaceCurrent.x-=archSizeGapX[archs]
						continue
					else:
						archSizeGapX.append(0)
						continue
						pass
					pass
				for archs in totalArchs:
					if availableSpaceCurrent.y>0:
						randomize()
						archSizeGapY.append(int(rand_range(0,availableSpaceCurrent.y/totalArchs)))
						availableSpaceCurrent.y-=archSizeGapY[archs]
						continue
					else:
						archSizeGapY.append(0)
						continue
						pass
					pass
			elif arrayArchitecture[arch]["sizeAmount"].size()==1:
				archSizeGapX.append(0)
				archSizeGapY.append(0)
				pass
			for sizes in arrayArchitecture[arch]["sizeAmount"].keys():
				for amount in arrayArchitecture[arch]["sizeAmount"][sizes]:
					archIndex+=1
					var sizeArray=sizes.split("x",false)
					var newArchSize=Vector2(int(sizeArray[0]),int(sizeArray[1]))
					var startPos=Vector2(0,0)
					isAreaClear=false
					var hasCheckedCells=false
					var currentBlankX=0
					var currentBlankY=0
					var curX=0
					var curY=0
					var checkedCellsMax=0
					var checkedCells=0
					var checkedCellsValid=0
					var currentArchSize=totalArchSize
					checkedCellsMax=(newArchSize.x)*(newArchSize.y)
					
					#TODO Revamp Variance system, Currently the subsequent archs will spawn on the bottom right side of the previous archs,
					#and if not, throw both an error, and delete  all remaining archs to be built within the arch:dictionary
					#Idealy, you would just check this in the "Packet Editor" UI, but more exceptions can't hurt ;)
					#var randPos=Vector2(int(rand_range(0,worldWidth-currentArchSize.x+1)),int(rand_range(0,worldHeight-currentArchSize.y+1)))
					var xNow=0
					var yNow=0
					var xInNow=0
					var yInNow=0
					while !isAreaClear:
						if hasCheckedCells:
							startPos.x=curX
							startPos.y=curY
							checkedCells=0
							checkedCellsValid=0
							isAreaClear=true
						for yy in (worldHeight-1-newArchSize.y):
							if isAreaClear: break
							if hasCheckedCells: break
							yNow=yy
							for xx in (worldWidth-1-newArchSize.x):
								if isAreaClear: break
								if hasCheckedCells: break
								xNow=xx
								for yIn in newArchSize.y:
									if isAreaClear: break
									if hasCheckedCells: break
									if worldArray[1][xx-1][yy+yIn]!="blank":
										checkedCellsValid=0
										checkedCells=0
									if worldArray[1][xx-1][yy]!="blank":
										checkedCellsValid=0
										checkedCells=0
									if worldArray[1][xx+newArchSize.x][yy]!="blank":
										checkedCellsValid=0
										checkedCells=0
									if worldArray[1][xx+newArchSize.x][yy+yIn]!="blank":
										checkedCellsValid=0
										checkedCells=0
									if worldArray[1][xx+xInNow-1][yy+newArchSize.y]!="blank":
										checkedCellsValid=0
										checkedCells=0
									if worldArray[1][xx-1][yy+newArchSize.y]!="blank":
										checkedCellsValid=0
										checkedCells=0
									yInNow=yIn
									for xIn in newArchSize.x:
										if isAreaClear: break
										if hasCheckedCells: break
										xInNow=xIn
										if worldArray[1][xx+xIn][yy+yIn]!="blank":
											checkedCells+=1
											checkedCellsValid=0
										elif worldArray[1][xx+xIn][yy+yIn]=="blank":
											checkedCellsValid+=1
											checkedCells+=1
										if worldArray[1][xx+xInNow][yy-1]!="blank":
											checkedCellsValid=0
											checkedCells=0
										if worldArray[1][xx][yy-1]!="blank":
											checkedCellsValid=0
											checkedCells=0
										if worldArray[1][xx-1][yy-1]!="blank":
											checkedCellsValid=0
											checkedCells=0
										if worldArray[1][xx][yy+newArchSize.y]!="blank":
											checkedCellsValid=0
											checkedCells=0
										if worldArray[1][xx+xIn][yy+newArchSize.y]!="blank":
											checkedCellsValid=0
											checkedCells=0
										if worldArray[1][xx+newArchSize.x][yy+newArchSize.y]!="blank":
											checkedCellsValid=0
											checkedCells=0
										if worldArray[1][xx+newArchSize.x][yy-1]!="blank":
											checkedCellsValid=0
											checkedCells=0
										if worldArray[1][xx+newArchSize.x][yy+yIn-1]!="blank":
											checkedCellsValid=0
											checkedCells=0
										if xNow+xIn==0 && yNow+yIn==0:
											checkedCellsValid=0
										elif yNow+yIn==0:
											checkedCellsValid=0
										elif xNow+xIn==0:
											checkedCellsValid=0
										if checkedCellsValid==checkedCellsMax:
											currentArchSize.x-=newArchSize.x
											currentArchSize.y-=newArchSize.y
											curX=xx
											curY=yy
											checkedCellsValid+=1
											if archIndex==totalArchs-1:
												print(worldArray[1][0][0])
											hasCheckedCells=true
										else:
											if checkedCells==checkedCellsMax:
												checkedCells=0
												checkedCellsValid=0
										pass
							
					currentPos=startPos
					var archArea=(newArchSize.x)*(newArchSize.y)
					var nextDir="none"
					var hasSpawnedWalls=false
					#TODO Make this variable based on the size of the current arch
					var doorCount=int(rand_range(1,2))
					#debug
					match arch:
						"house":
							while currentArchCount<archArea:
								if !hasSpawnedWalls:
									
									#TODO#
									#Spawn Doors, use "doorCount" for chance to spawn or something
									if currentArchCount==0:
										array[1][currentPos.x][currentPos.y]="house"+String(archIndex)
										var randDir=(randi()%2)-1
										nextDir="right"
										
										#Spawn Object
										var newAgent=prefabArchitecture.instance()
										newAgent.type="Arch"
										newAgent.subType="TL_WALL"
										newAgent.spriteAtlasRegion=Vector2(9,12)
										#Color(209,206,207,255)
										newAgent.spriteColor=NewColor(209,206,207,255)
										newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
										newAgent.condition=100
										newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
										containerLevel1.add_child(newAgent)
										newAgent.readyToStart=1
										currentPos.x+=1
										currentArchCount+=1
										pass
									elif currentArchCount<archArea:
										match nextDir:
											"right":
												#yah
												array[1][currentPos.x][currentPos.y]="house"+String(archIndex)
												var newAgent=prefabArchitecture.instance()
												currentArchCount+=1
												if currentArchX==newArchSize.x-2:
													#Spawn Object
													newAgent.type="Arch"
													newAgent.subType="TR_WALL"
													newAgent.spriteAtlasRegion=Vector2(15,11)
													#Color(209,206,207,255)
													newAgent.spriteColor=NewColor(209,206,207,255)
													newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
													newAgent.condition=100
													newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
													containerLevel1.add_child(newAgent)
													newAgent.readyToStart=1
													currentPos.y+=1
													nextDir="down"
													currentArchX=0
												elif currentArchX<newArchSize.x-2:
													if doorCount>0:
														if int(rand_range(0,10))>7:
															#Spawn Object
															newAgent.type="Arch"
															newAgent.subType="Door_Hor"
															newAgent.spriteAtlasRegion=Vector2(11,13)
															#Color(209,206,207,255)
															newAgent.spriteColor=NewColor(209,206,207,255)
															newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
															newAgent.condition=100
															newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
															containerLevel1.add_child(newAgent)
															newAgent.readyToStart=1
															currentArchX+=1
															currentPos.x+=1
															doorCount-=1
															pass
														else:
															#Spawn Object
															newAgent.type="Arch"
															newAgent.subType="Top_WALL"
															newAgent.spriteAtlasRegion=Vector2(13,12)
															#Color(209,206,207,255)
															newAgent.spriteColor=NewColor(209,206,207,255)
															newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
															newAgent.condition=100
															newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
															containerLevel1.add_child(newAgent)
															newAgent.readyToStart=1
															currentArchX+=1
															currentPos.x+=1
															pass
														pass
													else:
														#Spawn Object
														newAgent.type="Arch"
														newAgent.subType="Top_WALL"
														newAgent.spriteAtlasRegion=Vector2(13,12)
														#Color(209,206,207,255)
														newAgent.spriteColor=NewColor(209,206,207,255)
														newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
														newAgent.condition=100
														newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
														containerLevel1.add_child(newAgent)
														newAgent.readyToStart=1
														currentArchX+=1
														currentPos.x+=1
													pass
											"down":
												array[1][currentPos.x][currentPos.y]="house"+String(archIndex)
												var newAgent=prefabArchitecture.instance()
												currentArchCount+=1
												if currentArchY==newArchSize.y-2:
													#Spawn Object
													newAgent.type="Arch"
													newAgent.subType="BR_WALL"
													newAgent.spriteAtlasRegion=Vector2(12,11)
													#Color(209,206,207,255)
													newAgent.spriteColor=NewColor(209,206,207,255)
													newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
													newAgent.condition=100
													newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
													containerLevel1.add_child(newAgent)
													newAgent.readyToStart=1
													nextDir="left"
													currentArchY=0
													currentPos.x-=1
												elif currentArchY<newArchSize.y-2:
													if doorCount>0:
														if int(rand_range(0,10))>8:
															#Spawn Object
															newAgent.type="Arch"
															newAgent.subType="Door_Vert"
															newAgent.spriteAtlasRegion=Vector2(12,13)
															#Color(209,206,207,255)
															newAgent.spriteColor=NewColor(209,206,207,255)
															newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
															newAgent.condition=100
															newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
															containerLevel1.add_child(newAgent)
															newAgent.readyToStart=1
															currentArchY+=1
															currentPos.y+=1
															doorCount-=1
															pass
														else:
															#Spawn Object
															newAgent.type="Arch"
															newAgent.subType="Right_WALL"
															newAgent.spriteAtlasRegion=Vector2(10,11)
															#Color(209,206,207,255)
															newAgent.spriteColor=NewColor(209,206,207,255)
															newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
															newAgent.condition=100
															newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
															containerLevel1.add_child(newAgent)
															newAgent.readyToStart=1
															currentArchY+=1
															currentPos.y+=1
															pass
													else:
														#Spawn Object
														newAgent.type="Arch"
														newAgent.subType="Right_WALL"
														newAgent.spriteAtlasRegion=Vector2(10,11)
														#Color(209,206,207,255)
														newAgent.spriteColor=NewColor(209,206,207,255)
														newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
														newAgent.condition=100
														newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
														containerLevel1.add_child(newAgent)
														newAgent.readyToStart=1
														currentArchY+=1
														currentPos.y+=1
													pass
											"left":
												array[1][currentPos.x][currentPos.y]="house"+String(archIndex)
												var newAgent=prefabArchitecture.instance()
												currentArchCount+=1
												if currentArchX==newArchSize.x-2:
													#Spawn Object
													newAgent.type="Arch"
													newAgent.subType="BL_WALL"
													newAgent.spriteAtlasRegion=Vector2(4,13)
													#Color(209,206,207,255)
													newAgent.spriteColor=NewColor(209,206,207,255)
													newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
													newAgent.condition=100
													newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
													containerLevel1.add_child(newAgent)
													newAgent.readyToStart=1
													nextDir="up"
													currentPos.y-=1
													currentArchX=0
												elif currentArchX<newArchSize.x-2:
													if doorCount>0:
														if int(rand_range(0,10))>7:
															#Spawn Object
															newAgent.type="Arch"
															newAgent.subType="Door_Hor"
															newAgent.spriteAtlasRegion=Vector2(11,13)
															#Color(209,206,207,255)
															newAgent.spriteColor=NewColor(209,206,207,255)
															newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
															newAgent.condition=100
															newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
															containerLevel1.add_child(newAgent)
															newAgent.readyToStart=1
															currentArchX+=1
															currentPos.x-=1
															doorCount-=1
															pass
														else:
															#Spawn Object
															newAgent.type="Arch"
															newAgent.subType="Bottom_WALL"
															newAgent.spriteAtlasRegion=Vector2(13,12)
															#Color(209,206,207,255)
															newAgent.spriteColor=NewColor(209,206,207,255)
															newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
															newAgent.condition=100
															newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
															containerLevel1.add_child(newAgent)
															newAgent.readyToStart=1
															currentArchX+=1
															currentPos.x-=1
															pass
													else:
														#Spawn Object
														newAgent.type="Arch"
														newAgent.subType="Bottom_WALL"
														newAgent.spriteAtlasRegion=Vector2(13,12)
														#Color(209,206,207,255)
														newAgent.spriteColor=NewColor(209,206,207,255)
														newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
														newAgent.condition=100
														newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
														containerLevel1.add_child(newAgent)
														newAgent.readyToStart=1
														currentArchX+=1
														currentPos.x-=1
													pass
												pass
											"up":
												array[1][currentPos.x][currentPos.y]="house"+String(archIndex)
												var newAgent=prefabArchitecture.instance()
												currentArchCount+=1
												if currentArchY==newArchSize.y-3:
													if doorCount>0:
														#Spawn Object
														newAgent.type="Arch"
														newAgent.subType="Door_Vert"
														newAgent.spriteAtlasRegion=Vector2(12,13)
														#Color(209,206,207,255)
														newAgent.spriteColor=NewColor(209,206,207,255)
														newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
														newAgent.condition=100
														newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
														containerLevel1.add_child(newAgent)
														newAgent.readyToStart=1
														hasSpawnedWalls=true
														currentArchY=0
														pass
													else:
														#Spawn Object
														newAgent.type="Arch"
														newAgent.subType="Left_WALL"
														newAgent.spriteAtlasRegion=Vector2(3,11)
														#Color(209,206,207,255)
														newAgent.spriteColor=NewColor(209,206,207,255)
														newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
														newAgent.condition=100
														newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
														containerLevel1.add_child(newAgent)
														newAgent.readyToStart=1
														hasSpawnedWalls=true
														currentArchY=0
												elif currentArchY<newArchSize.y-3 && !hasSpawnedWalls:
													if doorCount>0:
														if int(rand_range(0,10))>6:
															#Spawn Object
															newAgent.type="Arch"
															newAgent.subType="Door_Vert"
															newAgent.spriteAtlasRegion=Vector2(12,13)
															#Color(209,206,207,255)
															newAgent.spriteColor=NewColor(209,206,207,255)
															newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
															newAgent.condition=100
															newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
															containerLevel1.add_child(newAgent)
															newAgent.readyToStart=1
															currentArchY+=1
															currentPos.y-=1
															doorCount-=1
															pass
														else:
															#Spawn Object
															newAgent.type="Arch"
															newAgent.subType="Left_WALL"
															newAgent.spriteAtlasRegion=Vector2(3,11)
															#Color(209,206,207,255)
															newAgent.spriteColor=NewColor(209,206,207,255)
															newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
															newAgent.condition=100
															newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
															containerLevel1.add_child(newAgent)
															newAgent.readyToStart=1
															currentArchY+=1
															currentPos.y-=1
															pass
													else:
														#Spawn Object
														newAgent.type="Arch"
														newAgent.subType="Left_WALL"
														newAgent.spriteAtlasRegion=Vector2(3,11)
														#Color(209,206,207,255)
														newAgent.spriteColor=NewColor(209,206,207,255)
														newAgent.gridPosition=Vector2(currentPos.x,currentPos.y)
														newAgent.condition=100
														newAgent.position=Vector2((startingPosition.x+(currentPos.x*gridSize)),(startingPosition.y+(currentPos.y*gridSize)))
														containerLevel1.add_child(newAgent)
														newAgent.readyToStart=1
														currentArchY+=1
														currentPos.y-=1
												pass
										pass
									pass
								else:
									#TODO, Randomishly spawn walls inside
									#randomize()
									#var randPosInside=Vector2(rand_range(startPos.x+1,newArchSize.x-1),rand_range(startPos.y+1,newArchSize.y-1))
									#while worldArray[1][randPosInside.x][randPosInside.y]!="blank":
									#	randPosInside=Vector2(rand_range(startPos.x+1,newArchSize.x-1),rand_range(startPos.y+1,newArchSize.y-1))
									#	pass
									#var currentPosInside=randPosInside
									var startPosInside=Vector2()
									startPosInside.x=startPos.x+1
									startPosInside.y=startPos.y+1
									for y in newArchSize.y-2:
										for x in newArchSize.x-2:
											#Spawn Object
											var xx=x+startPosInside.x
											var yy=y+startPosInside.y
											array[1][xx][yy]="house"+String(archIndex)
											var newAgent=prefabArchitecture.instance()
											newAgent.type="Arch"
											newAgent.subType="Floor"
											newAgent.spriteAtlasRegion=Vector2(1,11)
											#Color(209,206,207,255)
											newAgent.spriteColor=NewColor(209,206,207,255)
											newAgent.gridPosition=Vector2(xx,yy)
											newAgent.condition=100
											newAgent.position=Vector2((startingPosition.x+(xx*gridSize)),(startingPosition.y+(yy*gridSize)))
											containerLevel1.add_child(newAgent)
											newAgent.readyToStart=1
											currentArchCount+=1
											currentArchX=0
											currentArchY=0
											
											#end
											if y==newArchSize.y-3:
												if x==newArchSize.x-3:
													if archIndex==totalArchs-1:
														#debug
#														var arrayText=""
#														for array in worldArray[1].size():
#															arrayText+=String(worldArray[1][array])
#															arrayText+="\n"
#															pass
#														gridFileDebug.open("res://gridFileDebug.txt", File.READ_WRITE)
#														if gridFileDebug.get_as_text()!=String(arrayText):
#															gridFileDebug.store_string(String(arrayText))
#														gridFileDebug.close()
														#debug
														pass
													isAreaClear=false
													hasCheckedCells=false
													currentBlankX=0
													currentBlankY=0
													currentPos=Vector2(0,0)
													curX=0
													curY=0
													checkedCellsMax=0
													pass
											pass 
										pass 
									pass
							if currentArchCount==archArea:
								#arrayArchitecture[arch]["sizeAmount"].erase(sizes)
								currentArchCount=0
								pass
							pass
						"ruin":
							
							pass
				pass
			archIndex=-1
			pass
	if !arrayResource.size()==0:
#	if arrayResource.size()==0:
		for resource in arrayResource.keys():
			if arrayResource[resource]["amount"]>0:
				match resource:
					"tree":
						var isClear=false
						var resourceToSpawn=arrayResource[resource]["amount"]
						while resourceToSpawn>0:
							for y in worldHeight-1:
								for x in worldWidth-1:
									if worldArray[0][x][y]=="dirt":
										if worldArray[1][x][y]=="blank":
											if int(rand_range(0,10))>7:
												#Spawn Object
												var newAgent=prefabResource.instance()
												newAgent.type="Tree"
												newAgent.subType="Evergreen"
												newAgent.spriteAtlasRegion=Vector2(8,1)
												#Color(209,206,207,255)
												newAgent.spriteColor=NewColor(38,136,82,255)
												newAgent.gridPosition=Vector2(x,y)
												newAgent.amount=100
												newAgent.position=Vector2((x*gridSize)+startingPosition.x,(startingPosition.y+(y*gridSize)))
												containerLevel1.add_child(newAgent)
												newAgent.readyToStart=1
												#end
												resourceToSpawn-=1
												pass
											pass
										pass
									pass
#							var randPos=Vector2(int(rand_range(0,worldWidth-1)),int(rand_range(0,worldHeight-1)))
#							while worldArray[1][randPos.x][randPos.y]!="blank":
#								while worldArray[0][randPos.x][randPos.y]!="dirt":
#									randPos=Vector2(int(rand_range(0,worldWidth-1)),int(rand_range(0,worldHeight-1)))
#									pass
#								pass
#							while !isClear:
#								if worldArray[1][randPos.x][randPos.y]=="blank":
#									if worldArray[0][randPos.x][randPos.y]=="dirt":
#										isClear=true
#										pass
#									else:
#										randPos=Vector2(int(rand_range(0,worldWidth-1)),int(rand_range(0,worldHeight-1)))
#										isClear=false
#										pass
#									pass
#								else:
#									randPos=Vector2(int(rand_range(0,worldWidth-1)),int(rand_range(0,worldHeight-1)))
#									isClear=false
#									pass
#								pass
#							if int(rand_range(0,10))>8:
#								#Spawn Object
#								var newAgent=prefabResource.instance()
#								newAgent.type="Tree"
#								newAgent.subType="Evergreen"
#								newAgent.spriteAtlasRegion=Vector2(8,1)
#								#Color(209,206,207,255)
#								newAgent.spriteColor=NewColor(38,136,82,255)
#								newAgent.gridPosition=Vector2(randPos.x,randPos.y)
#								newAgent.amount=100
#								newAgent.position=Vector2((randPos.x*gridSize)*gridScaleRatio,(randPos.y*gridSize)*gridScaleRatio)
#								containerLevel1.add_child(newAgent)
#								newAgent.readyToStart=1
#								#end
#								resourceToSpawn-=1
								pass
					"bush":
						pass
#					for y in worldHeight-1:
#						if resourceToSpawn<1:
#							break
#						for x in worldWidth-1:
#							if resourceToSpawn<1:
#								break
#							if worldArray[1][x][y]=="blank":
#								if int(rand_range(0,10))>8:
#									#Spawn Object
#									var newAgent=prefabResource.instance()
#									newAgent.type="Tree"
#									newAgent.subType="Evergreen"
#									newAgent.spriteAtlasRegion=Vector2(8,1)
#									#Color(209,206,207,255)
#									newAgent.spriteColor=NewColor(38,136,82,255)
#									newAgent.gridPosition=Vector2(x,y)
#									newAgent.amount=100
#									newAgent.position=Vector2((x*gridSize)*gridScaleRatio,(y*gridSize)*gridScaleRatio)
#									containerLevel1.add_child(newAgent)
#									newAgent.readyToStart=1
#
#									#end
#									resourceToSpawn-=1
#									pass
#								pass
#							pass
				pass
			pass
	#if arrayAgent.size()==0:
	if !arrayAgent.size()==0:
		var currentAgentIndex=0
		for agent in arrayAgent.keys():
			if arrayAgent[agent]["amount"]>0:
				var agentsToSpawn=arrayAgent[agent]["amount"]
				if agentsToSpawn==0:
					break
				while agentsToSpawn>0:
					for y in worldHeight-1:
						if agentsToSpawn==0:
							break
						for x in worldWidth-1:
							if agentsToSpawn==0:
								break
							if worldArray[1][x][y]=="house"+String(currentAgentIndex):
								var subNode=GetNodeAtPos(containerLevel1,Vector2(x,y),"GridPosition")
								if subNode.subType=="Floor":
									worldArray[2][x][y]=="Agent"
									#Spawn Object
									var newAgent=prefabAgent.instance()
									newAgent.type="Agent"
									newAgent.subType="Humanoid"
									var nameLength=int(rand_range(5,8))
									var randName=""
									for i in nameLength:
										var randLetterRange=int(rand_range(65,91))
										randName+=OS.get_scancode_string(randLetterRange)
										pass
									newAgent.agentName=randName
									newAgent.spriteAtlasRegion=Vector2(1,0)
									#Color(209,206,207,255)
									newAgent.spriteColor=NewColor(178,164,140,255)
									newAgent.gridPosition=Vector2(x,y)
									newAgent.position=Vector2((x*gridSize)+startingPosition.x,(startingPosition.y+(y*gridSize)))
									containerLevel2.add_child(newAgent)
									newAgent.readyToStart=1
									#end
									agentsToSpawn-=1
									currentAgentIndex+=1
									pass
				pass
			pass
	pass
	
func GetNodeAtPos(nodes,pos,mode):
	match mode:
		"GridPosition":
			for node in nodes.get_children():
				if node.gridPosition == pos:  return node
			pass
		"NodePosition":
			for node in nodes.get_children():
				if node.position == pos:
					return node
			pass
		
func RestartGameState():
	for c in containerLevel0.get_children():
		c.queue_free()
		pass
	for c in containerLevel1.get_children():
		c.queue_free()
		pass
	for c in containerLevel2.get_children():
		c.queue_free()
		pass
	hasLoaded=false
	pass