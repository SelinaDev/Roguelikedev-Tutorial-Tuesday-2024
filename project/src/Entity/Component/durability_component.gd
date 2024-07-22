class_name DurabilityComponent
extends Component

signal hp_changed(hp, max_hp)

@export var max_hp: int:
	set(value):
		if value == max_hp:
			return
		var hp_diff := max_hp - value
		max_hp = value
		hp_changed.emit(current_hp, max_hp)
		current_hp += maxi(0, hp_diff)
@export var current_hp: int:
	set(value):
		if value == current_hp:
			return
		current_hp = clampi(value, 0, max_hp)
		hp_changed.emit(current_hp, max_hp)
		if current_hp <= 0:
			_parent_entity.process_message(Message.new("die"))
@export var death_texture: AtlasTexture
@export var death_z_index: DrawableComponent.RenderOrder = DrawableComponent.RenderOrder.CORPSE
@export var death_removes_movement_blocker: bool = true
@export var death_removes_visibility_blocker: bool = true


func _enter_entity(_entity) -> void:
	current_hp = max_hp


func process_message_precalculate(_message: Message) -> void:
	pass


func process_message_execute(message: Message) -> void:
	match message.type:
		"die":
			var should_die: bool = message.data.get("should_die", true)
			if not should_die:
				return
			if current_hp > 0:
				current_hp = 0
				return
			if death_removes_movement_blocker:
				_parent_entity.remove_component(Component.Type.MovementBlocker)
			if death_removes_visibility_blocker:
				_parent_entity.remove_component(Component.Type.VisibilityBlocker)
			_parent_entity.process_message(Message.new(
				"visual_update",
				{"texture": death_texture, "render_order": death_z_index}
			))
		"heal":
			var actual_amount := heal(message.get_calculation("amount").get_result())
			message.data["actual_amount"] = actual_amount
		"take_damage":
			message.data["did_hit"] = current_hp > 0
			var actual_amount := take_damage(message.get_calculation("damage").get_result())
			message.data["actual_amount"] = actual_amount


func heal(amount: int) -> int:
	var old_hp := current_hp
	current_hp += amount
	return current_hp - old_hp


func take_damage(amount: int) -> int:
	var old_hp := current_hp
	current_hp -= amount
	return old_hp - current_hp


func get_component_type() -> Type:
	return Type.Durability
