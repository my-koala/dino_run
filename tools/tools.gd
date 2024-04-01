# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Object
class_name Tools

# Namespace file for game-specific tools #

# Game #
const Game: = preload("game/scripts/game.gd")
const GameActor: = preload("game/scripts/game_actor.gd")
const GameMap: = preload("game/scripts/game_map.gd")

# Map #
const Map2D: = preload("map/scripts/map_2d.gd")

# Treadmill #
const TreadmillArea2D: = preload("treadmill/scripts/treadmill_area_2d.gd")
const TreadmillCast2D: = preload("treadmill/scripts/treadmill_cast_2d.gd")

# Hit #
const HitGive2D: = preload("hit/scripts/hit_give_2d.gd")
const HitTake2D: = preload("hit/scripts/hit_take_2d.gd")

# Killbox #
const KillArea2D: = preload("kill/scripts/kill_area_2d.gd")
const KillScan2D: = preload("kill/scripts/kill_scan_2d.gd")
