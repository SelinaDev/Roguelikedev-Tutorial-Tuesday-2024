class_name TurnSyncher
extends Resource

# NOTE: This may have to be refactored to int-based indices later to facilitate saving

const PERSISTENCE_TURNS = 5
const MAX_RECORDED_PLAYER_TURNS = 10
const TURN_SHIFT_FRACTION = 1.5
const DAMAGE_SHIFT_FRACTION = 1.75

var _synched_player: Entity
var _parent_entity: Entity

var _recorded_player_turns: Array[Entity] = []
var _recorded_damage: Array[DamageRecord] = []

var _visible_last_turn: bool = false
var _persistence_counter: int


func setup(parent_entity: Entity) -> void:
	_parent_entity = parent_entity
	var durability: DurabilityComponent = _parent_entity.get_component(Component.Type.Durability)
	durability.took_damage.connect(_on_parent_entity_took_damage)


func disable() -> void:
	var durability: DurabilityComponent = _parent_entity.get_component(Component.Type.Durability)
	if durability:
		durability.took_damage.disconnect(_on_parent_entity_took_damage)


func get_synched_player() -> Entity:
	return _synched_player


func check_group_durn() -> bool:
	return _synched_player == null


func check_player_turn(player: Entity) -> bool:
	var player_is_visible: bool = _is_player_visible(player)
	var visible_now: bool = _is_parent_entity_visible()
	
	if player_is_visible:
		_record_player_turn(player)
	
	if not visible_now:
		_handle_not_visible(player)
	
	elif _just_turned_visible():
		_handle_just_turned_visible(player)
	
	elif player_is_visible and player != _synched_player:
		_handle_unsynched_player_is_visible(player)
	
	if player == _synched_player:
		_turn_bookkeeping()
	return player == _synched_player


func _handle_not_visible(player: Entity) -> void:
	if _synched_player == player:
		_persistence_counter -= 1
		if _persistence_counter <= 0:
			_synched_player = null
			_recorded_player_turns = []
		else:
			_record_player_turn(player)


func _handle_just_turned_visible(player: Entity) -> void:
	_synched_player = player
	_persistence_counter = PERSISTENCE_TURNS


func _handle_unsynched_player_is_visible(player: Entity) -> void:
	_record_player_turn(player)
	_compare_recorded_turns(player)
	_compare_recorded_damage(player)


func _compare_recorded_turns(player: Entity) -> void:
	if player == _synched_player:
		return
	var recorded_turns_active_player := float(_recorded_player_turns.filter(func(entity: Entity) -> bool: return entity == player).size())
	var recorded_turns_synched_player := float(_recorded_player_turns.filter(func(entity: Entity) -> bool: return entity == _synched_player).size())
	var active_player_turn_fraction := recorded_turns_active_player / recorded_turns_synched_player
	if active_player_turn_fraction >= TURN_SHIFT_FRACTION:
		_synched_player = player


func _compare_recorded_damage(player: Entity) -> void:
	if player == _synched_player:
		return
	var recorded_damage_active_player: int = _recorded_damage\
		.filter(func(record: DamageRecord) -> bool: return record.source == player)\
		.reduce(
			func(total_damage: int, record: DamageRecord) -> bool: return total_damage + record.amount,
			0
		)
	var recorded_damage_synched_player: int = _recorded_damage\
		.filter(func(record: DamageRecord) -> bool: return record.source == _synched_player)\
		.reduce(
			func(total_damage: int, record: DamageRecord) -> bool: return total_damage + record.amount,
			0
		)
	var damage_fraction := float(recorded_damage_active_player) / float(recorded_damage_synched_player)
	if damage_fraction >= DAMAGE_SHIFT_FRACTION:
		_synched_player = player


func _is_parent_entity_visible() -> bool:
	return _parent_entity.map_data.is_in_fov(PositionComponent.get_entity_position(_parent_entity))


func _just_turned_visible() -> bool:
	return _is_parent_entity_visible() and not _visible_last_turn


func _is_player_visible(player: Entity) -> bool:
	var player_index: int = PlayerComponent.get_player_index(player)
	return _parent_entity.map_data.is_in_fov(PositionComponent.get_entity_position(_parent_entity), player_index)


func _get_visible_players() -> Array[Entity]:
	var players: Array[Entity] = _parent_entity.map_data.get_entities([Component.Type.Player])
	return players.filter(_is_player_visible)


func _turn_bookkeeping() -> void:
	_visible_last_turn = _is_parent_entity_visible()
	for damage_record: DamageRecord in _recorded_damage:
		damage_record.turns += 1
	_recorded_damage = _recorded_damage.filter(
		func(record: DamageRecord): return record.is_fresh()
	)


func _record_player_turn(player: Entity) -> void:
	_recorded_player_turns.append(player)
	if _recorded_player_turns.size() > MAX_RECORDED_PLAYER_TURNS:
		_recorded_player_turns = _recorded_player_turns.slice(- MAX_RECORDED_PLAYER_TURNS)


func _on_parent_entity_took_damage(amount: int, source: Entity) -> void:
	_recorded_damage.append(
		DamageRecord.new(amount, source)
	)


class DamageRecord extends RefCounted:
	const MAX_TURNS_ACTIVE = 10
	var turns: int
	var source: Entity
	var amount: int
	
	func _init(amount: int, source: Entity) -> void:
		turns = 0
		self.amount = amount
		self.source = source
	
	func is_fresh() -> bool:
		return turns <= MAX_TURNS_ACTIVE
