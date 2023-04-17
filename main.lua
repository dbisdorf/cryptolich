TILE_SIZE = 16
MAP_SIZE = 32
TILE_CENTER = 8
SCREEN_CENTER = {x = 200, y = 150}
SCREEN_MAX = {x = 400, y = 300}
COLOR_FADE = {1.0, 1.0, 1.0, 0.5}
COLOR_WHITE = {1.0, 1.0, 1.0, 1.0}
COLOR_BLACK = {0.0, 0.0, 0.0, 1.0}
TITLE_TEXT = {{0.5, 0.5, 1.0}, "TOWER OF THE CRYPTOLICH"}
VERSION_TEXT = {{0.4, 0.4, 0.4}, "VERSION 0.1.0"}
START_TEXT = {{0.8, 0.8, 0.8}, "PRESS ENTER TO START"}
GAME_OVER_TEXT = {{1.0, 0.2, 0.2}, "GAME OVER"}
UNLOCKED_TEXT = {{0.5, 1.0, 0.5}, "SECURITY UNLOCKED"}
PREPARE_TEXT = {{0.5, 1.0, 0.5}, "PREPARE FOR"}
LEVEL_TEXT = {{0.5, 1.0, 0.5}, "NEXT LEVEL"}
SHOT_COOLDOWN = 0.5
RIGHT_INDEX = 1
DOWN_INDEX = 2
LEFT_INDEX = 3
UP_INDEX = 4
VECTORS = {{x = 1.0, y = 0.0}, {x = 0.0, y = 1.0}, {x = -1.0, y = 0.0}, {x = 0.0, y = -1.0}}
BESTIARY = {
	["player"] = {speed = 64.0, spf = 0.25, points = 0},
	["spider"] = {speed = 16.0, spf = 0.2, points = 10},
	["wasp"] = {speed = 8.0, spf = 0.05, points = 10, cooldown = 3.0}
}
ARMORY = {
	["playerM"] = {speed = 256.0},
	["waspM"] = {speed = 80.0}
}
TERRAIN = {
	{playerPass = true, enemyPass = true},
	{playerPass = false, enemyPass = false},
	{playerPass = false, enemyPass = false},
	{playerPass = false, enemyPass = false},
	{playerPass = false, enemyPass = false},
	{playerPass = true, enemyPass = false}
}
STARTING_LIVES = 3
LOCK_POINTS = 100
LEVEL_POINTS = 1000
START_POSITION = {x = 16, y = 16}
BLAST_TIME = 1.0
BLAST_SIZE = 400.0
STALL_TIME = 1.5

font = nil
textures = nil
sounds = {}
spriteQuads = {}
tileQuads = {}
mapCanvas = nil
mapInfo = {}
spriteBatch = nil
combatants = {}
missiles = {}
blasts = {}
cooldown = 0.0
killed = false
lives = 0
score = 0
gameOver = false
locks = 0
unlocked = 0
title = true
oldReturn = false
level = 0
stalling = 0.0
advancing = false

function love.load()
	-- this is where we initialize
	
	math.randomseed(os.time())

	love.graphics.setDefaultFilter("nearest", "nearest")

	font = love.graphics.newFont("Mx437_IBM_BIOS.ttf", 8, "mono")
	love.graphics.setFont(font)

	textures = love.graphics.newImage("textures.png")

	loadWalkingSprites("player", 0)
	loadWalkingSprites("spider", 16)
	loadWalkingSprites("wasp", 32)

	loadMissileSprites("playerM", 0, 208)
	loadMissileSprites("waspM", 64, 208)

	spriteQuads["life"] = love.graphics.newQuad(0, 224, TILE_SIZE, TILE_SIZE, textures)
	spriteQuads["blastH"] = love.graphics.newQuad(16, 224, TILE_SIZE, TILE_SIZE, textures)
	spriteQuads["blastV"] = love.graphics.newQuad(32, 224, TILE_SIZE, TILE_SIZE, textures)

	for t = 1, 6 do
		tileQuads[t] = love.graphics.newQuad((t - 1) * TILE_SIZE, 240, TILE_SIZE, TILE_SIZE, textures)
	end

	mapCanvas = love.graphics.newCanvas(MAP_SIZE * TILE_SIZE, MAP_SIZE * TILE_SIZE)
	spriteBatch = love.graphics.newSpriteBatch(textures, 100)

	sounds["zap"] = love.audio.newSource("zap.wav", "static")
	sounds["boom"] = love.audio.newSource("boom.wav", "static")

	--startGame()
end

function love.update(delta)
	-- this is where bookkeeping happens
	if title then
		if love.keyboard.isDown("return") then
			if not oldReturn then
				title = false
				startGame()
			end
		else
			if oldReturn then
				oldReturn = false
			end
		end
		return
	end

	local player = combatants[1]

	if gameOver then
		-- wait until start
		if love.keyboard.isDown("return") then
			startTitle()
			return
		end
	elseif stalling > 0.0 then
		-- don't do much if we're stalling
		stalling = stalling - delta
		if stalling <= 0.0 then
			if killed then
				resetPlayer()
				killed = false
			else
				level = level + 1
				startLevel()
			end
		end
	else
		-- do player and enemy stuff
		if killed then
			makeBlast(player.x, player.y)
			sounds["boom"]:play()
			lives = lives - 1
			if lives == 0 then
				gameOver = true
			else
				stalling = STALL_TIME
			end
		elseif unlocked == locks then
			awardPoints(LEVEL_POINTS)
			stalling = STALL_TIME
			advancing = true
		end

		-- player commands
		-- this could be simpler too
		local turn = nil
		local go = false
		if love.keyboard.isDown("right") then
			turn = RIGHT_INDEX
			if player.waiting then
				go = true
			end
		elseif love.keyboard.isDown("left") then
			turn = LEFT_INDEX
			if player.waiting then
				go = true
			end
		elseif love.keyboard.isDown("up") then
			turn = UP_INDEX
			if player.waiting then
				go = true
			end
		elseif love.keyboard.isDown("down") then
			turn = DOWN_INDEX
			if player.waiting then
				go = true
			end
		end
		if turn and not love.keyboard.isDown("x") then
			player.facing = turn
		end
		if go then
			if not pointIsObstructed(
				player.x + (VECTORS[turn].x * TILE_SIZE), 
				player.y + (VECTORS[turn].y * TILE_SIZE), 
				true) then
				pushCombatant(player, turn)
			end
		end

		-- abilities and cooldowns
		if cooldown > 0.0 then
			cooldown = cooldown - delta
			if cooldown < 0.0 then
				cooldown = 0.0
			end
		else
			if love.keyboard.isDown("z") then
				cooldown = SHOT_COOLDOWN
				makeMissile(
					player.x + (VECTORS[player.facing].x * TILE_CENTER), 
					player.y + (VECTORS[player.facing].y * TILE_CENTER), 
					player.facing,
					"player",
					true)
				sounds["zap"]:play()
			end
		end

		-- enemy action
		for i, c in ipairs(combatants) do
			if i > 1 then
				runEnemyLogic(c, delta)
			end
		end

		-- move the combatants around
		for i, c in ipairs(combatants) do
			moveCombatant(c, delta)
		end
	end

	-- move the missiles around
	for i, m in ipairs(missiles) do
		moveMissile(m, delta)
	end

	-- move the blasts around
	for i, b in ipairs(blasts) do
		moveBlast(b, delta)
	end

	removeDestroyed(missiles)
	removeDestroyed(combatants)
	removeDestroyed(blasts)

	spriteBatch:clear()

	-- player xy offset should be calculated only once
	for i, c in ipairs(combatants) do
		if i > 1 or not killed then
			spriteBatch:add(spriteQuads[c.name][c.facing][c.frame], c.x - player.x + SCREEN_CENTER.x, c.y - player.y + SCREEN_CENTER.y)
		end
	end
	for i, m in ipairs(missiles) do
		spriteBatch:add(spriteQuads[m.name][m.facing], m.x - player.x + SCREEN_CENTER.x, m.y - player.y + SCREEN_CENTER.y)
	end
	local blastDistance
	local blastName = "blastH"
	for i, b in ipairs(blasts) do
		blastDistance = (b.time / BLAST_TIME) * BLAST_SIZE
		for v = 1, 4 do
			spriteBatch:add(
				spriteQuads[blastName], 
				b.x + (VECTORS[v].x * blastDistance) - player.x + SCREEN_CENTER.x, 
				b.y + (VECTORS[v].y * blastDistance) - player.y + SCREEN_CENTER.y)
			if blastName == "blastH" then
				blastName = "blastV"
			else
				blastName = "blastH"
			end
		end
	end

	for l = 1, lives do
		spriteBatch:add(spriteQuads["life"], SCREEN_MAX.x - (l * TILE_SIZE), 0)
	end
end

function love.draw()
	-- this is where we draw
	
	love.graphics.scale(2.0, 2.0)

	if title then
		printCenteredText(TITLE_TEXT, SCREEN_CENTER.x, 110, 2.0)
		printCenteredText(START_TEXT, SCREEN_CENTER.x, 180, 1.0)
		printCenteredText(VERSION_TEXT, SCREEN_CENTER.x, 280, 1.0)
	else
		if gameOver or advancing then
			love.graphics.setColor(COLOR_FADE)
		end
		
		love.graphics.draw(mapCanvas, SCREEN_CENTER.x - combatants[1].x, SCREEN_CENTER.y - combatants[1].y)
		love.graphics.draw(spriteBatch)

		if gameOver then
			love.graphics.setColor(COLOR_WHITE)
			printCenteredText(GAME_OVER_TEXT, SCREEN_CENTER.x, SCREEN_CENTER.y, 2.0)
		elseif advancing then
			love.graphics.setColor(COLOR_WHITE)
			printCenteredText(UNLOCKED_TEXT, SCREEN_CENTER.x, 70, 2.0)
			printCenteredText(PREPARE_TEXT, SCREEN_CENTER.x, 140, 2.0)
			printCenteredText(LEVEL_TEXT, SCREEN_CENTER.x, 210, 2.0)
		end

		love.graphics.print(string.format("%06d", score), 0, 0)
		love.graphics.print(string.format("LEVEL %02d", level), 160)
	end

	love.graphics.origin()
end

function loadWalkingSprites(name, y)
	spriteQuads[name] = {}
	for v = 1, 4 do
		spriteQuads[name][v] = {}
		for w = 1, 4 do
			spriteQuads[name][v][w] = love.graphics.newQuad(
				((v - 1) * TILE_SIZE * 4) + ((w - 1) * TILE_SIZE), y, 
				TILE_SIZE, TILE_SIZE, textures)
		end
	end
end

function loadMissileSprites(name, x, y)
	spriteQuads[name] = {}
	for v = 1, 4 do
		spriteQuads[name][v] = love.graphics.newQuad(x + ((v - 1) * TILE_SIZE), y, TILE_SIZE, TILE_SIZE, textures)
	end
end

function buildMap()
	mapInfo = {}
	for x = 0, MAP_SIZE - 1 do
		mapInfo[x] = {}
		for y = 0, MAP_SIZE - 1 do
			if x == 0 or x == MAP_SIZE - 1 or y == 0 or y == MAP_SIZE - 1 then
				mapInfo[x][y] = 2
			elseif x < 4 and y < 4 then
				mapInfo[x][y] = 6
			else
				mapInfo[x][y] = 1
			end
		end
	end
	mapInfo[MAP_SIZE - 2][1] = 4
	mapInfo[MAP_SIZE - 2][MAP_SIZE - 2] = 4
	mapInfo[1][MAP_SIZE - 2] = 4
	local mapX, mapY
	for o = 1, 10 do
		mapX, mapY = findVacantSpot(2, 2, MAP_SIZE - 3, MAP_SIZE - 3)
		mapInfo[mapX][mapY] = 3
	end
end

function drawMap()
	love.graphics.clear()
	for x = 0, MAP_SIZE - 1 do
		for y = 0, MAP_SIZE - 1 do
			love.graphics.draw(textures, tileQuads[mapInfo[x][y]], x * TILE_SIZE, y * TILE_SIZE)
		end
	end
end

function redrawMapTile(x, y)
	love.graphics.setCanvas(mapCanvas)
	love.graphics.setColor(COLOR_BLACK)
	love.graphics.rectangle("fill", x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
	love.graphics.setColor(COLOR_WHITE)
	love.graphics.draw(textures, tileQuads[mapInfo[x][y]], x * TILE_SIZE, y * TILE_SIZE)
	love.graphics.setCanvas()
end

function makeCombatant(startX, startY, name)
	table.insert(combatants, {
		x = startX, 
		y = startY, 
		dX = startX, 
		dY = startY, 
		facing = RIGHT_INDEX, 
		animation = 0.0,
		frame = 1,
		waiting = true, 
		name = name,
		hits = 1,
		cooling = 0.0,
		destroyed = false})
end

function makeMissile(startX, startY, facing, shooter, friendly)
	table.insert(missiles, {
		x = startX, 
		y = startY, 
		facing = facing, 
		name = shooter .. "M",
		friendly = friendly,
		destroyed = false})
end

function makeBlast(startX, startY)
	table.insert(blasts, {
		x = startX,
		y = startY,
		time = 0.0,
		destroyed = false})
end

function removeDestroyed(list)
	local i = 1
	local copyTo = 1
	while list[i] do
		if list[i].destroyed then
			list[i] = nil
		else
			if copyTo < i then
				list[copyTo] = list[i]
				list[i] = nil
			end
			copyTo = copyTo + 1
		end
		i = i + 1
	end
end

function pushCombatant(combatant, facing)
	combatant.dX = combatant.x + (VECTORS[facing].x * TILE_SIZE)
	combatant.dY = combatant.y + (VECTORS[facing].y * TILE_SIZE)
	combatant.waiting = false
end

function moveCombatant(combatant, delta)
	-- this could be more succinct

	if not combatant.waiting then
		if combatant.animation > 0.0 then
			combatant.animation = combatant.animation - delta
		end
		if combatant.animation <= 0.0 then
			combatant.animation = combatant.animation + BESTIARY[combatant.name].spf
			combatant.frame = combatant.frame + 1
			if combatant.frame > 4 then
				combatant.frame = 1
			end
		end
		movement = BESTIARY[combatant.name].speed * delta
		if combatant.x < combatant.dX then
			if combatant.x + movement >= combatant.dX then
				combatant.x = combatant.dX
				combatant.waiting = true
			else
				combatant.x = combatant.x + movement
			end
		elseif combatant.x > combatant.dX then
			if combatant.x - movement <= combatant.dX then
				combatant.x = combatant.dX
				combatant.waiting = true
			else
				combatant.x = combatant.x - movement
			end
		end
		if combatant.y < combatant.dY then
			if combatant.y + movement >= combatant.dY then
				combatant.y = combatant.dY
				combatant.waiting = true
			else
				combatant.y = combatant.y + movement
			end
		elseif combatant.y > combatant.dY then
			if combatant.y - movement <= combatant.dY then
				combatant.y = combatant.dY
				combatant.waiting = true
			else
				combatant.y = combatant.y - movement
			end
		end
		if combatant.waiting and combatant.name == "player" then
			checkLocks()
		end
	end
end

function moveMissile(missile, delta)
	missile.x = missile.x + (VECTORS[missile.facing].x * ARMORY[missile.name].speed * delta)
	missile.y = missile.y + (VECTORS[missile.facing].y * ARMORY[missile.name].speed * delta)
	local centerX = missile.x + TILE_CENTER
	local centerY = missile.y + TILE_CENTER

	-- this is insufficient because it could skip through walls or targets if delta is high enough
	if pointIsObstructed(centerX, centerY, missile.friendly) then
		missile.destroyed = true
	else
		for i, c in ipairs(combatants) do
			if (i == 1 and not missile.friendly) or (i > 1 and missile.friendly) then
				if centerX >= c.x and centerX < c.x + TILE_SIZE and centerY >= c.y and centerY < c.y + TILE_SIZE then
					if i == 1 then
						if not killed then
							killed = true
						end
					else
						takeHits(c, 1)
						awardPoints(BESTIARY[c.name].points)
					end
					missile.destroyed = true
					break
				end
			end
		end
	end
end

function moveBlast(blast, delta)
	blast.time = blast.time + delta
	if blast.time > BLAST_TIME then
		blast.destroyed = true
	end
end

function checkLocks()
	local checkX, checkY
	local mapX, mapY
	for v = 1, 4 do
		checkX = combatants[1].x + (VECTORS[v].x * TILE_SIZE)
		checkY = combatants[1].y + (VECTORS[v].y * TILE_SIZE)
		mapX, mapY = convertToMapCoords(checkX, checkY)
		if mapInfo[mapX][mapY] == 4 then
			mapInfo[mapX][mapY] = 5
			redrawMapTile(mapX, mapY)
			unlocked = unlocked + 1
			awardPoints(LOCK_POINTS)
		end
	end
end
		
function convertToMapCoords(x, y)
	return math.floor(x / TILE_SIZE), math.floor(y / TILE_SIZE)
end

function pointIsObstructed(x, y, fromPlayer)
	local obstructed = false
	local mapX, mapY = convertToMapCoords(x, y)
	if (fromPlayer and (not TERRAIN[mapInfo[mapX][mapY]].playerPass)) or (not fromPlayer and (not TERRAIN[mapInfo[mapX][mapY]].enemyPass)) then
		obstructed = true
	else
		for i, c in ipairs(combatants) do
			if x == c.dX and y == c.dY then
				obstructed = true
				break
			end
		end
	end
	return obstructed
end

function takeHits(combatant, hits)
	combatant.hits = combatant.hits - hits
	if combatant.hits <= 0 then
		combatant.destroyed = true
		makeBlast(combatant.x, combatant.y)
		sounds["boom"]:play()
	end
end

function runEnemyLogic(enemy, delta)
	local rangeX = combatants[1].x - enemy.x
	local rangeY = combatants[1].y - enemy.y
	if enemy.cooling > 0.0 then
		enemy.cooling = enemy.cooling - delta
		if enemy.cooling < 0.0 then
			enemy.cooling = 0.0
		end
	end
	if enemy.name == "spider" then
		-- walker logic
		if enemy.waiting then
			local vX = 0.0
			local vY = 0.0
			local facing = RIGHT_INDEX
			if math.abs(rangeX) + math.abs(rangeY) <= TILE_SIZE then
				killed = true
			else
				if math.abs(rangeX) > math.abs(rangeY) then
					vX = rangeX / math.abs(rangeX)
				else
					vY = rangeY / math.abs(rangeY)
				end
				for f = 1, 4 do
					if vX == VECTORS[f].x and vY == VECTORS[f].y then
						facing = f
					end
				end
				enemy.facing = facing
				local futureX = enemy.x + (vX * TILE_SIZE)
				local futureY = enemy.y + (vY * TILE_SIZE)
				if not pointIsObstructed(futureX, futureY, false) then
					pushCombatant(enemy, facing)
				end
			end
		end
	else
		-- patrolling shooter logic
		if enemy.waiting then
			if math.abs(rangeX) + math.abs(rangeY) <= TILE_SIZE then
				killed = true
			else
				if enemy.cooling == 0.0 then
					local fireFacing
					if math.abs(rangeX) > math.abs(rangeY) then
						if rangeX < 0 then
							fireFacing = LEFT_INDEX
						else
							fireFacing = RIGHT_INDEX
						end
					else
						if rangeY < 0 then
							fireFacing = UP_INDEX
						else
							fireFacing = DOWN_INDEX
						end
					end
					makeMissile(
						enemy.x + VECTORS[fireFacing].x * TILE_SIZE, 
						enemy.y + VECTORS[fireFacing].y * TILE_SIZE,
						fireFacing,
						enemy.name,
						false)
					enemy.cooling = BESTIARY[enemy.name].cooldown	
				end
				enemy.facing = math.random(1, 4)
				local futureX = enemy.x + (VECTORS[enemy.facing].x * TILE_SIZE)
				local futureY = enemy.y + (VECTORS[enemy.facing].y * TILE_SIZE)
				if not pointIsObstructed(futureX, futureY, false) then
					pushCombatant(enemy, enemy.facing)
				end
			end
		end
	end
end

function findVacantSpot(minX, minY, maxX, maxY)
	local searching = true
	local x1 = minX or 1
	local y1 = minY or 1
	local x2 = maxX or MAP_SIZE - 2
	local y2 = maxY or MAP_SIZE - 2
	local tryMapX = math.random(x1, x2)
	local tryMapY = math.random(y1, y2)
	local x = 0
	local y = 0
	while searching do
		x = tryMapX * TILE_SIZE
		y = tryMapY * TILE_SIZE
		if not pointIsObstructed(x, y, false) then
			searching = false
			for i, c in ipairs(combatants) do
				if x == c.x and y == c.y then
					searching = true
					break
				end
			end
		end
		if searching then
			tryMapX = tryMapX + 1
			if tryMapX > maxX then
				tryMapX = minX
				tryMapY = tryMapY + 1
				if tryMapY > minY then
					tryMapY = minY
				end
			end
		end
	end
	return tryMapX, tryMapY
end

function startTitle()
	title = true
	oldReturn = love.keyboard.isDown("return")
end

function startGame()
	level = 1
	lives = STARTING_LIVES
	gameOver = false
	killed = false
	startLevel()
end

function startLevel()
	buildMap()
	mapCanvas:renderTo(drawMap)

	combatants = {}
	makeCombatant(16, 16, "player")
	local mapX, mapY
	for e = 1, 8 + (level * 2) do
		mapX, mapY = findVacantSpot(5, 5, MAP_SIZE - 2, MAP_SIZE - 2)
		makeCombatant(mapX * TILE_SIZE, mapY * TILE_SIZE, "spider")
	end
	for e = 1, 8 + (level * 2) do
		mapX, mapY = findVacantSpot(5, 5, MAP_SIZE - 2, MAP_SIZE - 2)
		makeCombatant(mapX * TILE_SIZE, mapY * TILE_SIZE, "wasp")
	end
	missiles = {}
	blasts = {}
	killed = false
	advancing = false
	locks = 3
	unlocked = 0
end

function awardPoints(points)
	local tenThousands = math.floor(score / 10000)
	score = score + points
	if math.floor(score / 10000) > tenThousands then
		lives = lives + 1
	end
end

function printCenteredText(coloredText, x, y, scale)
	local w = font:getWidth(coloredText[2])
	local h = font:getHeight()
	love.graphics.print(coloredText, x, y, 0, scale, scale, w / 2, h / 2)
end

function resetPlayer()
	combatants[1].x = START_POSITION.x
	combatants[1].y = START_POSITION.y
	combatants[1].dX = START_POSITION.x
	combatants[1].dY = START_POSITION.y
	combatants[1].frame = 1
	combatants[1].animation = 0.0
	combatants[1].waiting = true
	cooldown = 0.0
	blasts = {}
end
