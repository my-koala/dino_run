# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Node

# TODO:
# first things first: recreate the base game
# then add the gun

# on fail, reload map?
# ok im thinking have a single map scene
# and map will load and reinstantiate scenes/levels as needed
# how to communicate to the map to regenerate?
# trex needs to implement regeneration itself somehow...


# somehow need to do some global state, communicating 

# first level is randomly generated generic castus + pteradactyl birds things
# then second level is with gun and randomyl generated
# then boss shit

# how will obstacles/enemies scroll?
# 
# NOTE: do not use CanvasLayer for world stuff/physics (unexpected behavior). use only for gui!!

# TODO: change treadmill to raycast down (physical treadmill; no area)

# TODO: randomize tiles using seed (very low priority)

# TODO: object pooling for obstacles? performance isnt really a concern atm

#@onready var game: Tools.Game = $game as Tools.Game
