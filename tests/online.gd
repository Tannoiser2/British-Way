## Prova online con un finto Firebase: godot --headless -s res://tests/online.gd -- host|ospite gioco passi
extends SceneTree
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var ruolo: String = a[0]
	var scena = load("res://scenes/main.tscn").instantiate()
	root.add_child(scena)
	await process_frame
	scena._seleziona_gioco(a[1])
	var rng := RandomNumberGenerator.new()
	rng.seed = 7 if ruolo == "host" else 8
	if ruolo == "host":
		scena.nome_edit.text = "Host"
		scena._crea_stanza("brit")
		for i in 50:
			await create_timer(0.3).timeout
			if scena.stanza != "":
				var f := FileAccess.open("/tmp/codice.txt", FileAccess.WRITE)
				f.store_string(scena.stanza)
				f.close()
				break
	elif ruolo == "rientro":
		await create_timer(1.0).timeout
		scena._rientra_stanza()
		for i in 20:
			await create_timer(0.5).timeout
		print("MSG ", scena.menu_msg.text)
	else:
		var code := ""
		for i in 100:
			await create_timer(0.3).timeout
			if FileAccess.file_exists("/tmp/codice.txt"):
				code = FileAccess.get_file_as_string("/tmp/codice.txt").strip_edges()
				if code != "":
					break
		scena.codice_edit.text = code
		scena.nome_edit.text = "Ospite"
		scena._entra_stanza()
	var t0 := Time.get_ticks_msec()
	var ult := 0
	while Time.get_ticks_msec() - t0 < int(a[2]) * 1000:
		await create_timer(0.05).timeout
		var m = scena.m
		if Time.get_ticks_msec() - ult > 4000:
			ult = Time.get_ticks_msec()
			print(ruolo, " t=", (ult - t0) / 1000, " online=", scena.online, " atti=", scena.atti.size(), " ans=", scena.ans.size(), " need=", (m.need["f"] if m and m.need else "-"), " ctrl=", scena.controllo, " k=", scena.net_k)
		if m == null or not scena.online:
			continue
		if m.finita():
			break
		if m.need != null and scena.controllo.get(m.need["f"], "") == "umano":
			var opz: Array = m.need["opz"]
			scena.rispondi(opz[rng.randi() % opz.size()]["v"])
	var m2 = scena.m
	if m2:
		print(ruolo, " ATTI ", scena.atti.size(), " PW ", m2.s["pw"], " CARTA ", m2.s["carta"], " HASH ", str(m2.s["sp"]).hash(), " FINE ", m2.s["fine"])
	else:
		print(ruolo, " nessuna partita")
	quit()
