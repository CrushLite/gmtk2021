extends Node2D


func _on_player_collided(collision : KinematicCollision2D):
	if collision.collider == $Interactables:
		var tile_pos = $Interactables.world_to_map($player.position)
		tile_pos -= collision.normal
		var tile = $Interactables.get_cellv(tile_pos)
		if tile >= 0:
			print(tile)
#			$Interactables.set_cellv(tile_pos, tile-1)

