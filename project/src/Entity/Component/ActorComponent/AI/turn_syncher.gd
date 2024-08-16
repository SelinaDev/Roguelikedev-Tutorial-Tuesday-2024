class_name TurnSyncher
extends Resource

const PERSISTENCE_TURNS = 5
const MAX_RECORDED_PLAYER_TURNS = 10
const TURN_SHIFT_FRACTION = 1.5
const DAMAGE_SHIFT_FRACTION = 1.75

var _synched_player: Entity:
	set(value): 
		if value:
			_synched_player_index = PlayerComponent.get_player_index(value)
		else:
			_synched_player_index = -1
		_synched_player_ref = weakref(value)
	get:
		var player: Entity = _synched_player_ref.get_ref()
		if player:
			return player
		if _synched_player_index == -1:
			return null
		player = WorldManager.get_world().get_player(_synched_player_index)
		_synched_player_ref = weakref(player)
		return player
var _synched_player_ref: WeakRef = weakref(null)
@export_storage var _synched_player_index: int
var _parent_entity: Entity:
	get:
		return _parent_entity_ref.get_ref()
	set(value):
		_parent_entity_ref = weakref(value)
var _parent_entity_ref: WeakRef = weakref(null)

@export_storage var _recorded_player_turns: Array[int] = []
@export_storage var _recorded_damage: Array[DamageRecord] = []

@export_storage var _visible_last_turn: bool = false
@export_storage var _persistence_counter: int


func setup(parent_entity: Entity) -> void:
	_parent_entity = parent_entity
	var durability: DurabilityComponent = _parent_entity.get_component(Component.Type.Durability)
	if not durability.took_damage.is_connected(_on_parent_entity_took_damage):
		durability.took_damage.connect(_on_parent_entity_took_damage)


func disable() -> void:
	var durability: DurabilityComponent = _parent_entity.get_component(Component.Type.Durability)
	if durability:
		durability.took_damage.disconnect(_on_parent_entity_took_damage)


func get_synched_player() -> Entity:
	return _synched_player


func check_group_turn() -> bool:
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
	var player_index: int = PlayerComponent.get_player_index(player)
	var recorded_turns_active_player := float(_recorded_player_turns.filter(func(index: int) -> bool: return index == player_index).size())
	var recorded_turns_synched_player := float(_recorded_player_turns.filter(func(index: int) -> bool: return index == _synched_player_index).size())
	var active_player_turn_fraction := recorded_turns_active_player / recorded_turns_synched_player
	if active_player_turn_fraction >= TURN_SHIFT_FRACTION:
		_synched_player = player


func _compare_recorded_damage(player: Entity) -> void:
	if player == _synched_player:
		return
	var player_index: int = PlayerComponent.get_player_index(player)
	var recorded_damage_active_player: int = _recorded_damage\
		.filter(func(record: DamageRecord) -> bool: return record.source == player_index)\
		.reduce(
			func(total_damage: int, record: DamageRecord) -> bool: return total_damage + record.amount,
			0
		)
	var recorded_damage_synched_player: int = _recorded_damage\
		.filter(func(record: DamageRecord) -> bool: return record.source == _synched_player_index)\
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
	var map_data: MapData = _parent_entity.map_data
	if map_data:
		return map_data.is_in_fov(PositionComponent.get_entity_position(_parent_entity), player_index)
	return false


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
	_recorded_player_turns.append(PlayerComponent.get_player_index(player))
	if _recorded_player_turns.size() > MAX_RECORDED_PLAYER_TURNS:
		_recorded_player_turns = _recorded_player_turns.slice(- MAX_RECORDED_PLAYER_TURNS)


func _on_parent_entity_took_damage(amount: int, source: Entity) -> void:
	_recorded_damage.append(
		DamageRecord.new(amount, source)
	)


class DamageRecord extends Resource:
	const MAX_TURNS_ACTIVE = 10
	@export_storage var turns: int
	@export_storage var source: int
	@export_storage var amount: int
	
	func _init(amount: int, source_player: Entity) -> void:
		turns = 0
		self.amount = amount
		self.source = PlayerComponent.get_player_index(source_player)
	
	func is_fresh() -> bool:
		return turns <= MAX_TURNS_ACTIVE
