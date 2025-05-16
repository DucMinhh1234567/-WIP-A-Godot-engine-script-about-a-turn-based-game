extends Node

signal battle_ended(winner_team: String)

var player_team: Array[BattleCharacter] = []
var enemy_team: Array[BattleCharacter] = []
var turn_order: Array[BattleCharacter] = []
var current_turn_index: int = 0
var current_character: BattleCharacter
var is_battle_active: bool = false

## Called when the node enters the scene tree
## Initializes random number generator for battle calculations
func _ready():
	randomize()

## Starts a new battle with the given player and enemy teams
## Parameters:
## - player_characters: Array of player team characters
## - enemy_characters: Array of enemy team characters
func start_battle(player_characters: Array[BattleCharacter], enemy_characters: Array[BattleCharacter]):
	player_team = player_characters
	enemy_team = enemy_characters
	is_battle_active = true
	
	# Initialize turn order based on speed
	initialize_turn_order()
	current_turn_index = 0
	current_character = turn_order[0]
	
	print("Battle started!")

## Initializes the turn order based on character speeds
## Characters with higher speed will go first
func initialize_turn_order():
	turn_order.clear()
	turn_order.append_array(player_team)
	turn_order.append_array(enemy_team)
	
	# Sort by speed (higher speed goes first)
	turn_order.sort_custom(func(a, b): return a.get_speed() > b.get_speed())

## Advances to the next character's turn
## Updates cooldowns and skips dead characters
func next_turn():
	if not is_battle_active:
		return
	
	# Update cooldowns for current character
	current_character.update_cooldowns()
	
	# Move to next character
	current_turn_index = (current_turn_index + 1) % turn_order.size()
	current_character = turn_order[current_turn_index]
	
	# Skip dead characters
	while not current_character.is_available():
		current_turn_index = (current_turn_index + 1) % turn_order.size()
		current_character = turn_order[current_turn_index]
	
	check_battle_end()

## Checks if the battle has ended by checking if either team is completely defeated
## Emits battle_ended signal if a winner is determined
func check_battle_end():
	var player_alive = false
	var enemy_alive = false
	
	for character in player_team:
		if character.is_available():
			player_alive = true
			break
	
	for character in enemy_team:
		if character.is_available():
			enemy_alive = true
			break
	
	if not player_alive:
		end_battle("enemy")
	elif not enemy_alive:
		end_battle("player")

## Ends the battle and emits the battle_ended signal
## Parameters:
## - winner: String indicating which team won ("player" or "enemy")
func end_battle(winner: String):
	is_battle_active = false
	emit_signal("battle_ended", winner)
	print("Battle ended! Winner: " + winner)

## Gets the character whose turn it currently is
## Returns: The current BattleCharacter
func get_current_character() -> BattleCharacter:
	return current_character

## Gets all available targets for the given attacker
## Parameters:
## - attacker: The character performing the attack
## Returns: Array of valid target characters
func get_available_targets(attacker: BattleCharacter) -> Array[BattleCharacter]:
	var targets: Array[BattleCharacter] = []
	var target_team = enemy_team if attacker in player_team else player_team
	
	for character in target_team:
		if character.is_available():
			targets.append(character)
	
	return targets 