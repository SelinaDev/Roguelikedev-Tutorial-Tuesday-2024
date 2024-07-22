class_name EntityTemplate
extends Resource

@export var templates: Array[EntityTemplate]
@export var template_components: Array[Component]


func get_components() -> Dictionary:
	var components := {}
	
	for template: EntityTemplate in templates:
		components.merge(template.get_components(), true)
	
	for component: Component in template_components:
		components.merge({component.type: component})
	
	return components
