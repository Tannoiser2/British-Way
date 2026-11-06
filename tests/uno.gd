extends SceneTree
func _init() -> void:
	var m := Motore.new()
	m.nuova("palestina", 42)
	print("carta ", m.s["carta"], " coda ", m.s["coda"])
	var base: Dictionary = m.s.duplicate(true)
	var t0 := Time.get_ticks_msec()
	var r := m.prova(base, [])
	print("fatto=", r, " need=", m.need, " in ", Time.get_ticks_msec() - t0, "ms")
	var rng := RandomNumberGenerator.new()
	t0 = Time.get_ticks_msec()
	var p := IA.pianifica(base, [], "ins", 1, rng)
	print("piano ", p, " in ", Time.get_ticks_msec() - t0, "ms")
	quit()
