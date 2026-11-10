## Variante avanzata di Cipro: controlla le quattro regole. godot --headless -s res://tests/variante_cipro.gd
extends SceneTree

var errori := 0

func ok(c: bool, t: String) -> void:
	print(("ok  " if c else "ERR ") + t)
	if not c:
		errori += 1


func pulisci(m: Motore) -> void:
	for id in m.ordine:
		var x := m.X(id)
		for k in ["u", "a", "b", "cf", "sab"]:
			x[k] = 0


func _init() -> void:
	for avz in [false, true]:
		var m := Motore.new()
		m.nuova("cipro", 42, {"avanzata": avz})
		ok(m.s["avanzata"] == avz, "variante %s registrata nello stato" % avz)
		pulisci(m)
		# 1) Reclutamento nei Monti senza Deposito
		ok(m._recruit_max("troodos") == (1 if avz else 0), "Reclutamento a Troodos senza Deposito: %d" % m._recruit_max("troodos"))
		ok(m._recruit_max("nicosia") == 0, "Città senza Deposito: nessun Reclutamento")
		m.X("troodos")["b"] = 1
		ok(m._recruit_max("troodos") == 2, "Monti con Deposito: 2 Cellule")
		# 2) Spostamento da Città con Coprifuoco
		m.X("nicosia")["u"] = 2
		m.X("nicosia")["cf"] = 1
		ok(m._travel_origine_ok("nicosia") == (not avz), "Spostamento da Nicosia con Coprifuoco permesso: %s" % m._travel_origine_ok("nicosia"))
		# 3) Propaganda con Sabotaggio e Coprifuoco: l'Opinione non sale nella variante
		m.X("nicosia")["sab"] = 1
		var op0 := int(m.s["opinione"])
		var pw0 := int(m.s["pw"])
		m.s["coda"] = []
		m.autorisposta = func(_mm, q):
			if q["opz"].any(func(o): return str(o["v"]) == "nicosia"):
				return "nicosia"
			for o in q["opz"]:
				if str(o["v"]) == "cf":
					return "cf"
			return q["opz"][0]["v"]
		var b: Dictionary = m.s.duplicate(true)
		m.s = b
		m.sa_propagandize("ins", {"max": 1})
		if avz:
			ok(int(m.s["pw"]) == pw0 - 1 and int(m.s["opinione"]) == op0, "Propaganda (Sabotaggio + Coprifuoco): solo −1 VP")
		else:
			ok(int(m.s["opinione"]) > op0 or int(m.s["pw"]) < pw0, "Propaganda originale: si può scegliere l'Opinione")
		# 4) Pressione per i prigionieri
		m.s["prigione"] = 7
		m.s["opinione"] = 1
		var stima := m.stima_propaganda()
		ok(stima <= (-3 if avz else -1), "stima della Propaganda con 7 prigionieri: %d" % stima)
	print("ERRORI: %d" % errori)
	quit()
