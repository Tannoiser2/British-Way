## Prove mirate delle regole: godot --headless -s res://tests/test_regole.gd
extends SceneTree
var errori := 0

func ok(c: bool, msg: String) -> void:
	if not c:
		errori += 1
		print("ERRORE: ", msg)
	else:
		print("ok  ", msg)

func nuovo(g: String) -> Motore:
	var m := Motore.new()
	m.nuova(g, 5)
	return m

func _init() -> void:
	# Haganah: scende da 4 a 3 e ritira 2 Cellule + 1 Deposito; risale e li restituisce
	var m := nuovo("palestina")
	var g0 := m.disp("g")
	var b0 := m.disp("b")
	m.sposta_haganah(-1)
	ok(m.disp("g") == g0 - 2 and m.disp("b") == b0 - 1, "Haganah 4→3 ritira 2 Cellule e 1 Deposito")
	m.sposta_haganah(-1)
	ok(m.disp("g") == g0 - 5, "Haganah 3→2 ritira altre 3 Cellule")
	m.sposta_haganah(2)
	ok(m.disp("g") == g0 and m.disp("b") == b0, "Haganah 2→4 restituisce tutto")
	# Assalto Palestina: 1 pezzo ogni 2 Truppe, alternanza Disponibili/Prigione
	m = nuovo("palestina")
	var x := m.X("gerusalemme_c")
	x["t"] = 4; x["a"] = 3; x["u"] = 0; x["b"] = 0
	var p0 := int(m.s["prigione"])
	m.assalto_in("brit", "gerusalemme_c")
	ok(int(x["a"]) == 1 and int(m.s["prigione"]) == p0 + 1, "Assalto: 2 Cellule (una Disponibile, una in Prigione)")
	# Spostamento: Cellule verso Coprifuoco con molti cubi diventano attive
	m = nuovo("palestina")
	x = m.X("telaviv"); x["cf"] = 1; x["t"] = 3; x["p"] = 1
	var o := m.X("lydda"); o["u"] = 2; o["a"] = 0
	var base: Dictionary = m.s.duplicate(true)
	base["coda"] = [{"t": "test"}]
	m.s = base
	m.need = null
	m._ans = ["lydda", "telaviv", 1, "fine", "fine"]
	m._i = 0
	m.op_travel("ins", {"max": 3})
	ok(int(m.X("telaviv")["a"]) == 1 and int(m.X("lydda")["u"]) == 1, "Spostamento: 1 Cellula attiva a Tel Aviv, l'altra clandestina a Lydda")
	# Kenya: Controllo e Volontà Politica
	m = nuovo("kenya")
	var pw := int(m.s["pw"])
	m.piazza("thika", "g", 2)
	ok(m.X("thika")["ctrl"] == "ins" and int(m.s["pw"]) == pw - 1, "Kenya: Controllo Mau Mau a Thika costa 1 VP")
	# Kenya Rifornimento: Base a Nairobi + Basi collegate
	m = nuovo("kenya")
	var r0 := int(m.s["ris"]["ins"])
	m.sa_supply("ins", {})
	ok(int(m.s["ris"]["ins"]) > r0, "Kenya: il Rifornimento dà Risorse (%d)" % (int(m.s["ris"]["ins"]) - r0))
	# Malesia: Propaganda iniziale stimata
	m = nuovo("malesia")
	ok(m.stima_propaganda() == 2 - 1, "Malesia: stima Propaganda iniziale (Supporto KL 2 − Opposizione Pahang 1)")
	# Cipro: setup
	m = nuovo("cipro")
	ok(int(m.s["pw"]) == 14 and int(m.s["opinione"]) == 2 and m.s["primo"] == "ins", "Cipro: preparazione")
	ok((m.s["mazzo"] as Array).size() == 20, "Mazzo di 21 carte (una già in gioco)")
	var prop := 0
	for c in m.s["mazzo"]:
		if m.carta_dati(c).get("propaganda", false):
			prop += 1
	ok(prop == 3, "3 carte Propaganda nel mazzo")
	print("ERRORI: ", errori)
	quit()
