## Partite automatiche IA contro IA: godot --headless -s res://tests/sim.gd -- [gioco] [partite] [sim]
extends SceneTree

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var giochi := ["palestina", "cipro", "malesia", "kenya"]
	if args.size() > 0 and args[0] != "tutti":
		giochi = [args[0]]
	var n := int(args[1]) if args.size() > 1 else 1
	var nsim := int(args[2]) if args.size() > 2 else 6
	var nsim_ins := int(args[3]) if args.size() > 3 else nsim
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var esiti := {}
	for g in giochi:
		for k in n:
			var m := Motore.new()
			m.nuova(g, 1000 + k * 77 + g.length())
			var atti := 0
			var piano: Array = []
			var t0 := Time.get_ticks_msec()
			while not m.finita() and atti < 400:
				var base: Dictionary = m.s.duplicate(true)
				var ans: Array = []
				var giri := 0
				while true:
					var fatto := m.prova(base, ans)
					if fatto:
						break
					giri += 1
					if giri > 300:
						push_error("atto bloccato: %s" % str(m.need))
						m.fine_partita("pareggio", "bloccato")
						break
					var v = IA.rispondi(base, ans, m.need, piano, rng, nsim if m.need["f"] == "brit" else nsim_ins)
					ans.append(v)
				atti += 1
			var fine: Dictionary = m.s["fine"]
			print("%s #%d: %s — %s (atti %d, VP %d, %.1fs)" % [g, k, fine.get("v", "?"), fine.get("m", ""), atti, int(m.s["pw"]), (Time.get_ticks_msec() - t0) / 1000.0])
			esiti[g + "_" + str(fine.get("v", "?"))] = int(esiti.get(g + "_" + str(fine.get("v", "?")), 0)) + 1
	print(esiti)
	quit()
