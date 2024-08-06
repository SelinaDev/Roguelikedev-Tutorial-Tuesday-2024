class_name DrawableUseEffect
extends UseEffect

@export var drawable_effect: DrawableEffect


func apply(entity: Entity, _source: Entity) -> bool:
	var drawable_component: DrawableComponent = entity.get_component(Component.Type.Drawable)
	if drawable_component:
		var effect := drawable_effect.duplicate()
		drawable_component.add_drawable_effect(effect)
	return true
	
