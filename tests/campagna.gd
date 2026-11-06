## Campagna completa IA contro IA: godot --headless -s res://tests/campagna.gd -- seme sim
extends SceneTree
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var seme := int(a[0])
	var nsim := int(a[1])
	var rng := RandomNumberGenerator.new()
	rng.seed = seme
	var early: Array = []
	var late: Array = []
	for i in range(1, 10):
		early.append("E%d" % i)
		late.append("E%d" % (i + 9))
	early.shuffle()
	late.shuffle()
	var prestigio := 13
	var prev := ""
	for k in 4:
		var g: String = Campagna.ORDINE[k]
		var mazzo: Array = early if k < 2 else late
		var ev: Array = mazzo.slice(0, 3)
		mazzo.assign(mazzo.slice(3))
		var m := Motore.new()
		m.nuova(g, seme + k, {"campagna": {"prestigio": prestigio, "eventi": ev, "prev": prev, "prewar": "caso"}})
		var piano: Array = []
		var n := 0
		while not m.finita() and n < 400:
			var base: Dictionary = m.s.duplicate(true)
			var ans: Array = []
			var giri := 0
			while not m.prova(base, ans):
				giri += 1
				if giri > 300:
					print("BLOCCO ", m.need)
					break
				ans.append(IA.rispondi(base, ans, m.need, piano, rng, nsim))
			for r in m.registro:
				if r.contains("campagna") or r.contains("Prestigio") or r.contains("pre-bellica") or r.contains("Politica coloniale") or r.begins_with("FINE") or r.contains("Esito"):
					print("  ", r)
			n += 1
		prestigio = int(m.s["camp"]["prestigio"])
		prev = m.s["camp"]["esito"]
		print("%s: %s, VP %d, esito %s, prestigio %d (atti %d)" % [g, m.s["fine"].get("v", ""), int(m.s["pw"]), prev, prestigio, n])
	print("CAMPAGNA FINITA: prestigio ", prestigio)
	quit()
