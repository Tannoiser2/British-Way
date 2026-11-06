## Una partita IA contro IA con il registro completo: godot --headless -s res://tests/registro.gd -- gioco seme sim
extends SceneTree
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var m := Motore.new()
	m.nuova(a[0], int(a[1]))
	var rng := RandomNumberGenerator.new()
	rng.seed = int(a[1])
	var piano: Array = []
	var n := 0
	while not m.finita() and n < 500:
		var base: Dictionary = m.s.duplicate(true)
		var ans: Array = []
		while not m.prova(base, ans):
			ans.append(IA.rispondi(base, ans, m.need, piano, rng, int(a[2])))
		for r in m.registro:
			print(r)
		n += 1
	print("RISPOSTE ULTIMO ATTO: ", piano)
	quit()
