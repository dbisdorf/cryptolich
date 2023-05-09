# 0.1.0

[x] Start screen
[x] Decent sprites
[x] Increasing level difficulty
[x] Proper death procedure - jump to start location but maintain enemies
[x] sounds
[x] death VFX
[x] level transition

# 0.2.0

[x] enemy becomes combatants[1] bug
[x] Cube farm level design
[x] random starting corner
[x] turret enemy
[x] random starting cooldowns
[x] video feedback for when missile splashes harmlessly
[x] automatic build

# 0.3.0

[x] Assembly line level
[x] Tank enemy
[x] Sometimes the tank gets stuck? Why?
[x] Visual effect for damaging hit
[x] Implement steps logic for wasps
[x] Gamepad
[x] High score
[x] Death cloud
[x] ghost shouldn't go into safe zone
[x] Random enemy selection
[x] Instructions text
[x] Credits
[x] Controlled exit from title
[x] Explain the digital nature of the fight?
[x] Constrain delta in updates due to this bug?

Error: main.lua:604: attempt to index a nil value
stack traceback:
	[love "boot.lua"]:345: in function '__index'
	main.lua:604: in function 'pointIsObstructed'
	main.lua:545: in function 'moveMissile'
	main.lua:242: in function 'update'
	[love "callbacks.lua"]:162: in function <[love "callbacks.lua"]:144>
	[C]: in function 'xpcall'

# 0.4.0

[x] Boss level, which includes:
[x] Big boss sprite
[x] and its missile
[x] Vulnerable servers
[x] Crawling side turrets
[x] and their missiles
[x] Random tech obstacles
[x] Disappearing shield
[x] Victory text
[x] Boss explosion
[x] Error when advancing past boss level

[x] New sounds (heartbeat, spawn, ?)
[x] Fix player/enemy collision bugs
[x] Better on-screen help
[x] Gamepad and keyboard simultaneously

# 0.5.0

[ ] Rebuild player movement
[ ] Turret missile -> two missiles
[ ] Ghost -> skull
[ ] Rocket launcher robot

# Future features

Level design
- atrium level
More enemies
- Fire trail
More sounds
- Bigger boom for victory explosion
Options
Exit from middle of game? Maybe after prompt?

# Tuning

spiders aren't much of a threat - faster?
text gloss / formatting / color
sound for harmless shot impact?
prevent cube farm level conditions where there's only a single-square gap
i'm no longer as thrilled about grid movement for the player
at least we should allow you to reverse your movement
points for victory
victory fade shouldn't fade hearts
do we really need the strafe key?
safe zone should time out (and/or...)
some sort of deadline to keep you from running a level forever
adjust scores so you could get a bonus life before lvl 10
better startup sound

# Outstanding bugs

cooldowns and other timers should have time ADDED after it hits zero, shouldn't just jump up to full time
pointIsObstructed is incorrect for missiles (could detect obstruction from combatant)

