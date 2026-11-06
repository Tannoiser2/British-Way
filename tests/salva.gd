extends SceneTree
func _init() -> void:
	var scena = load("res://scenes/main.tscn").instantiate()
	root.add_child(scena)
	await process_frame
	scena._seleziona_gioco("malesia")
	scena._nuova_locale("hotseat")
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in 300:
		await process_frame
		var m = scena.m
		if m.need != null:
			var opz: Array = m.need["opz"]
			scena.rispondi(opz[rng.randi() % opz.size()]["v"])
	var h1 = str(scena.m.s["sp"]).hash()
	var n1 = scena.atti.size()
	scena._torna_menu()
	scena._riprendi_locale()
	await process_frame
	await process_frame
	print("PRIMA ", n1, " ", h1, " DOPO ", scena.atti.size(), " ", str(scena.base["sp"]).hash())
	quit()
