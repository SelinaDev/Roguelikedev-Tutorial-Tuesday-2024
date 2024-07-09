extends GameState

@export var player_ui: Array[PlayerUiResource]

@onready var scheduler: Scheduler = $Scheduler

var entities: Array[Entity] = []
# TODO: Enter function that assigns players to their viewports

func enter(data: Dictionary = {}) -> void:
	var canvas = WorldManager.get_map_info(0).canvas
	for i in player_ui.size():
		var ui := player_ui[i]
		var viewport: SubViewport = get_node(ui.viewport)
		RenderingServer.viewport_attach_canvas(viewport.get_viewport().get_viewport_rid(), canvas)
		var entity := Entity.new()
		entities.append(entity)
		scheduler.actors.append(entity)
		entity.initialize(data.devices[i], canvas, Vector2i(2, 2) + Vector2i(i, 0))
