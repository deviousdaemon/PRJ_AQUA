extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var identity="UNDEFINED"
var hasSpawned=false
var hasStarted=false
var treeRoot
var agentMaster
var worldManagerNode
var worldWidth
var worldHeight
var selfStep=false
enum InstinctualDrives {
	exhaustionMental,
	exhaustionPhysical,
	hunger,
	hygiene,
	thrist
}
var gridPosition


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	treeRoot=get_tree().get_root().get_child(0)
	agentMaster=treeRoot.find_node("AgentMaster")
	worldManagerNode=treeRoot.find_node("WorldManager")
	worldManagerNode.connect("worldStep", self, "OnWorldStep")
	set_process(true)
	pass

func _process(delta):
	if !hasSpawned:
		if !hasStarted:
			var aList=agentMaster.agentList
			if aList.size()==0:
				var tempID=self
				agentMaster.agentList.append(tempID)
				identity=tempID
				hasStarted=true
				pass
			elif aList.size()==1:
				var tempID=self
				agentMaster.agentList.append(tempID)
				identity=tempID
				hasStarted=true
				pass
			elif aList.size()>1:
				var tempID=self
				agentMaster.agentList.append(tempID)
				identity=tempID
				hasStarted=true
				pass
			pass
		randomize()
		var randomX=randi() % 15
		randomize()
		var randomY=randi() % 15
		while worldManagerNode.worldArray[1][randomX][randomY]!=null && worldManagerNode.worldArray[0][randomX][randomY]!="water":
			randomize()
			randomX=randi() % 15
			randomize()
			randomY=randi() % 15
			pass
		
		worldManagerNode.worldArray[1][randomX][randomY]=identity
		gridPosition=Vector2(randomX,randomY)
		worldWidth=worldManagerNode.worldArray[1].size()
		worldHeight=worldManagerNode.worldArray[1][0].size()-1
		worldManagerNode.WorldStep()
		hasSpawned=true
	else:
		if selfStep:
			IdleWander()
			
			selfStep=false
			pass
		pass
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func IdleWander():
	randomize()
	if gridPosition.y==0:
		if gridPosition.x==0:
			var check=CheckIdleMovement(0,1,gridPosition, worldManagerNode.worldArray, agentMaster)
			if check[0]==true:
				worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
				worldManagerNode.worldArray[check[1].x][check[1].y]=self
				gridPosition=check[1]
				pass
			pass
		elif gridPosition.x>0 && gridPosition.x<worldWidth-1:
			var randNumb=randi()%3+1
			if randNumb==1:
				var check=CheckIdleMovement(0,1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==2:
				var check=CheckIdleMovement(1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==3:
				var check=CheckIdleMovement(-1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			pass
		elif gridPosition.x==worldWidth-1:
			var randNumb=randi()%2+1
			if randNumb==1:
				var check=CheckIdleMovement(0,1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==2:
				var check=CheckIdleMovement(-1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			pass
		pass
	elif gridPosition.y>0 && gridPosition.y<worldHeight-1:
		if gridPosition.x==0:
			randomize()
			var randNumb=randi()%3+1
			if randNumb==1:
				var check=CheckIdleMovement(0,1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==2:
				var check=CheckIdleMovement(1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==3:
				var check=CheckIdleMovement(0,-1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			pass
		elif gridPosition.x>0 && gridPosition.x<worldWidth-1:
			var randNumb=randi()%5+1
			if randNumb==1:
				var check=CheckIdleMovement(0,1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==2:
				var check=CheckIdleMovement(1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==3:
				var check=CheckIdleMovement(-1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==4:
				var check=CheckIdleMovement(0,-1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			pass
		elif gridPosition.x==worldWidth-1:
			var randNumb=randi()%3+1
			if randNumb==1:
				var check=CheckIdleMovement(0,1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==2:
				var check=CheckIdleMovement(0,-1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==3:
				var check=CheckIdleMovement(-1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			pass
		pass
	elif gridPosition.y==worldHeight-1:
		if gridPosition.x==0:
			var randNumb=randi()%2+1
			if randNumb==1:
				var check=CheckIdleMovement(0,-1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==2:
				var check=CheckIdleMovement(1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			pass
		elif gridPosition.x>0 && gridPosition.x<worldWidth-1:
			var randNumb=randi()%3+1
			if randNumb==1:
				var check=CheckIdleMovement(0,-1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==2:
				var check=CheckIdleMovement(1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==3:
				var check=CheckIdleMovement(-1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			pass
		elif gridPosition.x==worldWidth-1:
			var randNumb=randi()%2+1
			if randNumb==1:
				var check=CheckIdleMovement(0,-1,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			elif randNumb==2:
				var check=CheckIdleMovement(-1,0,gridPosition, worldManagerNode.worldArray, agentMaster)
				if check[0]==true:
					worldManagerNode.worldArray[1][gridPosition.x][gridPosition.y]="blank"
					worldManagerNode.worldArray[1][check[1].x][check[1].y]=self
					gridPosition=check[1]
					pass
			pass
		pass
	pass

func CheckIdleMovement(var newPosX, var newPosY, var gridPos, var wrldArray, var agntMaster):
	var newGridPos=gridPos
	newGridPos.x+=newPosX
	newGridPos.y+=newPosY
	var returnValue=[false, newGridPos]
	#First, check if the new position is not an object
	if typeof(wrldArray[1][gridPos.x+newPosX][gridPos.y+newPosY])==TYPE_OBJECT:
		returnValue[0]=false
		pass
	#Second, check if the new position is clear
	elif wrldArray[1][gridPos.x+newPosX][gridPos.y+newPosY]==null:
		if wrldArray[0][gridPos.x+newPosX][gridPos.y+newPosY]=="water":
			returnValue[0]=false
		else:
			#If the movement registry is empty, the agent is free to move after registering
			if agntMaster.movementRegistry.size()==0:
				agntMaster.movementRegistry.append(newGridPos)
				returnValue[0]=true
				pass
			#If not, Check if new position is in the movement registry, located in the AgentMaster
			elif agntMaster.movementRegistry.size()>0:
				#Check newGridPos against values in movement registry
				if !agntMaster.movementRegistry.has(newGridPos):
					#If the value is not a duplicate, the agent is free to move after registering
					agntMaster.movementRegistry.append(newGridPos)
					returnValue[0]=true
					pass
				else:
					returnValue[0]=false
					pass
				pass
			pass
		pass
	return returnValue
	pass



func GetInstinctualDrive(drive):
	var returnValue=null
	var getValue=InstinctualDrives.drive
	if InstinctualDrives.drive!=null:
		returnValue=getValue
	return returnValue
	pass
	
func SetInstinctualDrive(drive,value): # Returns true if it was succesful
	var returnValue=false
	var getValue=InstinctualDrives.drive
	if InstinctualDrives.drive!=null:
		InstinctualDrives.drive=value
		returnValue=true
	return returnValue
	pass


func OnWorldStep():
	if selfStep==false:
		selfStep=true
	pass # replace with function body
