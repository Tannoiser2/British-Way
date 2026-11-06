## Prova dell'interfaccia: due "giocatori" che cliccano a caso. godot --path . -s res://tests/ui_casuale.gd -- gioco passi png
extends SceneTree
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var scena = load("res://scenes/main.tscn").instantiate()
	root.add_child(scena)
	root.size = Vector2i(1600, 900)
	await process_frame
	scena._seleziona_gioco(a[0])
	scena._nuova_locale("hotseat")
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var passi := 0
	var fine := int(a[1])
	while passi < fine:
		await process_frame
		var m = scena.m
		if m == null:
			break
		if m.finita():
			print("finita: ", m.s["fine"])
			break
		if m.need != null:
			var opz: Array = m.need["opz"]
			var v = opz[rng.randi() % opz.size()]["v"]
			if rng.randf() < 0.04 and not scena.storia.is_empty():
				scena._annulla()
			else:
				scena.rispondi(v)
			passi += 1
			if passi % 200 == 0:
				scena._sopra_spazio(m.ordine[passi % m.ordine.size()])
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(a[2])
	print("passi ", passi, " atti ", scena.atti.size())
	quit()
