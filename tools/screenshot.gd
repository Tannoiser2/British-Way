## Screenshot: godot --path . -s res://tools/screenshot.gd -- gioco controllo(brit|ins|demo|menu) frames file
extends SceneTree
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var scena = load("res://scenes/main.tscn").instantiate()
	root.add_child(scena)
	root.size = Vector2i(1600, 900)
	await process_frame
	await process_frame
	if a[1] != "menu":
		scena._seleziona_gioco(a[0])
		scena._nuova_locale(a[1])
	var n := int(a[2])
	for i in n:
		await process_frame
	if a.size() > 4 and a[4] == "fine":
		scena.m.fine_partita("brit", "Volontà Politica a 18: vittoria britannica!")
		scena._fine()
		for i in 5:
			await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(a[3])
	print("salvato ", a[3])
	quit()
