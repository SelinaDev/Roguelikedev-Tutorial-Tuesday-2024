class_name UsableComponent
extends Component

enum UsageType {
	DRINK,
	READ,
	ACTIVATE
}

@export var effects: Array[UseEffect]
@export var targeting: UseTarget
@export var usage_type: UsageType = UsageType.ACTIVATE


func activate(_user: Entity, targets: Array[Entity]) -> bool:
	var did_use := false
	for target: Entity in targets:
		for effect: UseEffect in effects:
			did_use = effect.apply(target, _user) or did_use
	return did_use


static func get_use_target(entity: Entity) -> UseTarget:
	var usable: UsableComponent = entity.get_component(Component.Type.Use)
	if not usable:
		return null
	return usable.targeting


func get_component_type() -> Type:
	return Component.Type.Use


func _get_use_description() -> String:
	var effect_descriptions: Array[String] = effects.map(func(e: UseEffect) -> String: return e.get_effect_description())
	return "When %s, it %s." % [
		get_use_verb_passive(),
		TextTools.concatenate_list(effect_descriptions)
	]


func get_use_verb_passive() -> String:
	var use_word := "used"
	match usage_type:
		UsageType.DRINK:
			use_word = "drunk"
		UsageType.READ:
			use_word = "read"
		UsageType.ACTIVATE:
			use_word = "activated"
	return use_word


func get_use_verb_active() -> String:
	var use_word := "use"
	match usage_type:
		UsageType.DRINK:
			use_word = "drink"
		UsageType.READ:
			use_word = "read"
		UsageType.ACTIVATE:
			use_word = "activate"
	return use_word
