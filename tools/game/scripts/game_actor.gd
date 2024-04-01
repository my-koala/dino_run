# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Node

signal died()# emit by actor
signal reset_requested()# emit by game

var current_speed: float = 0.0
