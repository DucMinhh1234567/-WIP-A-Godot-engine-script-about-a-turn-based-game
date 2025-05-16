extends CharacterBody2D

class_name BattleCharacter

enum CharacterType {
	# Player Team Types
	FIGHTER,
	MAGE,
	ARCHER,
	TANK,
	BUFFER,
	HEALER,
	DEBUFFER,
	SPECIAL,
	
	# Enemy Types
	NORMAL_MONSTER,
	ELITE_MONSTER,
	BOSS_MONSTER
}

# Character stats
var character_name: String
var character_type: CharacterType
var max_hp: int
var current_hp: int
var attack: int
var defense: int
var speed: int
var is_enemy: bool = false

# Aggro system
var base_aggro: float = 1.0  # Base aggro value
var current_aggro: float = 1.0  # Current aggro value (can be modified by effects)
var aggro_modifier: float = 1.0  # Multiplier for aggro changes

# Resource systems
var max_skill_points: int = 5
var current_skill_points: int = 3
var max_energy: int = 100  # Default max energy
var current_energy: int = 0

# Energy gain values
const ENERGY_GAIN_NORMAL_ATTACK = 20
const ENERGY_GAIN_SKILL_ATTACK = 30
const ENERGY_GAIN_LIGHT_HIT = 5
const ENERGY_GAIN_HEAVY_HIT = 10

# Special stats
var healing_power: int = 0
var buff_power: int = 0
var debuff_power: int = 0
var effect_hit_rate: float = 0.0  # Base effect hit rate
var effect_resistance: float = 0.0  # Base effect resistance

# Support skill stats
var single_heal_power: int = 0  # Power for single target heal
var mass_heal_power: int = 0    # Power for mass heal
var single_buff_power: int = 0  # Power for single target buff
var mass_buff_power: int = 0    # Power for mass buff
var single_debuff_power: int = 0 # Power for single target debuff
var mass_debuff_power: int = 0  # Power for mass debuff
var buff_duration: int = 2      # Default buff duration
var debuff_duration: int = 2    # Default debuff duration
var ultimate_buff_duration: int = 3  # Ultimate buff duration
var ultimate_debuff_duration: int = 3 # Ultimate debuff duration

# Critical hit stats
var crit_rate: float = 0.05  # Base 5% crit rate
var crit_damage: float = 0.50  # Base 50% crit damage

# Add new tank-specific stats
var taunt_duration: int = 2      # Duration for taunt effect
var shield_power: int = 0        # Power for shield effect
var counter_damage: int = 0      # Damage for counter attacks

# Skills
var skills = {
	"normal_attack": {
		"name": "Normal Attack",
		"damage_multiplier": 1.0,
		"skill_point_cost": 0,  # No cost for basic attack
		"energy_cost": 0,  # No energy cost
		"description": "Basic attack",
		"base_effect_chance": 0.0,  # No effect for normal attack
		"hit_count": 1,  # Single hit
		"target_pattern": "single",  # single, adjacent, all, bounce
		"bounce_count": 0,  # Number of bounces for bounce pattern
		"scaling_attribute": "attack",  # attack, defense, etc.
		"extra_multiplier": 0.0,  # Additional multiplier from special conditions
		"extra_damage": 0  # Flat damage added after scaling
	},
	"skill": {
		"name": "Special Skill",
		"damage_multiplier": 1.5,
		"skill_point_cost": 1,  # Costs 1 skill point
		"energy_cost": 0,  # No energy cost
		"description": "Special attack",
		"base_effect_chance": 0.63,  # 63% base chance for effects
		"hit_count": 1,  # Single hit
		"target_pattern": "single",
		"bounce_count": 0,
		"scaling_attribute": "attack",
		"extra_multiplier": 0.0,
		"extra_damage": 0
	},
	"ultimate": {
		"name": "Ultimate",
		"damage_multiplier": 2.5,
		"skill_point_cost": 0,  # No skill point cost
		"energy_cost": 100,  # Full energy cost
		"description": "Ultimate attack",
		"base_effect_chance": 0.80,  # 80% base chance for effects
		"hit_count": 1,  # Single hit
		"target_pattern": "single",
		"bounce_count": 0,
		"scaling_attribute": "attack",
		"extra_multiplier": 0.0,
		"extra_damage": 0
	}
}

# Battle state
var is_alive: bool = true
var is_selected: bool = false
var active_buffs: Dictionary = {}
var active_debuffs: Dictionary = {}

# Equipment system
enum EquipmentSlot {
	HELMET,      # Mũ
	GLOVES,      # Găng tay
	ARMOR,       # Áo giáp
	BOOTS,       # Giày
	MAGIC_GEM,   # Ngọc phép thuật
	MAGIC_NECKLACE # Dây chuyền phép thuật
}

enum EquipmentMainStat {
	# Chỉ số chính
	FLAT_ATTACK,     # Tăng tấn công theo số
	FLAT_HP,         # Tăng máu theo số
	PERCENT_ATTACK,  # Tăng tấn công theo %
	PERCENT_HP,      # Tăng máu theo %
	PERCENT_DEFENSE, # Tăng phòng thủ theo %
	EFFECT_HIT_RATE, # Tăng tỉ lệ trúng hiệu ứng
	CRIT_RATE,       # Tăng tỉ lệ chí mạng
	CRIT_DAMAGE,     # Tăng sát thương chí mạng
	SPEED,           # Tăng tốc độ theo số
	SHIELD_POWER,    # Tăng lượng khiên cung cấp theo %
	HEALING_POWER,   # Tăng lượng hồi máu theo %
	ENERGY_EFFICIENCY # Tăng hiệu suất hồi năng lượng
}

class Equipment:
	var slot: EquipmentSlot
	var main_stat: EquipmentMainStat
	var main_stat_value: float
	var sub_stats: Array  # Sẽ thêm 4 chỉ số phụ sau
	var set_bonus: String  # Sẽ thêm bonus set sau
	
	func _init(slot_type: EquipmentSlot, stat: EquipmentMainStat, value: float):
		slot = slot_type
		main_stat = stat
		main_stat_value = value
		sub_stats = []

# Character equipment
var equipment: Dictionary = {
	EquipmentSlot.HELMET: null,
	EquipmentSlot.GLOVES: null,
	EquipmentSlot.ARMOR: null,
	EquipmentSlot.BOOTS: null,
	EquipmentSlot.MAGIC_GEM: null,
	EquipmentSlot.MAGIC_NECKLACE: null
}

# Equipment stat modifiers
var equipment_stats = {
	"flat_attack": 0,
	"flat_hp": 0,
	"percent_attack": 0.0,
	"percent_hp": 0.0,
	"percent_defense": 0.0,
	"effect_hit_rate": 0.0,
	"crit_rate": 0.0,
	"crit_damage": 0.0,
	"speed": 0,
	"shield_power": 0.0,
	"healing_power": 0.0,
	"energy_efficiency": 0.0
}

## Initializes a new battle character with basic stats and type
## Parameters:
## - name: The character's name
## - type: The character's type (from CharacterType enum)
## - hp: Maximum health points
## - atk: Attack power
## - def: Defense value
## - spd: Speed value
## - enemy: Whether this character is an enemy (default: false)
func _init(name: String, type: CharacterType, hp: int, atk: int, def: int, spd: int, enemy: bool = false):
	character_name = name
	character_type = type
	max_hp = hp
	current_hp = hp
	attack = atk
	defense = def
	speed = spd
	is_enemy = enemy
	
	# Set up character-specific skills and stats
	match type:
		CharacterType.FIGHTER:
			skills["skill"]["name"] = "Heavy Strike"
			skills["ultimate"]["name"] = "Berserker Rage"
			skills["skill"]["hit_count"] = 2  # Double hit
			skills["ultimate"]["hit_count"] = 3  # Triple hit
			skills["skill"]["target_pattern"] = "adjacent"  # Hits target and adjacent enemies
			skills["ultimate"]["target_pattern"] = "all"  # Hits all enemies
			skills["skill"]["damage_multiplier"] = 1.8  # Higher multiplier for heavy strike
			skills["ultimate"]["damage_multiplier"] = 2.2  # Slightly lower multiplier but hits all
			skills["skill"]["extra_damage"] = 10  # Extra flat damage
			skills["ultimate"]["extra_damage"] = 20  # More extra damage for ultimate
			crit_rate = 0.15  # 15% crit rate
			crit_damage = 0.75  # 75% crit damage
			max_energy = 120  # Higher max energy for aggressive playstyle
			base_aggro = 1.3  # Increased from 1.2
		CharacterType.MAGE:
			skills["skill"]["name"] = "Fireball"
			skills["ultimate"]["name"] = "Meteor Storm"
			skills["skill"]["hit_count"] = 1
			skills["ultimate"]["hit_count"] = 5
			skills["skill"]["target_pattern"] = "bounce"
			skills["skill"]["bounce_count"] = 2  # Bounces to 2 additional targets
			skills["ultimate"]["target_pattern"] = "all"
			skills["skill"]["damage_multiplier"] = 2.0  # High multiplier for single target
			skills["ultimate"]["damage_multiplier"] = 1.8  # Lower multiplier but hits all 5 times
			skills["skill"]["extra_multiplier"] = 0.2  # Extra multiplier for each bounce
			skills["ultimate"]["extra_multiplier"] = 0.3  # Extra multiplier for ultimate
			crit_rate = 0.10
			crit_damage = 1.00
			max_energy = 150  # Highest max energy for powerful ultimates
			base_aggro = 0.9  # Increased from 0.8
		CharacterType.ARCHER:
			skills["skill"]["name"] = "Precise Shot"
			skills["ultimate"]["name"] = "Arrow Storm"
			skills["skill"]["hit_count"] = 3
			skills["ultimate"]["hit_count"] = 7
			skills["skill"]["target_pattern"] = "single"
			skills["ultimate"]["target_pattern"] = "all"
			skills["skill"]["damage_multiplier"] = 1.2  # Lower multiplier but hits 3 times
			skills["ultimate"]["damage_multiplier"] = 1.5  # Lower multiplier but hits 7 times
			skills["skill"]["extra_multiplier"] = 0.1  # Extra multiplier for each hit
			skills["ultimate"]["extra_multiplier"] = 0.15  # Extra multiplier for each hit
			crit_rate = 0.20
			crit_damage = 0.60
			max_energy = 100  # Standard max energy
			base_aggro = 0.7  # Decreased from 0.9
		CharacterType.TANK:
			skills["skill"]["name"] = "Shield Wall"
			skills["ultimate"]["name"] = "Iron Fortress"
			skills["skill"]["hit_count"] = 1
			skills["ultimate"]["hit_count"] = 1
			skills["skill"]["damage_multiplier"] = 0.0
			skills["ultimate"]["damage_multiplier"] = 0.0
			skills["skill"]["extra_multiplier"] = 0.0
			skills["ultimate"]["extra_multiplier"] = 0.0
			
			# Tank specific stats
			shield_power = 30           # Shield amount for skill
			taunt_duration = 2         # Taunt duration for skill
			counter_damage = 20        # Counter damage for ultimate
			effect_hit_rate = 0.8      # 80% effect hit rate for taunt
			crit_rate = 0.05
			crit_damage = 0.50
			max_energy = 80   # Lower max energy but gains more from being hit
			base_aggro = 1.5  # Kept highest
		CharacterType.BUFFER:
			skills["skill"]["name"] = "Team Boost"
			skills["ultimate"]["name"] = "Battle Cry"
			skills["skill"]["hit_count"] = 1
			skills["ultimate"]["hit_count"] = 1
			skills["skill"]["damage_multiplier"] = 0.0
			skills["ultimate"]["damage_multiplier"] = 0.0
			skills["skill"]["extra_multiplier"] = 0.0
			skills["ultimate"]["extra_multiplier"] = 0.0
			
			# Buffer specific stats
			single_buff_power = 20    # Normal buff power
			mass_buff_power = 15      # Mass buff power (slightly lower per target)
			buff_duration = 2         # Normal buff duration
			ultimate_buff_duration = 3 # Ultimate buff duration
			effect_hit_rate = 0.2     # 20% extra effect hit rate for buffs
			
			crit_rate = 0.05
			crit_damage = 0.50
			max_energy = 90   # Slightly lower max energy
			base_aggro = 1.1  # Increased from 0.7
		CharacterType.HEALER:
			skills["skill"]["name"] = "Healing Light"
			skills["ultimate"]["name"] = "Mass Heal"
			skills["skill"]["hit_count"] = 1
			skills["ultimate"]["hit_count"] = 1
			skills["skill"]["damage_multiplier"] = 0.0
			skills["ultimate"]["damage_multiplier"] = 0.0
			skills["skill"]["extra_multiplier"] = 0.0
			skills["ultimate"]["extra_multiplier"] = 0.0
			
			# Healer specific stats
			single_heal_power = 30    # Normal heal power
			mass_heal_power = 20      # Mass heal power (slightly lower per target)
			healing_power = single_heal_power  # For compatibility
			
			crit_rate = 0.05
			crit_damage = 0.50
			max_energy = 110  # Higher max energy for emergency heals
			base_aggro = 1.2  # Increased from 0.6
		CharacterType.DEBUFFER:
			skills["skill"]["name"] = "Weaken"
			skills["ultimate"]["name"] = "Curse"
			skills["skill"]["hit_count"] = 1
			skills["ultimate"]["hit_count"] = 1
			skills["skill"]["damage_multiplier"] = 0.0
			skills["ultimate"]["damage_multiplier"] = 0.0
			skills["skill"]["extra_multiplier"] = 0.0
			skills["ultimate"]["extra_multiplier"] = 0.0
			
			# Debuffer specific stats
			single_debuff_power = 20   # Normal debuff power
			mass_debuff_power = 15     # Mass debuff power (slightly lower per target)
			debuff_duration = 2        # Normal debuff duration
			ultimate_debuff_duration = 3 # Ultimate debuff duration
			effect_hit_rate = 0.96     # 96% effect hit rate for debuffs
			
			crit_rate = 0.05
			crit_damage = 0.50
			max_energy = 100  # Standard max energy
			base_aggro = 1.0  # Increased from 0.8
		CharacterType.SPECIAL:
			skills["skill"]["name"] = "Special Move"
			skills["ultimate"]["name"] = "Unique Ability"
			skills["skill"]["hit_count"] = 1  # Single hit
			skills["ultimate"]["hit_count"] = 1  # Single hit
			skills["skill"]["damage_multiplier"] = 1.5  # Balanced multiplier
			skills["ultimate"]["damage_multiplier"] = 2.0  # Balanced ultimate multiplier
			crit_rate = 0.05  # 5% crit rate
			crit_damage = 0.50  # 50% crit damage
		CharacterType.NORMAL_MONSTER:
			skills["skill"]["name"] = "Monster Attack"
			skills["ultimate"]["name"] = "Frenzy"
			skills["skill"]["hit_count"] = 1  # Single hit
			skills["ultimate"]["hit_count"] = 2  # Double hit
			skills["skill"]["damage_multiplier"] = 1.3  # Basic monster skill
			skills["ultimate"]["damage_multiplier"] = 1.6  # Basic monster ultimate
			skills["skill"]["target_pattern"] = "adjacent"  # Hits target and adjacent enemies
			skills["ultimate"]["target_pattern"] = "single"  # Ultimate hits single target
			effect_resistance = 0.40  # 40% effect resistance for normal monsters
		CharacterType.ELITE_MONSTER:
			skills["skill"]["name"] = "Elite Ability"
			skills["ultimate"]["name"] = "Elite Ultimate"
			skills["skill"]["hit_count"] = 2  # Double hit
			skills["ultimate"]["hit_count"] = 3  # Triple hit
			skills["skill"]["damage_multiplier"] = 1.5  # Stronger elite skill
			skills["ultimate"]["damage_multiplier"] = 1.8  # Stronger elite ultimate
			skills["skill"]["extra_damage"] = 10  # Extra damage for elite
			skills["ultimate"]["extra_damage"] = 20  # More extra damage for elite ultimate
			skills["skill"]["target_pattern"] = "bounce"  # Skill bounces between targets
			skills["skill"]["bounce_count"] = 2  # Bounces to 2 additional targets
			skills["ultimate"]["target_pattern"] = "adjacent"  # Ultimate hits target and adjacent
			effect_resistance = 0.60  # 60% effect resistance for elite monsters
		CharacterType.BOSS_MONSTER:
			skills["skill"]["name"] = "Boss Ability"
			skills["ultimate"]["name"] = "Boss Ultimate"
			skills["skill"]["hit_count"] = 3  # Triple hit
			skills["ultimate"]["hit_count"] = 5  # Five hits
			skills["skill"]["damage_multiplier"] = 1.7  # Powerful boss skill
			skills["ultimate"]["damage_multiplier"] = 2.0  # Powerful boss ultimate
			skills["skill"]["extra_damage"] = 20  # High extra damage for boss
			skills["ultimate"]["extra_damage"] = 40  # Very high extra damage for boss ultimate
			skills["skill"]["target_pattern"] = "all"  # Skill hits all enemies
			skills["ultimate"]["target_pattern"] = "all"  # Ultimate hits all enemies
			effect_resistance = 0.80  # 80% effect resistance for boss monsters

	current_aggro = base_aggro

## Calculates the chance of an effect (like debuff) being applied to a target
## Parameters:
## - skill_name: Name of the skill being used
## - target: The target character
## Returns: Float between 0 and 1 representing the chance of effect being applied
func calculate_effect_chance(skill_name: String, target: BattleCharacter) -> float:
	var skill = skills[skill_name]
	var base_chance = skill["base_effect_chance"]
	
	# Apply the formula: Real Chance = Base Chance × (1 + Effect Hit Rate) × (1 − Effect RES)
	var real_chance = base_chance * (1.0 + effect_hit_rate) * (1.0 - target.effect_resistance)
	
	# Ensure chance is between 0 and 1
	return clamp(real_chance, 0.0, 1.0)

## Calculates the damage for an attack, including critical hit chance
## Parameters:
## - base_damage: The base damage value before crit calculation
## Returns: Dictionary containing final damage and whether it was a critical hit
func calculate_damage(base_damage: int) -> Dictionary:
	var is_crit = false
	var final_damage = base_damage
	
	# Only player team members can crit
	if not is_enemy:
		var rand = randf()
		if rand <= crit_rate:
			is_crit = true
			final_damage = int(base_damage * (1.0 + crit_damage))
	
	return {
		"damage": final_damage,
		"is_crit": is_crit
	}

## Applies damage to the character and handles death state
## Parameters:
## - amount: The amount of damage to take
## Returns: The actual damage taken after defense calculation
func take_damage(amount: int) -> int:
	var actual_damage = max(1, amount - defense)
	current_hp = max(0, current_hp - actual_damage)
	
	# Gain energy when taking damage
	if not is_enemy:  # Only player characters gain energy from taking damage
		var energy_gain = ENERGY_GAIN_LIGHT_HIT
		if amount > defense * 2:  # Consider it a heavy hit if damage is more than double defense
			energy_gain = ENERGY_GAIN_HEAVY_HIT
		gain_energy(energy_gain)
	
	if current_hp <= 0:
		is_alive = false
	return actual_damage

## Heals the character up to their maximum HP
## Parameters:
## - amount: The amount of healing to apply
## Returns: The actual amount of healing applied
func heal(amount: int) -> int:
	var actual_heal = min(amount, max_hp - current_hp)
	current_hp = min(max_hp, current_hp + actual_heal)
	return actual_heal

## Applies a buff to the character that lasts for a duration
## Parameters:
## - stat: The stat to buff (e.g., "attack", "defense")
## - value: The amount to increase the stat by
## - duration: Number of turns the buff lasts
func apply_buff(stat: String, value: int, duration: int):
	active_buffs[stat] = {"value": value, "duration": duration}

## Applies a debuff to the character that lasts for a duration
## Parameters:
## - stat: The stat to debuff (e.g., "attack", "defense")
## - value: The amount to decrease the stat by
## - duration: Number of turns the debuff lasts
func apply_debuff(stat: String, value: int, duration: int):
	if stat == "taunt":
		# Increase aggro when taunted
		current_aggro *= 2.0  # Double aggro when taunted
		active_debuffs[stat] = {"value": value, "duration": duration}
	else:
		active_debuffs[stat] = {"value": value, "duration": duration}

## Updates the duration of all active buffs and debuffs, removing expired ones
func update_buffs_and_debuffs():
	# Update buffs
	for stat in active_buffs.keys():
		active_buffs[stat]["duration"] -= 1
		if active_buffs[stat]["duration"] <= 0:
			active_buffs.erase(stat)
	
	# Update debuffs
	for stat in active_debuffs.keys():
		active_debuffs[stat]["duration"] -= 1
		if active_debuffs[stat]["duration"] <= 0:
			if stat == "taunt":
				# Reset aggro when taunt expires
				current_aggro = base_aggro
			active_debuffs.erase(stat)

## Calculates the base damage for a skill using the formula:
## Base DMG = (Skill Multiplier + Extra Multiplier) × Scaling Attribute + Extra DMG
## Parameters:
## - skill_name: Name of the skill being used
## Returns: Integer representing the base damage value
func calculate_base_damage(skill_name: String) -> int:
	var skill = skills[skill_name]
	var scaling_value = 0
	
	# Get the scaling attribute value
	match skill["scaling_attribute"]:
		"attack":
			scaling_value = attack
		"defense":
			scaling_value = defense
		# Add more attributes as needed
	
	# Calculate base damage using the formula:
	# Base DMG = (Skill Multiplier + Extra Multiplier) × Scaling Attribute + Extra DMG
	var total_multiplier = skill["damage_multiplier"] + skill["extra_multiplier"]
	var base_damage = int(total_multiplier * scaling_value) + skill["extra_damage"]
	
	# Divide damage by hit count to distribute damage across hits
	return int(base_damage / skill["hit_count"])

## Gets all valid targets for a skill based on its targeting pattern
## Parameters:
## - skill_name: Name of the skill being used
## - primary_target: The main target of the skill
## Returns: Array of valid target characters
func get_targets(skill_name: String, primary_target: BattleCharacter) -> Array:
	var skill = skills[skill_name]
	var targets = []
	
	match skill["target_pattern"]:
		"single":
			targets.append(primary_target)
		"adjacent":
			# Get all enemies and find adjacent ones
			var all_enemies = get_tree().get_nodes_in_group("enemy_team" if not is_enemy else "player_team")
			var primary_index = all_enemies.find(primary_target)
			if primary_index != -1:
				targets.append(primary_target)
				if primary_index > 0:
					targets.append(all_enemies[primary_index - 1])
				if primary_index < all_enemies.size() - 1:
					targets.append(all_enemies[primary_index + 1])
		"all":
			# Get all enemies
			targets = get_tree().get_nodes_in_group("enemy_team" if not is_enemy else "player_team")
		"bounce":
			# For bounce pattern, ignore aggro and select random targets
			targets.append(primary_target)
			var remaining_targets = get_tree().get_nodes_in_group("enemy_team" if not is_enemy else "player_team")
			remaining_targets.erase(primary_target)
			
			# Add bounce targets randomly
			for i in range(skill["bounce_count"]):
				if remaining_targets.size() > 0:
					var random_index = randi() % remaining_targets.size()
					targets.append(remaining_targets[random_index])
					remaining_targets.remove_at(random_index)
	
	return targets

## Adds energy to the character's current energy pool
## Parameters:
## - amount: Amount of energy to add
## Returns: The actual amount of energy gained (may be less if at max)
func gain_energy(amount: int) -> int:
	var old_energy = current_energy
	current_energy = min(max_energy, current_energy + amount)
	var actual_gain = current_energy - old_energy
	if actual_gain > 0:
		print("%s gained %d energy! (Current: %d/%d)" % [character_name, actual_gain, current_energy, max_energy])
	return actual_gain

## Adds skill points to the character's current skill point pool
## Parameters:
## - amount: Amount of skill points to add (default: 1)
## Returns: The actual amount of skill points gained (may be less if at max)
func gain_skill_point(amount: int = 1) -> int:
	var old_points = current_skill_points
	current_skill_points = min(max_skill_points, current_skill_points + amount)
	return current_skill_points - old_points

## Uses a skill on a target, handling resource costs, damage calculation, and effects
## Parameters:
## - skill_name: Name of the skill to use
## - target: The target character
## Returns: Dictionary containing success status and result message
func use_skill(skill_name: String, target: BattleCharacter) -> Dictionary:
	if not skills.has(skill_name):
		return {"success": false, "message": "Invalid skill"}
	
	var skill = skills[skill_name]
	
	# Check resource costs
	if skill["skill_point_cost"] > current_skill_points:
		return {"success": false, "message": "Not enough skill points"}
	if skill["energy_cost"] > current_energy:
		return {"success": false, "message": "Not enough energy"}
	
	var result = {"success": true, "message": ""}
	
	# Consume resources
	current_skill_points -= skill["skill_point_cost"]
	current_energy -= skill["energy_cost"]
	
	# Gain energy from attacks (only for player characters)
	if not is_enemy:
		if skill_name == "normal_attack":
			gain_energy(ENERGY_GAIN_NORMAL_ATTACK)
		elif skill_name == "skill":
			gain_energy(ENERGY_GAIN_SKILL_ATTACK)
	
	match character_type:
		CharacterType.HEALER:
			if skill_name == "skill":
				var heal_amount = single_heal_power
				var actual_heal = target.heal(heal_amount)
				result.message = "%s used %s on %s, healing for %d HP!" % [character_name, skill["name"], target.character_name, actual_heal]
			elif skill_name == "ultimate":
				# Mass heal all allies
				var heal_amount = mass_heal_power
				var total_heal = 0
				for ally in get_tree().get_nodes_in_group("player_team"):
					if ally.is_available():
						total_heal += ally.heal(heal_amount)
				result.message = "%s used %s, healing all allies for %d total HP!" % [character_name, skill["name"], total_heal]
		CharacterType.BUFFER:
			if skill_name == "skill":
				target.apply_buff("attack", single_buff_power, buff_duration)
				result.message = "%s used %s on %s, increasing their attack by %d for %d turns!" % [
					character_name, skill["name"], target.character_name, single_buff_power, buff_duration
				]
			elif skill_name == "ultimate":
				# Buff all allies
				for ally in get_tree().get_nodes_in_group("player_team"):
					if ally.is_available():
						ally.apply_buff("attack", mass_buff_power, ultimate_buff_duration)
				result.message = "%s used %s, increasing all allies' attack by %d for %d turns!" % [
					character_name, skill["name"], mass_buff_power, ultimate_buff_duration
				]
		CharacterType.DEBUFFER:
			if skill_name == "skill" or skill_name == "ultimate":
				# Calculate effect chance
				var effect_chance = calculate_effect_chance(skill_name, target)
				var rand = randf()
				
				if rand <= effect_chance:
					if skill_name == "skill":
						target.apply_debuff("attack", single_debuff_power, debuff_duration)
						result.message = "%s used %s on %s, decreasing their attack by %d for %d turns! (Effect Chance: %.1f%%)" % [
							character_name, skill["name"], target.character_name, single_debuff_power, debuff_duration, effect_chance * 100
						]
					else:  # ultimate
						# Debuff all enemies
						var affected_count = 0
						for enemy in get_tree().get_nodes_in_group("enemy_team"):
							if enemy.is_available():
								var enemy_chance = calculate_effect_chance(skill_name, enemy)
								if randf() <= enemy_chance:
									enemy.apply_debuff("attack", mass_debuff_power, ultimate_debuff_duration)
									affected_count += 1
						result.message = "%s used %s, decreasing %d enemies' attack by %d for %d turns! (Effect Chance: %.1f%%)" % [
							character_name, skill["name"], affected_count, mass_debuff_power, ultimate_debuff_duration, effect_chance * 100
						]
				else:
					result.message = "%s used %s on %s, but the effect was resisted! (Effect Chance: %.1f%%)" % [
						character_name, skill["name"], target.character_name, effect_chance * 100
					]
		CharacterType.TANK:
			if skill_name == "skill":
				# Apply shield and taunt
				var effect_chance = calculate_effect_chance(skill_name, target)
				var rand = randf()
				
				if rand <= effect_chance:
					# Apply shield to self
					apply_buff("defense", shield_power, 2)
					# Apply taunt to target
					target.apply_debuff("taunt", 1, taunt_duration)
					result.message = "%s used %s, gaining %d defense and taunting %s for %d turns! (Effect Chance: %.1f%%)" % [
						character_name, skill["name"], shield_power, target.character_name, taunt_duration, effect_chance * 100
					]
				else:
					result.message = "%s used %s, but the taunt was resisted! (Effect Chance: %.1f%%)" % [
						character_name, skill["name"], effect_chance * 100
					]
			elif skill_name == "ultimate":
				# Apply counter effect to self
				apply_buff("counter", counter_damage, 3)
				result.message = "%s used %s, gaining counter-attack ability for 3 turns! (Counter Damage: %d)" % [
					character_name, skill["name"], counter_damage
				]
		_:
			# Get all valid targets based on the skill's pattern
			var targets = get_targets(skill_name, target)
			var total_damage = 0
			var crit_count = 0
			
			# Calculate base damage for the skill
			var base_damage = calculate_base_damage(skill_name)
			
			# Apply damage to each target
			for current_target in targets:
				if current_target.is_available():
					for i in range(skill["hit_count"]):
						var damage_result = calculate_damage(base_damage)
						var actual_damage = current_target.take_damage(damage_result["damage"])
						total_damage += actual_damage
						if damage_result["is_crit"]:
							crit_count += 1
			
			# Generate appropriate message based on target pattern and results
			var target_desc = ""
			match skill["target_pattern"]:
				"single":
					target_desc = "on %s" % target.character_name
				"adjacent":
					target_desc = "on %s and adjacent enemies" % target.character_name
				"all":
					target_desc = "on all enemies"
				"bounce":
					target_desc = "bouncing between enemies"
			
			if crit_count > 0:
				result.message = "%s used %s %s for %d total damage (%d hits, %d critical)! (Crit Rate: %.1f%%, Crit DMG: %.1f%%)" % [
					character_name, skill["name"], target_desc, total_damage,
					skill["hit_count"] * targets.size(), crit_count, crit_rate * 100, crit_damage * 100
				]
			else:
				result.message = "%s used %s %s for %d total damage (%d hits)!" % [
					character_name, skill["name"], target_desc, total_damage,
					skill["hit_count"] * targets.size()
				]
			
			# Gain skill point from basic attack
			if skill_name == "normal_attack":
				gain_skill_point(1)
	
	return result

## Gets the character's current speed value
## Returns: Integer representing the character's speed
func get_speed() -> int:
	return speed

## Checks if the character is available for actions (alive)
## Returns: Boolean indicating if the character can act
func is_available() -> bool:
	return is_alive 

# Add new function to calculate aggro-based target selection
func select_target_by_aggro(available_targets: Array) -> BattleCharacter:
	if available_targets.size() == 0:
		return null
	
	# Calculate total aggro of available targets
	var total_aggro = 0.0
	for target in available_targets:
		if target.is_available():
			total_aggro += target.current_aggro
	
	# If no valid targets, return null
	if total_aggro <= 0:
		return null
	
	# Select target based on aggro ratios
	var rand = randf() * total_aggro
	var current_sum = 0.0
	
	for target in available_targets:
		if target.is_available():
			current_sum += target.current_aggro
			if rand <= current_sum:
				return target
	
	# Fallback to first available target
	for target in available_targets:
		if target.is_available():
			return target
	
	return null 

# Function to equip an item
func equip_item(item: Equipment) -> bool:
	if item == null:
		return false
	
	# Unequip current item in that slot if exists
	if equipment[item.slot] != null:
		unequip_item(item.slot)
	
	# Equip new item
	equipment[item.slot] = item
	
	# Apply main stat
	match item.main_stat:
		EquipmentMainStat.FLAT_ATTACK:
			equipment_stats.flat_attack += item.main_stat_value
		EquipmentMainStat.FLAT_HP:
			equipment_stats.flat_hp += item.main_stat_value
		EquipmentMainStat.PERCENT_ATTACK:
			equipment_stats.percent_attack += item.main_stat_value
		EquipmentMainStat.PERCENT_HP:
			equipment_stats.percent_hp += item.main_stat_value
		EquipmentMainStat.PERCENT_DEFENSE:
			equipment_stats.percent_defense += item.main_stat_value
		EquipmentMainStat.EFFECT_HIT_RATE:
			equipment_stats.effect_hit_rate += item.main_stat_value
		EquipmentMainStat.CRIT_RATE:
			equipment_stats.crit_rate += item.main_stat_value
		EquipmentMainStat.CRIT_DAMAGE:
			equipment_stats.crit_damage += item.main_stat_value
		EquipmentMainStat.SPEED:
			equipment_stats.speed += item.main_stat_value
		EquipmentMainStat.SHIELD_POWER:
			equipment_stats.shield_power += item.main_stat_value
		EquipmentMainStat.HEALING_POWER:
			equipment_stats.healing_power += item.main_stat_value
		EquipmentMainStat.ENERGY_EFFICIENCY:
			equipment_stats.energy_efficiency += item.main_stat_value
	
	return true

# Function to unequip an item
func unequip_item(slot: EquipmentSlot) -> bool:
	if equipment[slot] == null:
		return false
	
	var item = equipment[slot]
	
	# Remove main stat
	match item.main_stat:
		EquipmentMainStat.FLAT_ATTACK:
			equipment_stats.flat_attack -= item.main_stat_value
		EquipmentMainStat.FLAT_HP:
			equipment_stats.flat_hp -= item.main_stat_value
		EquipmentMainStat.PERCENT_ATTACK:
			equipment_stats.percent_attack -= item.main_stat_value
		EquipmentMainStat.PERCENT_HP:
			equipment_stats.percent_hp -= item.main_stat_value
		EquipmentMainStat.PERCENT_DEFENSE:
			equipment_stats.percent_defense -= item.main_stat_value
		EquipmentMainStat.EFFECT_HIT_RATE:
			equipment_stats.effect_hit_rate -= item.main_stat_value
		EquipmentMainStat.CRIT_RATE:
			equipment_stats.crit_rate -= item.main_stat_value
		EquipmentMainStat.CRIT_DAMAGE:
			equipment_stats.crit_damage -= item.main_stat_value
		EquipmentMainStat.SPEED:
			equipment_stats.speed -= item.main_stat_value
		EquipmentMainStat.SHIELD_POWER:
			equipment_stats.shield_power -= item.main_stat_value
		EquipmentMainStat.HEALING_POWER:
			equipment_stats.healing_power -= item.main_stat_value
		EquipmentMainStat.ENERGY_EFFICIENCY:
			equipment_stats.energy_efficiency -= item.main_stat_value
	
	equipment[slot] = null
	return true

# Function to get final stats including equipment
func get_final_stats() -> Dictionary:
	var final_stats = {
		"attack": attack + equipment_stats.flat_attack,
		"hp": max_hp + equipment_stats.flat_hp,
		"defense": defense,
		"speed": speed + equipment_stats.speed,
		"crit_rate": crit_rate + equipment_stats.crit_rate,
		"crit_damage": crit_damage + equipment_stats.crit_damage,
		"effect_hit_rate": effect_hit_rate + equipment_stats.effect_hit_rate,
		"shield_power": shield_power + equipment_stats.shield_power,
		"healing_power": healing_power + equipment_stats.healing_power,
		"energy_efficiency": 1.0 + equipment_stats.energy_efficiency
	}
	
	# Apply percentage modifiers
	final_stats.attack *= (1.0 + equipment_stats.percent_attack)
	final_stats.hp *= (1.0 + equipment_stats.percent_hp)
	final_stats.defense *= (1.0 + equipment_stats.percent_defense)
	
	return final_stats 