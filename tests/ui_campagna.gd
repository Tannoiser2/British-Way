## Campagna nell'interfaccia: due giocatori a caso, partita dopo partita, con screenshot.
extends SceneTree
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var scena = load("res://scenes/main.tscn").instantiate()
	root.add_child(scena)
	root.size = Vector2i(1600, 900)
	await process_frame
	scena._nuova_campagna("hotseat")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(a[1].replace(".png", "_0.png"))
	scena._camp_avanti()
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var foto := 0
	for i in int(a[0]):
		await process_frame
		var m = scena.m
		if m == null:
			continue
		if m.finita():
			print("PARTITA ", m.gioco(), " ", m.s["camp"]["esito"], " prestigio ", scena.campagna["prestigio"], " indice ", scena.campagna["indice"])
			if foto == 0:
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(a[1])
				foto = 1
			scena.fine_dlg.hide()
			scena._ok_fine()
			for j in 3:
				await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(a[1].replace(".png", "_%d.png" % int(scena.campagna["indice"])))
			if int(scena.campagna["indice"]) == 2:
				scena._scheda_partita_campagna("palestina")
				for j in 3:
					await process_frame
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(a[1].replace(".png", "_scheda.png"))
				scena.fine_dlg.hide()
				scena._ok_fine()
			if int(scena.campagna["indice"]) < 4:
				scena._camp_avanti()
			if int(scena.campagna["indice"]) >= 4:
				break
			continue
		if m.need != null:
			if m.atto_corrente().get("t", "") == "camp" and foto == 0 and m.need["testo"].contains("Politica"):
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(a[1])
				foto = 1
			var opz: Array = m.need["opz"]
			scena.rispondi(opz[rng.randi() % opz.size()]["v"])
	print("FINE indice ", scena.campagna.get("indice"), " prestigio ", scena.campagna.get("prestigio"))
	quit()
