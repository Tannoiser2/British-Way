## Round di Propaganda dei quattro giochi.
class_name Propaganda
extends Regole


func ultima_propaganda() -> bool:
	return int(s["prop_fatte"]) >= int(s["prop_tot"])


func prop_inizio() -> void:
	var d := 0
	var righe: Array = []
	match gioco():
		"palestina":
			var ferr_sab := 0
			var citta_pulite := 0
			for id in ordine:
				var x = X(id)
				match tipo(id):
					"distretto":
						d -= int(x["sab"]) + int(x["ter"])
						if int(x["sab"]) + int(x["ter"]) > 0:
							righe.append("%s: −%d" % [nome_sp(id), int(x["sab"]) + int(x["ter"])])
					"ferrovia":
						if int(x["sab"]) > 0:
							ferr_sab += 1
							d -= 2
							righe.append("%s sabotata: −2" % nome_sp(id))
					"citta":
						var v = 2 * int(x["sab"]) + 3 * int(x["ter"])
						d -= v
						if v > 0:
							righe.append("%s: −%d" % [nome_sp(id), v])
						else:
							citta_pulite += 1
			if ferr_sab == 0:
				d += 2
				righe.append("Nessuna ferrovia sabotata: +2")
			d += citta_pulite
			if citta_pulite:
				righe.append("Città senza Sabotaggi né Terrore: +%d" % citta_pulite)
		"cipro":
			var op := int(s["opinione"])
			if (s.get("camp", {}) as Dictionary).get("attivi", {}).has("E15"):
				op = op / 2
			d -= op
			if op:
				righe.append("Pressione internazionale: −%d" % op)
			var pulite := 0
			var dep_monti := false
			for id in ordine:
				var x = X(id)
				if tipo(id) in ["citta", "base"] and int(x["sab"]) > 0:
					var v := int(x["sab"]) * int(SP[id].get("valore", 1))
					d -= v
					righe.append("%s: −%d" % [nome_sp(id), v])
				if tipo(id) == "citta" and int(x["sab"]) == 0:
					pulite += 1
				if tipo(id) == "montagna" and int(x["b"]) > 0:
					dep_monti = true
			if not dep_monti:
				d += 2
				righe.append("Nessun Deposito nei Monti: +2")
			d += pulite / 2
			if pulite / 2:
				righe.append("Città senza Sabotaggio (%d): +%d" % [pulite, pulite / 2])
		"malesia":
			var sup := 0
			var opp := 0
			for id in ordine:
				var x = X(id)
				if int(x["sup"]) > 0:
					sup += popolazione(id)
				elif int(x["sup"]) < 0 and int(x["nv"]) == 0:
					opp += popolazione(id)
			d += sup - opp
			righe.append("Cuori e menti: Supporto %d − Opposizione %d" % [sup, opp])
			for id in ordine:
				if tipo(id) == "ec" and int(X(id)["sab"]) == 0 and gue(id) > cubi(id):
					X(id)["sab"] = 1
					nota("Coloni intimiditi: Sabotaggio al %s." % nome_sp(id))
			for id in ordine:
				if tipo(id) == "ec" and int(X(id)["sab"]) > 0:
					d -= 1
					righe.append("%s sabotato: −1" % nome_sp(id))
			if int(X("kl")["ter"]) > 0:
				d -= 1
				righe.append("Terrore a Kuala Lumpur: −1")
		"kenya":
			var le := 0
			var re := 0
			for id in ordine:
				if int(X(id)["sup"]) > 0:
					le += popolazione(id)
				elif int(X(id)["sup"]) < 0:
					re += popolazione(id)
			if re > le:
				d -= re - le
				righe.append("Resistenza kikuyu: −%d" % (re - le))
			for id in ordine:
				if tipo(id) in ["prov_n", "nairobi"] and popolazione(id) > 0 and int(X(id)["ter"]) > 0:
					d -= 1
					righe.append("Coloni intimiditi a %s: −1" % nome_sp(id))
			if ins_n("nairobi") == 0:
				d += 2
				righe.append("Nessun Mau Mau a Nairobi: +2")
			var fuori := false
			for id in ordine:
				if tipo(id) != "giungla" and int(X(id)["b"]) > 0:
					fuori = true
			if not fuori:
				d += 2
				righe.append("Nessuna Base fuori dalle giungle: +2")
	for r in righe:
		nota("  " + r)
	if d == 0:
		nota("Volontà Politica invariata (%d)." % int(s["pw"]))
	cambia_pw(d, "Propaganda")
	call("camp_fase_pw")
	var pw := int(s["pw"])
	if cellule():
		if pw <= 0:
			fine_partita("ins", "La Volontà Politica britannica crolla a 0: vittoria %s!" % nome_faz("ins"))
			return
		if ultima_propaganda():
			fine_partita("brit", "Ultima Propaganda superata: vittoria britannica!")
			return
	else:
		if pw <= 2:
			fine_partita("ins", "Volontà Politica a %d: vittoria %s!" % [pw, nome_faz("ins")])
			return
		if pw >= 18:
			fine_partita("brit", "Volontà Politica a %d: vittoria britannica!" % pw)
			return
		if ultima_propaganda():
			if pw < 10:
				fine_partita("ins", "Fine del mazzo con Volontà Politica %d: vittoria %s." % [pw, nome_faz("ins")])
			elif pw > 10:
				fine_partita("brit", "Fine del mazzo con Volontà Politica %d: vittoria britannica." % pw)
			else:
				fine_partita("pareggio", "Fine del mazzo con Volontà Politica 10: pareggio.")
			return
	match gioco():
		"palestina":
			accoda([_a("ins", "pal_rapina"), _a("brit", "intel"), _a("", "pal_haganah"), _a("brit", "pal_redeploy_b"), _a("ins", "pal_redeploy_i"), _a("", "reset")])
		"cipro":
			accoda([_a("ins", "cip_armi"), _a("brit", "intel"), _a("brit", "cip_redeploy_b"), _a("ins", "cip_redeploy_i"), _a("", "reset")])
		"malesia":
			accoda([_a("", "mal_risorse"), _a("brit", "mal_pacify"), _a("ins", "mal_agitate"), _a("brit", "mal_redeploy"), _a("", "reset")])
		"kenya":
			accoda([_a("", "ken_risorse"), _a("brit", "ken_reward"), _a("ins", "ken_oath"), _a("brit", "ken_redeploy"), _a("ins", "ken_campi"), _a("brit", "reset_ken")])


func _a(f: String, passo: String) -> Dictionary:
	return {"t": "prop", "f": f, "passo": passo}


# ---------------------------------------------------------------- Palestina

func prop_pal_rapina() -> void:
	if not ordine.any(func(x): return _rob_ok(x)):
		return
	if si_no("ins", "Espropri: vuoi eseguire una Rapina in 1 spazio?", "esproprio"):
		op_rob("ins", {"max": 1, "limitata": true, "passaggio": true})


func prop_intel() -> void:
	var a: Array = s["intel"]
	if a.is_empty():
		pesca_intel(1)
		return
	var n := a.size() / 2
	for i in n:
		var v = chiedi("brit", "Devi scartare metà dei tuoi Intel (%d di %d): quale scarti?" % [i + 1, n], _opz_intel(), {"tag": "scarta_intel"})
		if ferma():
			return
		scarta_intel(int(v))
	if n:
		nota("I Britannici scartano %d Intel." % n)


func prop_pal_haganah() -> void:
	var h := int(s["haganah"])
	if h == 0:
		pesca_intel(1)
	elif h == 4:
		accoda([_a("ins", "pal_haganah_dep")])


func prop_pal_haganah_dep() -> void:
	if disp("b") <= 0:
		return
	var sp = scegli_spazio("ins", "Cooperazione dell'Haganah: piazza 1 Deposito d'armi in un Distretto o Città con Cellula", func(x): return tipo(x) in ["distretto", "citta"] and gue(x) > 0 and int(X(x)["b"]) < 2, true, "haganah_dep", "Non piazzare")
	if ferma() or sp == null:
		return
	piazza(sp, "b", 1)
	nota("Deposito d'armi a %s." % nome_sp(sp))


func prop_pal_redeploy_b() -> void:
	# Polizia verso Ferrovie e spazi con pezzi britannici, poi Truppe verso Città o Ferrovie
	_ridispiega("brit", "p", func(x): return tipo(x) == "ferrovia" or cubi(x) > 0, "Ridispiegamento: Polizia verso %s?")
	if ferma():
		return
	_ridispiega("brit", "t", func(x): return tipo(x) in ["citta", "ferrovia"], "Ridispiegamento: Truppe verso %s?")


## Sposte libere: sceglie una destinazione alla volta e quante unità prendere dagli altri spazi.
func _ridispiega(f: String, k: String, dest_ok: Callable, testo: String, origine_ok: Callable = func(_x): return true, obbliga: bool = false) -> void:
	var usate: Array = []
	for giro in 12:
		var dest = scegli_spazio(f, testo % nome_pezzo(k, 2) if testo.contains("%s") else testo, func(x): return not (x in usate) and dest_ok.call(x) and ordine.any(func(y): return y != x and int(X(y)[k]) > 0 and origine_ok.call(y)), true, "ridispiega_" + k, "Fine")
		if ferma() or dest == null:
			return
		usate.append(dest)
		raccogli(f, dest, k, func(y): return origine_ok.call(y), "Ridispiegamento", "ridispiega_n")
		if ferma():
			return


func prop_pal_redeploy_i() -> void:
	# 1 Cellula verso ogni Città senza Coprifuoco, poi 1 Deposito verso un Distretto/Città con Cellula
	for c in ordine:
		if tipo(c) != "citta" or int(X(c)["cf"]) > 0:
			continue
		var da = scegli_spazio("ins", "Ridispiegamento: sposti 1 Cellula a %s? Da dove?" % nome_sp(c), func(x): return x != c and gue(x) > 0, true, "redeploy_cella", "Nessuna")
		if ferma():
			return
		if da != null:
			muovi(da, c, "u" if int(X(da)["u"]) > 0 else "a", 1)
			nota("1 Cellula da %s a %s." % [nome_sp(da), nome_sp(c)])
	_sposta_deposito("ins", func(x): return tipo(x) in ["distretto", "citta"] and gue(x) > 0)


func _sposta_deposito(f: String, dest_ok: Callable) -> void:
	var da = scegli_spazio(f, "Ridispiegamento: vuoi spostare un Deposito d'armi? Da dove?", func(x): return int(X(x)["b"]) > 0 and ordine.any(func(y): return y != x and dest_ok.call(y) and int(X(y)["b"]) < 2), true, "redeploy_dep", "No")
	if ferma() or da == null:
		return
	var a = scegli_spazio(f, "Verso dove?", func(y): return y != da and dest_ok.call(y) and int(X(y)["b"]) < 2, false, "redeploy_dep_a")
	if ferma() or a == null:
		return
	muovi(da, a, "b", 1)
	nota("Deposito d'armi da %s a %s." % [nome_sp(da), nome_sp(a)])


# ---------------------------------------------------------------- Cipro

func prop_cip_armi() -> void:
	if disp("b") <= 0:
		return
	var sp = scegli_spazio("ins", "Armi per l'EOKA: piazza 1 Deposito in una Città o nei Monti con Cellula", func(x): return tipo(x) in ["citta", "montagna"] and gue(x) > 0 and int(X(x)["b"]) < 2, true, "eoka_armi", "Non piazzare")
	if ferma() or sp == null:
		return
	piazza(sp, "b", 1)
	nota("Deposito d'armi a %s." % nome_sp(sp))


func prop_cip_redeploy_b() -> void:
	_ridispiega("brit", "p", func(x): return cubi(x) > 0, "Ridispiegamento: Polizia verso %s?", func(y): return true)
	if ferma():
		return
	for id in ordine:
		if tipo(id) == "montagna" and int(X(id)["t"]) > 0:
			var n := int(X(id)["t"])
			var a = chiedi("brit", "Le %s nei %s devono tornare in una Base: quale?" % [pz(n, "t"), nome_sp(id)], [o("dhekelia", "Dhekelia"), o("akrotiri", "Akrotiri")], {"tag": "cip_base"})
			if ferma():
				return
			muovi(id, a, "t", n)
			nota("%s da %s a %s." % [pz(n, "t"), nome_sp(id), nome_sp(a)])


func prop_cip_redeploy_i() -> void:
	for id in ordine:
		if tipo(id) != "base":
			continue
		while gue(id) > 0:
			var a = scegli_spazio("ins", "Le Cellule a %s devono lasciare la Base: verso dove?" % nome_sp(id), func(x): return tipo(x) == "montagna" or (tipo(x) == "citta" and ins_n(x) > 0), false, "cip_via")
			if ferma() or a == null:
				return
			muovi(id, a, "a" if int(X(id)["a"]) > 0 else "u", 1)
	_sposta_deposito("ins", func(x): return gue(x) > 0 and base_ok(x))


# ---------------------------------------------------------------- Malesia

func prop_mal_risorse() -> void:
	var b := 0
	for id in ordine:
		if X(id)["ctrl"] == "brit":
			b += popolazione(id)
		if tipo(id) == "ec" and int(X(id)["sab"]) == 0:
			b += int(SP[id].get("econ", 6))
	cambia_ris("brit", b)
	var basi := 0
	for id in ordine:
		basi += int(X(id)["b"])
	cambia_ris("ins", 2 * basi)


func prop_mal_pacify() -> void:
	var gratis: bool = (s.get("camp", {}) as Dictionary).get("attivi", {}).get("E9", "") == "supporto"
	if gratis:
		s["tmp"]["pacifica_gratis"] = true
		nota("Relazione speciale: la Pacificazione non costa Risorse.")
	pacifica("brit", 2)
	s["tmp"].erase("pacifica_gratis")
	if gratis and not ferma():
		s["camp"]["attivi"].erase("E9")


func prop_mal_agitate() -> void:
	agita("ins", 2)


func prop_mal_redeploy() -> void:
	# obbligatorio: Truppe nei CE o in Province a Controllo MCP verso KL o Province a Controllo britannico
	for id in ordine:
		if int(X(id)["t"]) > 0 and (tipo(id) == "ec" or X(id)["ctrl"] == "ins"):
			while int(X(id)["t"]) > 0:
				var a = scegli_spazio("brit", "Le Truppe a %s devono spostarsi: verso dove?" % nome_sp(id), func(x): return x != id and (tipo(x) == "kl" or (tipo(x) in ["prov_m", "prov_g"] and X(x)["ctrl"] == "brit")), false, "mal_ritira")
				if ferma() or a == null:
					return
				var n = numero("brit", "Quante Truppe da %s a %s?" % [nome_sp(id), nome_sp(a)], 1, int(X(id)["t"]), "mal_ritira_n")
				if ferma():
					return
				muovi(id, a, "t", n)
	_ridispiega("brit", "p", func(x): return tipo(x) in ["ec", "kl"] or (tipo(x) in ["prov_m", "prov_g"] and X(x)["ctrl"] == "brit"), "Ridispiegamento: Polizia verso %s?")


# ---------------------------------------------------------------- Kenya

func prop_ken_risorse() -> void:
	var basi := 0
	for id in ordine:
		basi += int(X(id)["b"])
	cambia_ris("ins", basi)


func prop_ken_reward() -> void:
	if ordine.any(func(x): return _reward_ok(x)):
		sa_reward("brit", {})


func prop_ken_oath() -> void:
	if ordine.any(func(x): return _oath_ok(x)):
		sa_oath("ins", {})


func prop_ken_redeploy() -> void:
	for id in ordine:
		if tipo(id) == "giungla" and int(X(id)["t"]) > 0:
			while int(X(id)["t"]) > 0:
				var a = scegli_spazio("brit", "Le Truppe in %s devono uscire: verso dove?" % nome_sp(id), func(x): return x != id and (tipo(x) == "nairobi" or X(x)["ctrl"] == "brit"), false, "ken_ritira")
				if ferma() or a == null:
					return
				var n = numero("brit", "Quante Truppe da %s a %s?" % [nome_sp(id), nome_sp(a)], 1, int(X(id)["t"]), "ken_ritira_n")
				if ferma():
					return
				muovi(id, a, "t", n)
	_ridispiega("brit", "p", func(x): return tipo(x) == "nairobi" or (tipo(x) in ["prov_r", "prov_n"] and X(x)["ctrl"] == "brit"), "Ridispiegamento: Polizia verso %s?")


func prop_ken_campi() -> void:
	if cap("K31") == "u":
		return
	for id in ordine:
		if tipo(id) == "giungla":
			var v = chiedi("ins", "Campi nella foresta: Raduno gratuito in %s?" % nome_sp(id), [o("si", "Sì"), o("no", "No")], {"tag": "campi"})
			if ferma():
				return
			if v == "si":
				raduno_in("ins", id)
				if ferma():
					return


func prop_reset_ken() -> void:
	var v = chiedi("brit", "Fine del Round: spostare la Pipeline?", [o(-1, "A sinistra (-1)"), o(0, "Non spostare"), o(1, "A destra (+1)")], {"tag": "pipeline"})
	if ferma():
		return
	sposta_pipeline(int(v))
	prop_reset()


# ---------------------------------------------------------------- Reset comune

func prop_reset() -> void:
	match gioco():
		"palestina":
			if s["tmp"].has("curfews"):
				var lato: String = s["tmp"]["curfews"]
				for id in ordine:
					if int(X(id)["cf"]) > 0:
						if lato == "u":
							rimuovi_g(id, 1)
						else:
							piazza(id, "g", 1)
				s["tmp"].erase("curfews")
		"cipro":
			if cap("C18") == "u":
				for id in ordine:
					if int(X(id)["cf"]) > 0 and gue(id) > 0:
						rimuovi_g(id, gue(id), "prigione")
			var n := 0
			for id in ordine:
				if tipo(id) == "citta" and (int(X(id)["sab"]) > 0 or int(X(id)["cf"]) > 0):
					n += 1
			if n <= 3:
				sposta_opinione(-1)
			if s["tmp"].has("suez"):
				var k: int = s["tmp"]["suez"]
				s["tmp"].erase("suez")
				s["tmp"]["suez_rientro"] = k
	for id in ordine:
		var x = X(id)
		x["cf"] = 0
		x["sab"] = 0
		x["ter"] = 0
		clandestine(id)
	if cellule():
		var r := int(s["prigione"]) / 2
		s["prigione"] = int(s["prigione"]) - r
		s["disp"]["g"] = disp("g") + r
		if r:
			nota("%s %s di Prigione." % [pz(r, "g"), "esce" if r == 1 else "escono"])
		s["primo"] = "ins"
	if gioco() == "malesia":
		s["tmp"].erase("gurney")
		if int(s["comandante"]) < 2:
			s["comandante"] = int(s["comandante"]) + 1
			nota("Nuovo Comandante: %s." % ["Gurney", "Briggs", "Templer"][int(s["comandante"])])
	s["tmp"].erase("loans")
	nota("Reset: segnalini rimossi, %s clandestine." % nome_pezzo("g", 2))
	if s["tmp"].has("suez_rientro"):
		accoda([_a("brit", "suez")])
	call("camp_fine_reset")


func prop_suez() -> void:
	var k: int = s["tmp"].get("suez_rientro", 0)
	for i in k:
		var a = chiedi("brit", "Crisi di Suez: le Truppe rientrano. In quale Base va la Truppa n. %d?" % (i + 1), [o("dhekelia", "Dhekelia"), o("akrotiri", "Akrotiri")], {"tag": "cip_base"})
		if ferma():
			return
		X(a)["t"] = int(X(a)["t"]) + 1
	s["tmp"].erase("suez_rientro")
	nota("Crisi di Suez: %s rientrano nelle Basi." % pz(k, "t"))
