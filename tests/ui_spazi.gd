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
	rng.seed = int(a[1])
	var trovate := 0
	for i in 2000:
		await process_frame
		var m = scena.m
		if m.need == null:
			continue
		if m.need.get("x", {}).get(a[2], false) or str(m.need.get("x", {}).get("tag", "")) == a[2]:
			trovate += 1
			if trovate >= int(a[3]):
				break
		var opz: Array = m.need["opz"]
		scena.rispondi(opz[rng.randi() % opz.size()]["v"])
	for i in 30:
		await process_frame
	if a.size() > 5:
		scena._mostra_regole()
		for i in 5:
			await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(a[4])
	quit()
