class_name DurabilityComponent
extends Component

signal hp_changed(hp, max_hp)
signal took_damage(amount, source)

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
			_parent_entity.process_message(Message.new(&"die"))
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
		&"die":
			var should_die: bool = message.data.get(&"should_die", true)
			if not should_die:
				return
			if current_hp > 0:
				current_hp = 0
				return
			if death_removes_movement_blocker:
				_parent_entity.remove_component(Component.Type.MovementBlocker)
			if death_removes_visibility_blocker:
				_parent_entity.remove_component(Component.Type.VisibilityBlocker)
			_parent_entity.remove_component(Component.Type.Actor)
			_parent_entity.process_message(Message.new(
				&"visual_update",
				{&"texture": death_texture, &"render_order": death_z_index}
			))
			var is_player := _parent_entity.has_component(Component.Type.Player)
			var log_text: String
			var log_color: Color
			if is_player:
				log_text = "[pulse freq=1.0 color=#%s]%s has died![/pulse]" % [Log.COLOR_IMPORTANT, _parent_entity.name]
				log_color = Log.COLOR_NEUTRAL
			else:
				log_text = "The %s has died." % _parent_entity.name
				log_color = Log.COLOR_POSITIVE
			Log.send_log(log_text)
			_parent_entity.name = "Remains of %s" % _parent_entity.name
		&"heal":
			var actual_amount := heal(message.get_calculation(&"amount").get_result())
			message.data[&"actual_amount"] = actual_amount
		&"take_damage":
			message.data[&"did_hit"] = current_hp > 0
			var actual_amount := take_damage(message.get_calculation(&"damage").get_result())
			message.data[&"actual_amount"] = actual_amount
			var damage_source: Entity = message.data.get(&"source")
			var hit_verb: String = message.data.get(&"verb", "hit")
			var is_player := _parent_entity.has_component(Component.Type.Player)
			if actual_amount > 0:
				var log_color: Color = Log.COLOR_NEUTRAL if is_player else Log.COLOR_NEGATIVE
				Log.send_log("The %s %s the %s for %d damage!" % [
					damage_source.name,
					hit_verb,
					_parent_entity.name,
					actual_amount,
					],
					log_color
					)
			else:
				Log.send_log("The %s %s the %s, but did no damage." % [
					damage_source.name,
					hit_verb,
					_parent_entity.name
				])
				
			took_damage.emit(actual_amount, message.data.get("source", null))


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
