extends SceneTree
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var m := Motore.new()
	m.nuova(a[0], int(a[1]))
	var rng := RandomNumberGenerator.new()
	rng.seed = int(a[1])
	var piano: Array = []
	var n := 0
	while not m.finita() and n < int(a[2]):
		var base: Dictionary = m.s.duplicate(true)
		var ans: Array = []
		while not m.prova(base, ans):
			var v = IA.rispondi(base, ans, m.need, piano, rng, 40)
			var lab := str(v)
			for o in m.need["opz"]:
				if str(o["v"]) == str(v):
					lab = o["t"]
			print("  [%s] %s  ->  %s" % [m.need["f"], m.need["testo"], lab])
			ans.append(v)
		for r in m.registro:
			print("    · ", r)
		n += 1
	quit()
