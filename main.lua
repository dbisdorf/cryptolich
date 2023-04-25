-- constants

TILE_SIZE = 16
MAP_SIZE = 32
TILE_CENTER = 8
SCREEN_CENTER = {x = 200, y = 150}
SCREEN_MAX = {x = 400, y = 300}
COLOR_FADE = {1.0, 1.0, 1.0, 0.5}
COLOR_WHITE = {1.0, 1.0, 1.0, 1.0}
COLOR_BLACK = {0.0, 0.0, 0.0, 1.0}
TITLE_TEXT = {{0.5, 0.5, 1.0}, "TOWER OF THE CRYPTOLICH"}
VERSION_TEXT = {{0.4, 0.4, 0.4}, "VERSION 0.3.0"}
START_TEXT = {{0.8, 0.8, 0.8}, "PRESS ENTER TO START\nPRESS Z FOR INSTRUCTIONS\nPRESS X FOR CREDITS\n\nPRESS ESC TO QUIT"}
GAME_OVER_TEXT = {{1.0, 0.2, 0.2}, "GAME OVER"}
UNLOCKED_TEXT = {{0.5, 1.0, 0.5}, "SECURITY UNLOCKED"}
PREPARE_TEXT = {{0.5, 1.0, 0.5}, "PREPARE FOR"}
LEVEL_TEXT = {{0.5, 1.0, 0.5}, "NEXT LEVEL"}
BACK_TEXT = {{0.5, 1.0, 0.5}, "PRESS Z"}
INSTRUCTIONS_TEXT = {{1.0, 1.0, 1.0}, "THE CRYPTOLICH HAS SEIZED CONTROL OF THE WORLD'S TECHNOLOGY.\n\nYOU ARE DELTA, THE ONLY HACKER WITH ENOUGH SKILL TO INFILTRATE THE CRYPTOLICH'S MEGATOWER, CONFRONT ITS CYBERDIGITAL GUARDIANS, AND SAVE HUMANITY.\n\nGOOD LUCK DELTA!\n\nARROW KEYS TO MOVE\nZ TO SHOOT\nX TO HOLD AIM DIRECTION"}
LEFT_CREDITS_TEXT = {{1.0, 1.0, 1.0}, "PROGRAMMING AND ART\n\nENGINE\n\nGRAPHICS\n\nSOUND EFFECTS\n\nFONT"}
RIGHT_CREDITS_TEXT = {{0.7, 0.7, 1.0}, "DON BISDORF\ndonbisdorf.com\nLOVE2D\nlove2d.org\nKRITA\nkrita.org\nCHIPTONE\nsfbgames.itch.io/chiptone\nMx437_IBM_BIOS.ttf\nint10h.org/oldschool-pc-fonts"}
SHOT_COOLDOWN = 0.5
RIGHT_INDEX = 1
DOWN_INDEX = 2
LEFT_INDEX = 3
UP_INDEX = 4
INSUBSTANTIAL = 1000
INVULNERABLE = 999
VECTORS = {{x = 1.0, y = 0.0}, {x = 0.0, y = 1.0}, {x = -1.0, y = 0.0}, {x = 0.0, y = -1.0}}
BESTIARY = {
	["player"] = {speed = 64.0, spf = 0.25, points = 0, cooldown = 0.0, hits = 0},
	["spider"] = {speed = 16.0, spf = 0.2, points = 10, cooldown = 0.0, hits = 1, level1 = 5, eachLevel = 2},
	["wasp"] = {speed = 8.0, spf = 0.05, points = 10, cooldown = 3.0, hits = 1, level1 = 5, eachLevel = 2},
	["turret"] = {speed = 0.0, spf = 0.25, points = 10, cooldown = 10.0, hits = INVULNERABLE, level1 = 5, eachLevel = 2},
	["ghost"] = {speed = 16.0, spf = 0.25, points = 0, cooldown = 0.0, hits = INSUBSTANTIAL, level1 = 1, eachLevel = 0.5}
}
ARMORY = {
	["playerM"] = {speed = 256.0},
	["waspM"] = {speed = 80.0},
	["turretM"] = {speed = 80.0}
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
TICK_TIME = 0.2
DEFAULT_HIGH_SCORE = 10000

-- globals

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
highScore = 0
gameOver = false
locks = 0
unlocked = 0
title = true
instructions = false
credits = false
oldKeys = false
level = 0
stalling = 0.0
advancing = false
startX = 0
startY = 0

-- LOVE callbacks

function love.load()
	-- this is where we initialize
	
	math.randomseed(os.time())

	love.graphics.setDefaultFilter("nearest", "nearest")

	font = love.graphics.newFont("Mx437_IBM_BIOS.ttf", 8, "mono")
	font:setLineHeight(2.0)
	love.graphics.setFont(font)

	textures = love.graphics.newImage("textures.png")

	loadWalkingSprites("player", 0)
	loadWalkingSprites("spider", 16)
	loadWalkingSprites("wasp", 32)
	loadWalkingSprites("turret", 48)
	loadWalkingSprites("ghost", 64)

	loadMissileSprites("playerM", 0, 208)
	loadMissileSprites("waspM", 64, 208)
	loadMissileSprites("turretM", 128, 208)

	spriteQuads["life"] = love.graphics.newQuad(0, 224, TILE_SIZE, TILE_SIZE, textures)
	spriteQuads["blastH"] = love.graphics.newQuad(16, 224, TILE_SIZE, TILE_SIZE, textures)
	spriteQuads["blastV"] = love.graphics.newQuad(32, 224, TILE_SIZE, TILE_SIZE, textures)
	spriteQuads["blastS"] = love.graphics.newQuad(48, 224, TILE_SIZE, TILE_SIZE, textures)

	for t = 1, 6 do
		tileQuads[t] = love.graphics.newQuad((t - 1) * TILE_SIZE, 240, TILE_SIZE, TILE_SIZE, textures)
	end

	mapCanvas = love.graphics.newCanvas(MAP_SIZE * TILE_SIZE, MAP_SIZE * TILE_SIZE)
	spriteBatch = love.graphics.newSpriteBatch(textures, 100)

	sounds["zap"] = love.audio.newSource("zap.wav", "static")
	sounds["boom"] = love.audio.newSource("boom.wav", "static")
	sounds["unlock"] = love.audio.newSource("unlock.wav", "static")
	sounds["level"] = love.audio.newSource("level.wav", "static")

	readHighScore()
end

function love.update(delta)
	local elapsed = delta
	while elapsed > TICK_TIME do
		tick(TICK_TIME)
		elapsed = elapsed - TICK_TIME
	end
	if elapsed > 0.0 then
		tick(elapsed)
	end
end

function love.draw()
	-- this is where we draw
	
	love.graphics.scale(2.0, 2.0)

	if title then
		drawTitle()
	elseif instructions then
		drawInstructions()
	elseif credits then
		drawCredits()
	else
		if gameOver or advancing then
			love.graphics.setColor(COLOR_FADE)
		end
		
		love.graphics.draw(mapCanvas, SCREEN_CENTER.x - combatants[1].x, SCREEN_CENTER.y - combatants[1].y)
		love.graphics.draw(spriteBatch)

		if gameOver then
			love.graphics.setColor(COLOR_WHITE)
			love.graphics.printf(GAME_OVER_TEXT, 0, 150, 200, "center", 0, 2.0, 2.0)
		elseif advancing then
			love.graphics.setColor(COLOR_WHITE)
			love.graphics.printf(UNLOCKED_TEXT, 0, 70, 200, "center", 0, 2.0, 2.0)
			love.graphics.printf(PREPARE_TEXT, 0, 140, 200, "center", 0, 2.0, 2.0)
			love.graphics.printf(LEVEL_TEXT, 0, 210, 200, "center", 0, 2.0, 2.0)
		end

		love.graphics.print(string.format("%06d", score), 0, 4)
		love.graphics.print(string.format("LEVEL %02d", level), 80, 4)
		love.graphics.print(string.format("HIGH %06d", highScore), 220, 4)
	end

	love.graphics.origin()
end

-- other game functions

function tick(delta)
	-- process the maximum allowable game time
	
	if title then
		if oldKeys then
			checkOldKeys()
		else
			if love.keyboard.isDown("return") then
				title = false
				startGame()
			elseif love.keyboard.isDown("escape") then
				love.event.quit(0)
			elseif love.keyboard.isDown("z") then
				title = false
				instructions = true
				checkOldKeys()
			elseif love.keyboard.isDown("x") then
				title = false
				credits = true
				checkOldKeys()
			end
		end
		return
	elseif instructions or credits then
		if oldKeys then
			checkOldKeys()
		else
			if love.keyboard.isDown("z") then
				instructions = false
				credits = false
				title = true
				checkOldKeys()
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
			makeBlast(player.x, player.y, true)
			sounds["boom"]:play()
			lives = lives - 1
			if lives == 0 then
				gameOver = true
				if score > highScore then
					highScore = score
					writeHighScore()
				end
			else
				stalling = STALL_TIME
			end
		elseif unlocked == locks then
			awardPoints(LEVEL_POINTS)
			stalling = STALL_TIME
			advancing = true
			sounds["level"]:play()
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
		if b.big then
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
		else
			spriteBatch:add(
				spriteQuads["blastS"], 
				b.x - player.x + SCREEN_CENTER.x,
				b.y - player.y + SCREEN_CENTER.y)
		end
	end

	for l = 1, lives do
		spriteBatch:add(spriteQuads["life"], SCREEN_MAX.x - (l * TILE_SIZE), 0)
	end
end

function drawTitle()
	love.graphics.printf(TITLE_TEXT, 0, 110, 200, "center", 0, 2.0, 2.0)
	love.graphics.printf(START_TEXT, 0, 180, 400, "center")
	love.graphics.printf(VERSION_TEXT, 0, 280, 400, "center")
end

function drawInstructions()
	love.graphics.printf(INSTRUCTIONS_TEXT, 20, 50, 360, "center")
	love.graphics.printf(BACK_TEXT, 0, 280, 400, "center")
end

function drawCredits()
	love.graphics.printf(LEFT_CREDITS_TEXT, 20, 50, 360, "left")
	love.graphics.printf(RIGHT_CREDITS_TEXT, 20, 50, 360, "right")
	love.graphics.printf(BACK_TEXT, 0, 280, 400, "center")
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

	-- cube farm
	local corner = math.random(1, 4)
	local x1 = math.random(12, 20)
	local x2 = math.random(12, 20)
	local y1 = math.random(12, 20)
	local y2 = math.random(12, 20)
	for x = 0, MAP_SIZE - 1 do
		mapInfo[x] = {}
		for y = 0, MAP_SIZE - 1 do
			if x == 0 or x == MAP_SIZE - 1 or y == 0 or y == MAP_SIZE - 1 then
				-- exterior walls
				mapInfo[x][y] = 2
			elseif (x == x1 and y < 7) or (x == x2 and y > 24) or (y == y1 and x < 7) or (y == y2 and x > 24) or
				(math.abs(x - x1) < 4 and y == 7) or (math.abs(x - x2) < 4 and y == 24) or
				(math.abs(y - y1) < 4 and x == 7) or (math.abs(y - y2) < 4 and x == 24) then
				-- interior walls
				mapInfo[x][y] = 2
			elseif (corner == 1 and x < 4 and y < 4) or
				(corner == 2 and x > 27 and y < 4) or
				(corner == 3 and x < 4 and y > 27) or
				(corner == 4 and x > 27 and y > 27) then
				-- safe starting zone
				mapInfo[x][y] = 6
			elseif (x == 1 and y == 1 and corner ~= 1) or
				(x == 30 and y == 1 and corner ~= 2) or
				(x == 1 and y == 30 and corner ~= 3) or
				(x == 30 and y == 30 and coner ~= 4) then
				-- security servers
				mapInfo[x][y] = 4
			else
				mapInfo[x][y] = 1
			end
		end
	end
	local mapX, mapY
	for o = 1, 12 do
		if o < 5 then
			mapX, mapY = findVacantSpot(2, 2, 29, 6)
		elseif o < 9 then
			mapX, mapY = findVacantSpot(2, 8, 29, 23)
		else
			mapX, mapY = findVacantSpot(2, 5, 29, 29)
		end
		mapInfo[mapX][mapY] = 3
	end
	if corner == 1 then
		startX = TILE_SIZE
		startY = TILE_SIZE
	elseif corner == 2 then
		startX = 30 * TILE_SIZE
		startY = TILE_SIZE
	elseif corner == 3 then
		startX = TILE_SIZE
		startY = 30 * TILE_SIZE
	else
		startX = 30 * TILE_SIZE
		startY = 30 * TILE_SIZE
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
		cooling = math.random() * BESTIARY[name].cooldown,
		hits = BESTIARY[name].hits,
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

function makeBlast(startX, startY, big)
	table.insert(blasts, {
		x = startX,
		y = startY,
		big = big,
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
	local fizzle = false

	-- this is insufficient because it could skip through walls or targets if delta is high enough
	if pointIsObstructed(centerX, centerY, missile.friendly) then
		missile.destroyed = true
		fizzle = true
	else
		for i, c in ipairs(combatants) do
			if (i == 1 and not missile.friendly) or (i > 1 and missile.friendly and c.hits ~= INSUBSTANTIAL) then
				if centerX >= c.x and centerX < c.x + TILE_SIZE and centerY >= c.y and centerY < c.y + TILE_SIZE then
					if i == 1 then
						if not killed then
							killed = true
						end
					else
						takeHits(c, 1)
						if not c.destroyed then
							fizzle = true
						end
					end
					missile.destroyed = true
					break
				end
			end
		end
	end
	if fizzle and missile.friendly then
		makeBlast(missile.x, missile.y, false)
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
			sounds["unlock"]:play()
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
	if BESTIARY[combatant.name].hits ~= INVULNERABLE then
		combatant.hits = combatant.hits - hits
		if combatant.hits <= 0 then
			combatant.destroyed = true
			makeBlast(combatant.x, combatant.y, true)
			sounds["boom"]:play()
			awardPoints(BESTIARY[combatant.name].points)
		end
	end
end

function runEnemyLogic(enemy, delta)
	local rangeX = combatants[1].x - enemy.x
	local rangeY = combatants[1].y - enemy.y
	if enemy.cooling > 0.0 then
		enemy.cooling = enemy.cooling - delta
	end
	if enemy.name == "spider" or enemy.name == "ghost" then
		runEnemyWalkerLogic(enemy, delta, rangeX, rangeY)
	elseif enemy.name == "wasp" then
		runEnemyShooterLogic(enemy, delta, rangeX, rangeY)
	else
		runEnemyTurretLogic(enemy, delta, rangeX, rangeY)
	end
	if BESTIARY[enemy.name].cooldown > 0.0 and enemy.cooling <= 0.0 then
		enemy.cooling = enemy.cooling + BESTIARY[enemy.name].cooldown
	end
end

function runEnemyWalkerLogic(enemy, delta, rangeX, rangeY)
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
			if enemy.hits == INSUBSTANTIAL or not pointIsObstructed(futureX, futureY, false) then
				pushCombatant(enemy, facing)
			end
		end
	end
end

function runEnemyShooterLogic(enemy, delta, rangeX, rangeY)
	if enemy.waiting then
		if math.abs(rangeX) + math.abs(rangeY) <= TILE_SIZE then
			killed = true
		else
			enemy.facing = math.random(1, 4)
			local futureX = enemy.x + (VECTORS[enemy.facing].x * TILE_SIZE)
			local futureY = enemy.y + (VECTORS[enemy.facing].y * TILE_SIZE)
			if not pointIsObstructed(futureX, futureY, false) then
				pushCombatant(enemy, enemy.facing)
			end
		end
	end
	if enemy.cooling <= 0.0 then
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
	end
end

function runEnemyTurretLogic(enemy, delta, rangeX, rangeY)
	if enemy.cooling < 1.0 then
		local i1 = math.floor(enemy.cooling / 0.2)
		local i2 = math.floor((enemy.cooling + delta) / 0.2)
		if i1 ~= i2 then
			for v = 1, 4 do
				makeMissile(
					enemy.x + VECTORS[v].x * TILE_SIZE,
					enemy.y + VECTORS[v].y * TILE_SIZE,
					v, enemy.name, false)
			end
		end
	elseif enemy.cooling < 2.0 then
		enemy.frame = math.floor((enemy.cooling - 1.0) / 0.25) + 1
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

function checkOldKeys()
	oldKeys = love.keyboard.isDown("return") or love.keyboard.isDown("z") or love.keyboard.isDown("x") or love.keyboard.isDown("escape")
end

function startTitle()
	title = true
	checkOldKeys()
end

function startGame()
	score = 0
	level = 1
	lives = STARTING_LIVES
	gameOver = false
	killed = false
	startLevel()
end

function chooseRandomEnemies()
	local keys = {}
	for k in pairs(BESTIARY) do
		if k ~= "player" then
			table.insert(keys, k)
		end
	end
	local chosen = {}
	local r = 0
	while table.getn(chosen) < 3 do
		r = math.random(table.getn(chosen))
		table.insert(chosen, keys[r])
		table.remove(keys, r)
	end
	return chosen
end

function startLevel()
	buildMap()
	mapCanvas:renderTo(drawMap)

	combatants = {}
	makeCombatant(startX, startY, "player")
	local mapX, mapY
	local chosenEnemies = chooseRandomEnemies()
	for i, e in ipairs(chosenEnemies) do
		for n = 1, BESTIARY[e].level1 + math.floor(level * BESTIARY[e].eachLevel) do
			mapX, mapY = findVacantSpot(2, 2, MAP_SIZE - 2, MAP_SIZE - 2)
			makeCombatant(mapX * TILE_SIZE, mapY * TILE_SIZE, e)
		end
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

function resetPlayer()
	combatants[1].x = startX
	combatants[1].y = startY
	combatants[1].dX = startX
	combatants[1].dY = startY
	combatants[1].frame = 1
	combatants[1].animation = 0.0
	combatants[1].waiting = true
	cooldown = 0.0
	blasts = {}
end

function readHighScore()
	local file, ioError
	file, ioError = love.filesystem.newFile("highscore", "r")
	if file then
		local highString, bytes = file:read()
		highScore = tonumber(highString)
		file:close()
	else
		highScore = DEFAULT_HIGH_SCORE
	end
end

function writeHighScore()
	local file, ioError
	file, ioError = love.filesystem.newFile("highscore", "w")
	if file then
		file:write(tostring(highScore))
		file:close()
	end
end

