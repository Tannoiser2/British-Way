## Campagna salvata su Firebase con codice e ripresa da un altro "dispositivo".
extends SceneTree
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var scena = load("res://scenes/main.tscn").instantiate()
	root.add_child(scena)
	await process_frame
	if a[0] == "a":
		scena._nuova_campagna("hotseat")
		var rng := RandomNumberGenerator.new()
		rng.seed = 4
		for i in 120:
			await process_frame
			var m = scena.m
			if m.need != null:
				var opz: Array = m.need["opz"]
				scena.rispondi(opz[rng.randi() % opz.size()]["v"])
		for i in 60:
			await create_timer(0.1).timeout
		var f := FileAccess.open("/tmp/codice_camp.txt", FileAccess.WRITE)
		f.store_string(scena.campagna["codice"])
		f.close()
		print("A codice ", scena.campagna["codice"], " gioco ", scena.m.gioco(), " atti ", scena.atti.size(), " hash ", str(scena.base["sp"]).hash(), " cloud ", scena.campagna.get("cloud_ok"))
	else:
		scena.camp_codice_edit.text = FileAccess.get_file_as_string("/tmp/codice_camp.txt")
		scena._riprendi_campagna_codice()
		for i in 40:
			await create_timer(0.1).timeout
		print("B: ", scena.menu_msg.text, " gioco ", scena.m.gioco() if scena.m else "-", " atti ", scena.atti.size(), " hash ", (str(scena.base["sp"]).hash() if scena.m else 0))
	quit()
