extends Control

@onready var battle_manager = $BattleManager
@onready var action_buttons = $ActionButtons
@onready var target_buttons = $TargetButtons
@onready var battle_log = $BattleLog
@onready var character_info = $CharacterInfo

var current_character: BattleCharacter
var selected_target: BattleCharacter

## Called when the node enters the scene tree
## Sets up signal connections and initial UI state
func _ready():
	# Connect battle manager signals
	battle_manager.battle_ended.connect(_on_battle_ended)
	
	# Hide target selection initially
	target_buttons.hide()
	
	# Connect action buttons
	for button in action_buttons.get_children():
		button.pressed.connect(_on_action_button_pressed.bind(button.name))

## Starts a new battle and initializes the UI
## Parameters:
## - player_team: Array of player team characters
## - enemy_team: Array of enemy team characters
func start_battle(player_team: Array[BattleCharacter], enemy_team: Array[BattleCharacter]):
	battle_manager.start_battle(player_team, enemy_team)
	update_ui()

## Updates all UI elements to reflect current battle state
## Updates character info, action buttons visibility, and battle log
func update_ui():
	current_character = battle_manager.get_current_character()
	
	# Update character info display
	update_character_info()
	
	# Show/hide action buttons based on whether it's player's turn
	action_buttons.visible = current_character in battle_manager.player_team
	
	# Update battle log
	add_to_battle_log("It's " + current_character.character_name + "'s turn!")

## Updates the character info display with current HP values
## Shows HP for all characters in both teams
func update_character_info():
	var info_text = ""
	for character in battle_manager.player_team + battle_manager.enemy_team:
		info_text += "%s: HP %d/%d\n" % [
			character.character_name,
			character.current_hp,
			character.max_hp
		]
	character_info.text = info_text

## Handles action button presses
## Shows target selection for attacks or advances turn for other actions
## Parameters:
## - action: String name of the action button pressed
func _on_action_button_pressed(action: String):
	if action == "normal_attack" or action == "skill" or action == "ultimate":
		show_target_selection()
	else:
		battle_manager.next_turn()
		update_ui()

## Shows the target selection UI with buttons for each valid target
## Creates dynamic buttons for each available target
func show_target_selection():
	target_buttons.show()
	var targets = battle_manager.get_available_targets(current_character)
	
	# Clear existing target buttons
	for child in target_buttons.get_children():
		child.queue_free()
	
	# Create new target buttons
	for target in targets:
		var button = Button.new()
		button.text = target.character_name
		button.pressed.connect(_on_target_selected.bind(target))
		target_buttons.add_child(button)

## Handles target selection and executes the attack
## Parameters:
## - target: The selected target character
func _on_target_selected(target: BattleCharacter):
	target_buttons.hide()
	selected_target = target
	
	# Use the selected skill
	var result = current_character.use_skill("normal_attack", target)
	add_to_battle_log(result.message)
	
	# Update UI and move to next turn
	update_character_info()
	battle_manager.next_turn()
	update_ui()

## Adds a message to the battle log and scrolls to the bottom
## Parameters:
## - message: The message to add to the log
func add_to_battle_log(message: String):
	battle_log.text += message + "\n"
	# Scroll to bottom
	battle_log.scroll_vertical = battle_log.get_v_scroll_bar().max_value

## Handles battle end by updating UI and showing winner
## Parameters:
## - winner: String indicating which team won
func _on_battle_ended(winner: String):
	action_buttons.hide()
	target_buttons.hide()
	add_to_battle_log("Battle ended! " + winner.capitalize() + " team wins!") 