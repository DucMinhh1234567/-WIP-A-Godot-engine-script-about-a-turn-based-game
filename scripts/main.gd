extends Node

@onready var battle_ui = $BattleUI

## Called when the node enters the scene tree
## Creates player and enemy teams and starts the battle
func _ready():
	# Create player team
	var player_team = [
		BattleCharacter.new("Warrior", BattleCharacter.CharacterType.FIGHTER, 120, 18, 12, 8),
		BattleCharacter.new("Mage", BattleCharacter.CharacterType.MAGE, 90, 25, 6, 7),
		BattleCharacter.new("Archer", BattleCharacter.CharacterType.ARCHER, 100, 15, 8, 12),
		BattleCharacter.new("Tank", BattleCharacter.CharacterType.TANK, 150, 10, 20, 5),
		BattleCharacter.new("Buffer", BattleCharacter.CharacterType.BUFFER, 80, 8, 8, 9)
	]
	
	# Create enemy team with various monster types
	var enemy_team = [
		# Normal Monsters
		BattleCharacter.new("Goblin", BattleCharacter.CharacterType.NORMAL_MONSTER, 60, 12, 5, 10, true),
		BattleCharacter.new("Skeleton", BattleCharacter.CharacterType.NORMAL_MONSTER, 70, 10, 8, 8, true),
		BattleCharacter.new("Orc", BattleCharacter.CharacterType.NORMAL_MONSTER, 100, 15, 10, 6, true),
		
		# Elite Monsters
		BattleCharacter.new("Elite Goblin Shaman", BattleCharacter.CharacterType.ELITE_MONSTER, 120, 20, 12, 9, true),
		BattleCharacter.new("Skeleton Knight", BattleCharacter.CharacterType.ELITE_MONSTER, 150, 18, 15, 7, true),
		
		# Boss Monster
		BattleCharacter.new("Ancient Dragon", BattleCharacter.CharacterType.BOSS_MONSTER, 300, 30, 25, 10, true)
	]
	
	# Add characters to their respective groups
	for character in player_team:
		character.add_to_group("player_team")
	
	for character in enemy_team:
		character.add_to_group("enemy_team")
	
	# Start the battle
	battle_ui.start_battle(player_team, enemy_team) 