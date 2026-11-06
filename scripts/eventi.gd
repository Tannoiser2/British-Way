## Eventi delle carte dei quattro giochi.
class_name Eventi
extends Propaganda


func evento(f: String, cd: Dictionary) -> void:
	var id: String = cd["id"]
	var lato = "u"
	if cd.has("testo_s"):
		lato = chiedi(f, "Quale testo dell'Evento %s?" % cd["titolo"], [o("u", "Chiaro: " + str(cd.get("sott_u", ""))), o("s", "Ombreggiato: " + str(cd.get("sott_s", "")))], {"tag": "ev_lato", "mostra": true})
		if ferma():
			return
	nota("%s: Evento «%s» (%s)." % [nome_faz(f), cd["titolo"], "testo chiaro" if lato == "u" else "testo ombreggiato"])
	if str(cd.get("cap", "")) != "":
		s["cap"][id] = "d" if cd["cap"] == "dual" else lato
		nota("Capacità attiva per il resto della partita.")
		return
	if has_method("ev_" + id):
		call("ev_" + id, f, lato)


func evento_possibile(cd: Dictionary) -> bool:
	return not cd.get("propaganda", false)


# ---------------------------------------------------------------- aiuti

func ok(_x) -> bool:
	return true


## Piazza fino a n pezzi k, uno alla volta, in spazi che soddisfano filtro (per_spazio: massimo per spazio).
func piazza_scelta(f: String, n: int, k: String, filtro: Callable, testo: String, per_spazio: int = 99, obblig: bool = false) -> int:
	var fatti := 0
	var conta := {}
	for i in n:
		var dk = "g" if k == "g" else k
		if disp(dk) <= 0 and (cellule() or k == "b"):
			break
		var sp = scegli_spazio(f, "%s (%d/%d)" % [testo, i + 1, n], func(x): return int(conta.get(x, 0)) < per_spazio and filtro.call(x) and (k != "b" or (base_ok(x) and int(X(x)["b"]) < 2)) and (not (k in ["t", "p"]) or brit_ok(x)), not obblig, "ev_piazza", "Basta così")
		if ferma() or sp == null:
			break
		if piazza(sp, k, 1) > 0:
			conta[sp] = int(conta.get(sp, 0)) + 1
			fatti += 1
	if fatti:
		nota("Piazzat%s %s." % ["o" if fatti == 1 else "i", pz(fatti, k)])
	return fatti


## Rimuove fino a n Cellule/Guerriglie (o pezzi k) da spazi scelti.
func rimuovi_scelta(f: String, n: int, k: String, filtro: Callable, testo: String, dest: String = "disp", per_spazio: int = 99) -> int:
	var fatti := 0
	var conta := {}
	for i in n:
		var ha = func(x): return (gue(x) > 0 if k == "g" else int(X(x)[k]) > 0)
		var sp = scegli_spazio(f, "%s (%d/%d)" % [testo, i + 1, n], func(x): return int(conta.get(x, 0)) < per_spazio and ha.call(x) and filtro.call(x), true, "ev_rimuovi", "Basta così")
		if ferma() or sp == null:
			break
		var t = rimuovi_g(sp, 1, dest) if k == "g" else rimuovi(sp, k, 1, dest)
		if t > 0:
			conta[sp] = int(conta.get(sp, 0)) + 1
			fatti += 1
			if k == "b":
				nota("%s rimosso da %s." % [nome_pezzo("b"), nome_sp(sp)])
	if fatti and k != "b":
		nota("Rimoss%s %s." % ["a" if fatti == 1 else "e", pz(fatti, k)])
	return fatti


func pw_stella(d: int, motivo: String) -> void:
	if d < 0 and cap("P9") == "u":
		d += 1
	cambia_pw(d, motivo)


func op_libera(f: String, op: String, p: Dictionary = {}) -> void:
	var q := {"gratis": true, "max": 99 if not cellule() else 3, "op": op}
	q.merge(p, true)
	nota("%s: %s (dall'Evento)." % [nome_faz(f), nome_op(op)])
	call("op_" + op, f, q)


func operazione_limitata_scelta(f: String, filtro: Callable = Callable(), gratis: bool = true) -> void:
	var ops: Array = []
	for id in OPS[gioco()][f]:
		if op_possibile(f, id, true):
			ops.append(o(id, nome_op(id)))
	if ops.is_empty():
		return
	var op = chiedi(f, "Operazione Limitata (dall'Evento):", ops, {"tag": "op", "mostra": true})
	if ferma():
		return
	var p := {"limitata": true, "max": 1, "gratis": gratis, "op": op}
	if filtro.is_valid():
		p["filtro"] = filtro
	nota("%s: %s limitata." % [nome_faz(f), nome_op(op)])
	call("op_" + op, f, p)


func citta(x: String) -> bool:
	return tipo(x) == "citta"


func costiero(x: String) -> bool:
	return tipo(x) == "distretto" and SP[x].get("costa", false)


# ================================================================ PALESTINA

func ev_P1(f: String, l: String) -> void:
	if l == "u":
		var c = scegli_spazio("brit", "Operazione Agatha: in quale Città fai la Perquisizione?", func(x): return citta(x), false, "ev_citta")
		if ferma() or c == null:
			return
		op_search("brit", {"max": 1, "limitata": true, "filtro": func(x): return x == c})
		if ferma():
			return
		if int(X(c)["cf"]) > 0 and int(X(c)["t"]) >= 3:
			detenzione_in(c)
		elif int(X(c)["cf"]) > 0:
			detenzione_in(c)
		sposta_haganah(-1)
	else:
		sposta_haganah(1)
		if int(s["haganah"]) == 4:
			op_sabotage("ins", {"max": 1, "limitata": true, "no_extra": true})


func ev_P2(_f: String, l: String) -> void:
	if l == "u":
		for id in ordine:
			if costiero(id) and int(X(id)["t"]) > 0 and gue(id) > 0:
				var n := rimuovi_g(id, gue(id), "prigione")
				nota("%s in Prigione da %s." % [pz(n, "g"), nome_sp(id)])
	else:
		pw_stella(-3, "Affare Exodus")


func ev_P3(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio(f, "Togli un segnalino Terrore", func(x): return int(X(x)["ter"]) > 0, false, "ev_terrore")
		if ferma() or sp == null:
			return
		X(sp)["ter"] = int(X(sp)["ter"]) - 1
		sposta_haganah(-1)
	else:
		var c = scegli_spazio(f, "Hotel King David: in quale Città con Cellula clandestina?", func(x): return citta(x) and int(X(x)["u"]) > 0, false, "ev_citta")
		if ferma() or c == null:
			return
		X(c)["ter"] = int(X(c)["ter"]) + 2
		nota("2 Terrori a %s." % nome_sp(c))


func ev_P4(_f: String, _l: String) -> void:
	var sab := 0
	var pezzi := 0
	for id in ordine:
		if costiero(id):
			sab += int(X(id)["sab"]) + int(X(id)["ter"])
			pezzi += ins_n(id)
	if sab == 0:
		cambia_pw(2, "Immigrazione illegale bloccata")
	else:
		pw_stella(-min(3, (sab + pezzi) / 2), "Immigrazione illegale")


func ev_P5(f: String, l: String) -> void:
	if l == "u":
		var n: int = min(2, int(s["prigione"]))
		s["prigione"] = int(s["prigione"]) - n
		s["fuori_g"] = int(s["fuori_g"]) + n
		nota("%s tolte dal gioco." % pz(n, "g"))
	else:
		_evasione()


func _evasione() -> void:
	var n := int(s["prigione"])
	s["prigione"] = 0
	s["disp"]["g"] = disp("g") + n
	nota("Evasione: %s tornano Disponibili." % pz(n, "g"))


func ev_P6(f: String, l: String) -> void:
	if l == "u":
		op_search("brit", {"max": 3, "no_intel": true})
	else:
		for id in ordine:
			if citta(id) and int(X(id)["t"]) == 0:
				piazza(id, "g", 1)
		nota("Una Cellula in ogni Città senza Truppe.")


func ev_P7(f: String, l: String) -> void:
	for id in ordine:
		if l == "u" and gue(id) > 1:
			if si_no(f, "Lehi: rimuovi 1 Cellula a %s?" % nome_sp(id), "ev_rim"):
				rimuovi_g(id, 1)
			if ferma():
				return
		elif l == "s" and int(X(id)["u"]) > 0 and int(X(id)["p"]) > 0:
			rimuovi(id, "p", 1)
			nota("1 Polizia uccisa a %s." % nome_sp(id))


func ev_P8(f: String, l: String) -> void:
	if l == "u":
		cambia_pw(2, "Truman")
		op_libera("brit", "deploy", {"max": 3})
	else:
		pw_stella(-coprifuochi_mappa(), "Truman")


func ev_P10(f: String, l: String) -> void:
	if l == "u":
		piazza_scelta(f, disp("p"), "p", func(x): return tipo(x) == "ferrovia", "Polizia sulle Ferrovie")
	else:
		var tot := 0
		for id in ordine:
			tot += int(X(id)["p"])
		var n := tot / 2
		rimuovi_scelta(f, n, "p", ok, "Fondi scarsi: togli 1 Polizia")


func ev_P11(f: String, l: String) -> void:
	if l == "u":
		var c = scegli_spazio("brit", "Operazione Shark: in quale Città?", func(x): return citta(x), false, "ev_citta")
		if ferma() or c == null:
			return
		op_search("brit", {"max": 1, "limitata": true, "filtro": func(x): return x == c})
		if ferma():
			return
		if int(X(c)["t"]) > 0:
			assalto_in("brit", c)
		if ferma():
			return
		var sp = scegli_spazio("brit", "Rimuovi un Deposito d'armi entro 1 spazio da %s" % nome_sp(c), func(x): return int(X(x)["b"]) > 0 and (x == c or x in SP[c]["adj"]), true, "ev_dep")
		if ferma() or sp == null:
			return
		rimuovi(sp, "b", 1)
		cambia_pw(1, "Deposito rimosso")
	else:
		op_travel("ins", {"max": 2, "filtro": func(x): return int(X(x)["cf"]) > 0})


func ev_P12(f: String, l: String) -> void:
	if l == "u":
		rimuovi_scelta(f, 2, "b", ok, "Togli un Deposito d'armi")
	else:
		piazza_scelta(f, 2, "b", func(x): return gue(x) > 0, "Piazza un Deposito d'armi")


func ev_P14(f: String, l: String) -> void:
	if l == "u":
		var fatte: Array = []
		for k in 2:
			var c = scegli_spazio("brit", "Legge marziale: Perquisizione in una Città", func(x): return citta(x) and not (x in fatte), true, "ev_citta")
			if ferma() or c == null:
				break
			fatte.append(c)
			op_search("brit", {"max": 1, "limitata": true, "filtro": func(x): return x == c})
			if ferma():
				return
		var c2 = scegli_spazio("brit", "Detenzione di massa: in quale Città con Coprifuoco?", func(x): return x in fatte and int(X(x)["cf"]) > 0, true, "ev_det")
		if ferma() or c2 == null:
			return
		detenzione_in(c2)
	else:
		for id in ordine:
			if int(X(id)["cf"]) > 0:
				piazza(id, "g", 1)


func ev_P15(f: String, l: String) -> void:
	if l == "u":
		sposta_haganah(-1)
		var sp = scegli_spazio(f, "Togli un Sabotaggio", func(x): return int(X(x)["sab"]) > 0, true, "ev_sab")
		if ferma() or sp == null:
			return
		X(sp)["sab"] = int(X(sp)["sab"]) - 1
	else:
		sposta_haganah(1)
		op_sabotage("ins", {"max": 1, "limitata": true, "no_extra": true})


func ev_P16(f: String, l: String) -> void:
	if l == "u":
		for k in 2:
			operazione_limitata_scelta("brit")
			if ferma():
				return
		sa_restore("brit", {})
	else:
		for k in min(2, int(s["prigione"])):
			var c = scegli_spazio("brit", "Cellule rilasciate: in quale Città?", func(x): return citta(x), false, "ev_citta")
			if ferma() or c == null:
				return
			s["prigione"] = int(s["prigione"]) - 1
			X(c)["u"] = int(X(c)["u"]) + 1
			_dopo(c)


func ev_P19(f: String, l: String) -> void:
	if l == "u":
		rimuovi_scelta(f, 2, "g", ok, "Rimuovi una Cellula")
		if ferma():
			return
		if rimuovi_scelta(f, 1, "b", ok, "Rimuovi un Deposito d'armi") > 0:
			cambia_pw(1, "Deposito rimosso")
	else:
		var d := dado()
		nota("Dado: %d." % d)
		if d > 2:
			cambia_pw(-2, "attacchi all'estero")


func ev_P20(_f: String, l: String) -> void:
	if l == "u":
		if not ordine.any(func(x): return tipo(x) == "ferrovia" and int(X(x)["sab"]) > 0):
			cambia_pw(2, "valore strategico")
	else:
		pw_stella(-2, "pressioni crescenti")


func ev_P21(f: String, l: String) -> void:
	if l == "u":
		sposta_haganah(-1)
		rimuovi_scelta(f, 2, "g", ok, "Rimuovi una Cellula")
	else:
		sposta_haganah(1)
		for id in ordine:
			if tipo(id) == "ferrovia" and _sabotage_ok(id):
				if si_no("ins", "Sabotaggio sulla %s?" % nome_sp(id), "ev_sab_ferr"):
					sabotaggio_in("ins", id)
				if ferma():
					return


func ev_P22(f: String, _l: String) -> void:
	var v = chiedi(f, "Agenzia Ebraica: sposta l'Haganah", [o(-1, "A sinistra"), o(1, "A destra")], {"tag": "haganah"})
	if ferma():
		return
	sposta_haganah(int(v))
	if f == "ins":
		operazione_limitata_scelta("ins")
	else:
		pesca_intel(1)


func ev_P24(_f: String, l: String) -> void:
	var t := 0
	for id in ordine:
		t += int(X(id)["ter"])
	cambia_pw(min(3, t) * (1 if l == "u" else -1), "Affare dei sergenti")


func ev_P26(f: String, _l: String) -> void:
	var op = "assault" if f == "brit" else "sabotage"
	var sas: Array = [o("nessuna", "Nessuna")]
	for id in SAS[gioco()][f]:
		var acc: Array = SAS[gioco()][f][id]
		if (acc.is_empty() or op in acc) and sa_possibile(f, id, op):
			sas.append(o(id, nome_op(id)))
	var sa = chiedi(f, "Veterani: Attività Speciale con %s?" % nome_op(op), sas, {"tag": "sa"})
	if ferma():
		return
	var p := {"max": 3, "gratis": true, "op": op, "no_extra": true}
	if sa == "terror":
		p["terror"] = true
	call("op_" + op, f, p)
	if ferma():
		return
	if sa != "nessuna" and sa != "terror":
		call("sa_" + sa, f, {"op": op})


func ev_P27(_f: String, l: String) -> void:
	if l == "u":
		s["tmp"]["loans"] = true
		operazione("brit", false, true)
		s["tmp"].erase("loans")
	else:
		pw_stella(-1, "Dunkerque finanziaria")
		s["tmp"]["passa_forzato"] = "brit"


func ev_P28(f: String, l: String) -> void:
	if l == "u":
		var n := 0
		for id in ordine:
			if int(X(id)["p"]) > 0 and gue(id) > 0:
				n += 1
		pesca_intel(n)
	else:
		var sp = scegli_spazio("ins", "Sabotaggio in uno spazio con Polizia", func(x): return int(X(x)["p"]) > 0 and _sabotage_ok(x), true, "ev_sab")
		if ferma() or sp == null:
			return
		if sabotaggio_in("ins", sp):
			rimuovi(sp, "p", int(X(sp)["p"]))
			nota("Tutta la Polizia a %s eliminata." % nome_sp(sp))


func ev_P29(_f: String, l: String) -> void:
	s["tmp"]["curfews"] = l
	nota("L'effetto si applicherà all'inizio del prossimo Reset.")


func ev_P30(f: String, l: String) -> void:
	if l == "u":
		rimuovi_scelta(f, 3, "g", func(x): return int(X(x)["p"]) > 0, "Rimuovi 1 Cellula da uno spazio con Polizia", "disp", 1)
	else:
		rimuovi_scelta(f, 2, "p", ok, "Rimuovi 1 Polizia")
		cambia_pw(-1, "uccisione controversa")


func ev_P31(f: String, l: String) -> void:
	if l == "u":
		rimuovi_scelta(f, 1, "g", func(x): return int(X(x)["t"]) > 0, "Manda in Prigione una Cellula", "prigione")
	else:
		piazza_scelta(f, 3, "g", func(x): return tipo(x) in ["citta", "distretto"], "Piazza una Cellula")


# ================================================================ CIPRO

func ev_C1(f: String, l: String) -> void:
	if l == "u":
		var fatti: Array = []
		for k in 2:
			var sp = scegli_spazio("brit", "Ripristino: scegli uno spazio con cubi e senza EOKA", func(x): return not (x in fatti) and cubi(x) > 0 and ins_n(x) == 0, true, "restore")
			if ferma() or sp == null:
				return
			fatti.append(sp)
			X(sp)["cf"] = 0
			X(sp)["sab"] = 0
	else:
		sposta_opinione(2)


func ev_C2(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio("brit", "Assalto con i documenti di Grivas: scegli uno spazio con Truppe", func(x): return int(X(x)["t"]) > 0 and ins_n(x) > 0, false, "ev_ass")
		if ferma() or sp == null:
			return
		var capn := assalto_cap(sp)
		while capn > 0 and int(X(sp)["b"]) > 0:
			rimuovi(sp, "b", 1)
			capn -= 1
			cambia_pw(1, "Deposito rimosso")
			pesca_intel(1)
		var n: int = min(capn, int(X(sp)["a"]))
		rimuovi(sp, "a", n)
	else:
		for k in 3:
			operazione_limitata_scelta("ins")
			if ferma():
				return


func ev_C3(f: String, l: String) -> void:
	if l == "u":
		op_patrol("brit", {"max": 1, "limitata": true})
		if ferma():
			return
		cambia_pw(1, "Lobster Pot")
	else:
		sa_propagandize("ins", {"max": 1, "filtro": func(x): return int(X(x)["cf"]) > 0})


func ev_C4(f: String, _l: String) -> void:
	var tolte := rimuovi_scelta("brit", 3, "t", ok, "Crisi di Suez: togli una Truppa", "fuori")
	# le Truppe tolte non restano fuori gioco: rientrano al prossimo Reset
	s["fuori_g"] = int(s["fuori_g"]) - tolte
	s["tmp"]["suez"] = int(s["tmp"].get("suez", 0)) + tolte
	if tolte < 3:
		var resto: int = 3 - tolte
		for id in ordine:
			while resto > 0 and int(X(id)["t"]) > 0:
				X(id)["t"] = int(X(id)["t"]) - 1
				s["tmp"]["suez"] = int(s["tmp"]["suez"]) + 1
				resto -= 1
				_dopo(id)


func ev_C5(f: String, l: String) -> void:
	if l == "u":
		sposta_opinione(-2)
	else:
		var sp = scegli_spazio(f, "Piazza un Sabotaggio in una Città con Polizia ed EOKA", func(x): return citta(x) and int(X(x)["p"]) > 0 and ins_n(x) > 0, false, "ev_sab")
		if ferma() or sp == null:
			return
		X(sp)["sab"] = int(X(sp)["sab"]) + 1


func ev_C6(f: String, l: String) -> void:
	if l == "u":
		for m in ["troodos", "kyrenia"]:
			raccogli("brit", m, "t", ok, "Pepperpot")
			if ferma():
				return
			raccogli("brit", m, "p", ok, "Pepperpot")
			if ferma():
				return
			_search_effetto("brit", m, true)
	else:
		op_travel("ins", {"max": 2, "filtro": func(x): return tipo(x) == "montagna"})


func ev_C7(_f: String, l: String) -> void:
	for id in ordine:
		if int(X(id)["cf"]) > 0:
			if l == "u":
				rimuovi_g(id, gue(id), "prigione")
			elif int(s["prigione"]) > 0:
				s["prigione"] = int(s["prigione"]) - 1
				X(id)["u"] = int(X(id)["u"]) + 1
	nota("Effetto applicato agli spazi con Coprifuoco.")


func ev_C8(f: String, l: String) -> void:
	if l == "u":
		rimuovi_scelta(f, 2, "g", ok, "Rimuovi una Cellula")
	else:
		sa_propagandize("ins", {"max": 1, "senza_cellula": true, "filtro": func(x): return int(X(x)["cf"]) > 0})


func ev_C11(_f: String, l: String) -> void:
	s["opinione"] = 0 if l == "u" else 2
	nota("Opinione internazionale: %s." % nome_opinione(int(s["opinione"])))


func ev_C12(f: String, l: String) -> void:
	if l == "u":
		for k in 2:
			operazione_limitata_scelta("brit")
			if ferma():
				return
		var sas: Array = []
		for id in SAS[gioco()]["brit"]:
			if sa_possibile("brit", id, ""):
				sas.append(o(id, nome_op(id)))
		sas.append(o("nessuna", "Nessuna"))
		var sa = chiedi("brit", "Attività Speciale qualsiasi:", sas, {"tag": "sa"})
		if ferma() or sa == "nessuna":
			return
		call("sa_" + sa, "brit", {})
	else:
		op_sabotage("ins", {"max": 3, "no_extra": true})


func ev_C14(f: String, l: String) -> void:
	if l == "u":
		if int(s["opinione"]) <= 1:
			rimuovi_scelta(f, 3, "g", ok, "Rimuovi una Cellula")
	else:
		piazza_scelta(f, 3, "g", func(x): return tipo(x) in ["citta", "montagna"], "Piazza una Cellula")


func ev_C15(f: String, l: String) -> void:
	if l == "u":
		var c = scegli_spazio("brit", "John Harding: Coprifuoco in quale Città con Truppe?", func(x): return citta(x) and int(X(x)["t"]) > 0, false, "ev_citta")
		if ferma() or c == null:
			return
		_piazza_coprifuoco("brit", c)
		if ferma():
			return
		op_search("brit", {"max": 1, "limitata": true, "filtro": func(x): return x == c})
		if ferma():
			return
		if int(X(c)["t"]) > 0 and ins_n(c) > 0:
			assalto_in("brit", c)
	else:
		sposta_opinione(2)


func ev_C16(f: String, l: String) -> void:
	if l == "u":
		var dep_fatto := false
		var fatti: Array = []
		for k in 3:
			var sp = scegli_spazio(f, "Pattuglie Q: spazio con Truppe ed EOKA (%d/3)" % (k + 1), func(x): return not (x in fatti) and int(X(x)["t"]) > 0 and ins_n(x) > 0, true, "ev_q")
			if ferma() or sp == null:
				return
			fatti.append(sp)
			if int(X(sp)["b"]) > 0 and not dep_fatto and (gue(sp) == 0 or si_no(f, "Rimuovi il Deposito invece di una Cellula?", "ev_q_dep")):
				rimuovi(sp, "b", 1)
				dep_fatto = true
				cambia_pw(1, "Deposito rimosso")
			elif gue(sp) > 0:
				rimuovi_g(sp, 1)
			if ferma():
				return
	else:
		var fatti: Array = []
		for k in 2:
			var sp = scegli_spazio(f, "Piazza un Sabotaggio in una Città con Truppe", func(x): return not (x in fatti) and citta(x) and int(X(x)["t"]) > 0, true, "ev_sab")
			if ferma() or sp == null:
				return
			fatti.append(sp)
			X(sp)["sab"] = int(X(sp)["sab"]) + 1


func ev_C19(f: String, l: String) -> void:
	if l == "u":
		var m = scegli_spazio("brit", "In quale spazio di Monti?", func(x): return tipo(x) == "montagna", false, "ev_monti")
		if ferma() or m == null:
			return
		op_search("brit", {"max": 1, "limitata": true, "filtro": func(x): return x == m})
		if ferma():
			return
		if int(X(m)["t"]) > 0 and ins_n(m) > 0:
			assalto_in("brit", m)
	else:
		var m = scegli_spazio(f, "Verso quale spazio di Monti attiri le Truppe?", func(x): return tipo(x) == "montagna", false, "ev_monti")
		if ferma() or m == null:
			return
		var tot := 0
		for id in ordine:
			if citta(id) and int(X(id)["t"]) > 0 and tot < 6:
				var n = numero(f, "Quante Truppe da %s?" % nome_sp(id), 0, min(6 - tot, int(X(id)["t"])), "ev_n")
				if ferma():
					return
				tot += muovi(id, m, "t", n)


func ev_C20(f: String, l: String) -> void:
	if l == "u":
		for k in 2:
			var c = scegli_spazio(f, "Coprifuoco in una Città con Truppe", func(x): return citta(x) and int(X(x)["t"]) > 0 and int(X(x)["cf"]) == 0, true, "ev_cf")
			if ferma() or c == null:
				return
			_piazza_coprifuoco(f, c)
	else:
		piazza_scelta(f, 3, "g", func(x): return citta(x), "Piazza una Cellula")


func ev_C21(f: String, l: String) -> void:
	if l == "u":
		var n := 0
		for id in ordine:
			if citta(id) and int(X(id)["t"]) > 0 and int(X(id)["p"]) > 0 and ins_n(id) == 0 and int(X(id)["sab"]) == 0 and int(X(id)["cf"]) == 0:
				n += 1
		cambia_pw(n, "programma di sviluppo")
	else:
		piazza_scelta(f, 2, "g", func(x): return citta(x), "Piazza una Cellula")


func ev_C22(f: String, _l: String) -> void:
	var v = chiedi(f, "Governo greco: sposta l'Opinione internazionale", [o(-2, "2 a sinistra"), o(-1, "1 a sinistra"), o(0, "Non spostare"), o(1, "1 a destra"), o(2, "2 a destra")], {"tag": "opinione"})
	if ferma():
		return
	sposta_opinione(int(v))
	var w = chiedi(f, "Poi:", [o("piazza", "Piazza 2 Cellule in Città"), o("rimuovi", "Rimuovi 2 Cellule")], {"tag": "ev_greco"})
	if ferma():
		return
	if w == "piazza":
		piazza_scelta(f, 2, "g", func(x): return citta(x), "Piazza una Cellula")
	else:
		rimuovi_scelta(f, 2, "g", ok, "Rimuovi una Cellula")


func ev_C24(f: String, l: String) -> void:
	if l == "u":
		piazza_scelta(f, disp("p"), "p", func(x): return cubi(x) > 0, "Piazza Polizia")
		if ferma():
			return
		op_patrol("brit", {"max": 2})
	else:
		var fatti: Array = []
		for k in 2:
			var sp = scegli_spazio(f, "Sabotaggio in una Città con Cellule e Polizia", func(x): return not (x in fatti) and citta(x) and gue(x) > 0 and int(X(x)["p"]) > 0, true, "ev_sab")
			if ferma() or sp == null:
				return
			fatti.append(sp)
			X(sp)["sab"] = int(X(sp)["sab"]) + 1


func ev_C26(f: String, _l: String) -> void:
	var fatti: Array = []
	for k in 2:
		var sp = scegli_spazio(f, "Volkan/TMT: spazio con Cellule e Polizia", func(x): return not (x in fatti) and gue(x) > 0 and int(X(x)["p"]) > 0, true, "ev_sab")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		rimuovi_g(sp, 1)
		X(sp)["sab"] = int(X(sp)["sab"]) + 1
		nota("Sabotaggio a %s." % nome_sp(sp))


func ev_C27(f: String, l: String) -> void:
	if l == "u":
		rimuovi_scelta(f, 1, "g", ok, "Manda in Prigione una Cellula", "prigione")
		if ferma():
			return
		sa_interrogate("brit", {})
	else:
		_evasione()


func ev_C28(f: String, l: String) -> void:
	var basi := ["dhekelia", "akrotiri"]
	if l == "u":
		for b in basi:
			if int(X(b)["sab"]) == 0 and ins_n(b) == 0:
				cambia_pw(1, "Base sicura")
	else:
		for b in basi:
			piazza(b, "g", 1)
		for b in basi:
			if int(X(b)["u"]) > 0:
				if si_no("ins", "Sabotaggio a %s?" % nome_sp(b), "ev_sab_base"):
					sabotaggio_in("ins", b)
				if ferma():
					return


func ev_C29(f: String, l: String) -> void:
	if l == "u":
		var v = chiedi(f, "Piano Macmillan: −1 VP per", [o("sab", "Togliere 2 Sabotaggi"), o("op", "Spostare l'Opinione di 2 a sinistra"), o("no", "Nulla")], {"tag": "ev_mac"})
		if ferma() or v == "no":
			return
		cambia_pw(-1, "compromesso")
		if v == "op":
			sposta_opinione(-2)
		else:
			for k in 2:
				var sp = scegli_spazio(f, "Togli un Sabotaggio", func(x): return int(X(x)["sab"]) > 0, true, "ev_sab")
				if ferma() or sp == null:
					return
				X(sp)["sab"] = int(X(sp)["sab"]) - 1
	else:
		if not si_no(f, "Piano respinto: +1 VP per Sabotare fino a 3 spazi?", "ev_mac2"):
			return
		cambia_pw(1, "piano respinto")
		op_sabotage("ins", {"max": 3, "no_extra": true})


func ev_C30(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio("brit", "Perquisizione in 1 spazio, poi Assalto", ok, false, "ev_sp")
		if ferma() or sp == null:
			return
		op_search("brit", {"max": 1, "limitata": true, "filtro": func(x): return x == sp})
		if ferma():
			return
		if int(X(sp)["t"]) > 0 and ins_n(sp) > 0:
			assalto_in("brit", sp)
	else:
		for id in ordine:
			if citta(id) and int(X(id)["u"]) > 0:
				if si_no("ins", "Sabotaggio a %s?" % nome_sp(id), "ev_sab_c"):
					sabotaggio_in("ins", id)
				if ferma():
					return


# ================================================================ MALESIA

func prov(x: String) -> bool:
	return tipo(x) in ["prov_m", "prov_g"]


func ev_M3(f: String, l: String) -> void:
	if l == "u":
		var v = chiedi(f, "Volantini:", [o("giungla", "1 Guerriglia da 2 spazi di Giungla"), o("monte", "2 Guerriglie da 1 spazio di Montagna")], {"tag": "ev_vol"})
		if ferma():
			return
		if v == "giungla":
			rimuovi_scelta(f, 2, "g", func(x): return tipo(x) == "prov_g", "Rimuovi 1 Guerriglia", "disp", 1)
		else:
			var sp = scegli_spazio(f, "Spazio di Montagna", func(x): return tipo(x) == "prov_m" and gue(x) > 0, false, "ev_sp")
			if ferma() or sp == null:
				return
			rimuovi_g(sp, 2)
	else:
		var sp = scegli_spazio(f, "Spazio con pezzi MCP", func(x): return ins_n(x) > 0, false, "ev_sp")
		if ferma() or sp == null:
			return
		var v = chiedi(f, "Piazza:", [o("g", "2 Guerriglie"), o("b", "1 Base")], {"tag": "ev_gb"})
		if ferma():
			return
		if v == "g":
			piazza(sp, "g", 2)
		else:
			piazza(sp, "b", 1)


func ev_M4(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio(f, "Nuovo Villaggio in una Provincia", func(x): return prov(x) and int(X(x)["nv"]) == 0 and disponibili_nv() > 0, false, "ev_nv")
		if ferma() or sp == null:
			return
		X(sp)["nv"] = 1
		_dopo(sp)
	else:
		piazza_scelta("ins", 2, "g", prov, "Piazza 1 Guerriglia in una Provincia", 1)


func ev_M5(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio(f, "Porta uno spazio in Opposizione a Neutrale", func(x): return int(X(x)["sup"]) < 0, false, "ev_sup")
		if ferma() or sp == null:
			return
		set_sup(sp, 0)
	else:
		_sposta_spazi(f, 2, -1, func(x): return ins_n(x) > 0)


func _sposta_spazi(f: String, n: int, d: int, filtro: Callable) -> void:
	var fatti: Array = []
	for k in n:
		var sp = scegli_spazio(f, "Sposta uno spazio di 1 livello verso %s" % ("il Supporto" if d > 0 else "l'Opposizione"), func(x): return not (x in fatti) and puo_sup(x) and (int(X(x)["sup"]) < 1 if d > 0 else int(X(x)["sup"]) > -1) and filtro.call(x), true, "ev_sup")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		sposta_sup(sp, d)
		nota("%s: ora %s." % [nome_sp(sp), nome_sup(int(X(sp)["sup"]))])


func ev_M6(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio(f, "Provincia con una Base", func(x): return prov(x) and int(X(x)["b"]) > 0, false, "ev_sp")
		if ferma() or sp == null:
			return
		attiva(sp, gue(sp))
		raccogli("brit", sp, "t", ok, "Chin Peng")
	else:
		for k in 2:
			operazione_limitata_scelta("ins")
			if ferma():
				return


func ev_M7(_f: String, l: String) -> void:
	if l == "u":
		cambia_ris("ins", -3)
		set_sup("kl", 1)
	else:
		cambia_ris("ins", 5)
		set_sup("kl", 0)


func ev_M9(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio("brit", "Rappresaglia in uno spazio con Truppe", func(x): return prov(x) and int(X(x)["t"]) > 0, false, "reprisal")
		if ferma() or sp == null:
			return
		set_sup(sp, 0)
		X(sp)["ter"] = max(1, int(X(sp)["ter"]))
		if gue(sp) > 0:
			var a = scegli_spazio("brit", "Sposta 1 Guerriglia in uno spazio adiacente", func(x): return x in SP[sp]["adj"], false, "reprisal_g")
			if ferma():
				return
			muovi(sp, a, "a" if int(X(sp)["a"]) > 0 else "u", 1)
		if ins_n(sp) > 0:
			assalto_in("brit", sp)
	else:
		var sp = scegli_spazio(f, "Porta una Provincia a Opposizione", prov, false, "ev_sup")
		if ferma() or sp == null:
			return
		set_sup(sp, -1)
		cambia_pw(-2, "massacro")


func ev_M10(f: String, l: String) -> void:
	if l == "u":
		piazza_scelta(f, 3, "p", func(x): return cubi(x) > 0, "Piazza 1 Polizia", 1)
	else:
		s["tmp"]["gurney"] = true
		nota("L'effetto del Comandante è annullato fino al Reset.")
		piazza_scelta(f, 1, "g", func(x): return true, "Piazza 1 Guerriglia")


func ev_M11(f: String, l: String) -> void:
	if l == "u":
		var n := 0
		for id in ordine:
			if tipo(id) == "prov_g":
				n += int(X(id)["b"])
		cambia_ris("ins", -n)
	else:
		_sposta_spazi(f, 1, -1, func(x): return int(X(x)["b"]) > 0)
		cambia_pw(-1, "defolianti")


func ev_M12(f: String, l: String) -> void:
	if l == "u":
		var fatti: Array = []
		for k in 2:
			var sp = scegli_spazio(f, "Provincia di Giungla senza Controllo MCP", func(x): return not (x in fatti) and tipo(x) == "prov_g" and X(x)["ctrl"] != "ins", true, "ev_sp")
			if ferma() or sp == null:
				return
			fatti.append(sp)
			piazza(sp, "p", 2)
	else:
		piazza_scelta(f, 1, "b", func(x): return tipo(x) == "prov_g", "Piazza una Base")


func ev_M13(f: String, l: String) -> void:
	if l == "u":
		piazza_scelta(f, 4, "p", func(x): return X(x)["ctrl"] == "brit", "Piazza 1 Polizia")
	else:
		_sposta_spazi(f, 1, -1, func(x): return int(X(x)["p"]) > 0)


func ev_M14(_f: String, l: String) -> void:
	if l == "u":
		cambia_ris("brit", 10)
		cambia_pw(1, "Corea")
	else:
		cambia_ris("brit", -4)


func ev_M15(f: String, l: String) -> void:
	if l == "u":
		op_train("brit", {"gratis": true, "max": 1, "limitata": true, "filtro": func(x): return x == "kl"})
		if ferma():
			return
		operazione_limitata_scelta("brit", func(x): return x == "kl" or x in SP["kl"]["adj"])
	else:
		piazza("kl", "g", 1)


func ev_M16(f: String, l: String) -> void:
	if l == "u":
		for k in 3:
			var sp = scegli_spazio("brit", "Deportazioni: rimuovi un pezzo MCP (%d/3)" % (k + 1), func(x): return X(x)["ctrl"] == "brit" and ins_n(x) > 0, true, "ev_rim")
			if ferma() or sp == null:
				return
			if int(X(sp)["b"]) > 0 and (gue(sp) == 0 or si_no("brit", "Rimuovi la Base?", "ev_base")):
				rimuovi(sp, "b", 1)
				cambia_pw(1, "Base rimossa")
			else:
				rimuovi_g(sp, 1)
			if ferma():
				return
	else:
		var sp = scegli_spazio(f, "Provincia verso l'Opposizione", func(x): return prov(x), false, "ev_sup")
		if ferma() or sp == null:
			return
		sposta_sup(sp, -1)
		piazza(sp, "g", 1)


func ev_M17(f: String, l: String) -> void:
	if l == "u":
		var fatti: Array = []
		for k in 2:
			var sp = scegli_spazio(f, "Attiva tutte le Guerriglie in uno spazio", func(x): return not (x in fatti) and int(X(x)["u"]) > 0, true, "ev_att")
			if ferma() or sp == null:
				break
			fatti.append(sp)
			attiva(sp, gue(sp))
		op_assault("brit", {"gratis": true, "max": 1, "limitata": true})
	else:
		for id in ordine:
			clandestine(id)


func ev_M19(f: String, l: String) -> void:
	if l == "u":
		var n := int(s["nv_tot"]) - disponibili_nv()
		for k in n:
			var v = "ris"
			if ordine.any(func(x): return gue(x) > 0):
				v = chiedi("ins", "Negazione del cibo (%d/%d): cosa perdi?" % [k + 1, n], [o("g", "Rimuovi 1 Guerriglia"), o("ris", "Perdi 1 Risorsa")], {"tag": "ev_cibo"})
				if ferma():
					return
			if v == "g":
				rimuovi_scelta("ins", 1, "g", ok, "Rimuovi una Guerriglia")
				if ferma():
					return
			else:
				cambia_ris("ins", -1)
	else:
		var n := 0
		for id in ordine:
			if ins_n(id) > 0 and int(X(id)["nv"]) > 0:
				n += 1
		cambia_ris("ins", n)


func ev_M20(f: String, l: String) -> void:
	if l == "u":
		for id in ordine:
			if tipo(id) == "ec":
				piazza(id, "p", 2)
		var sp = scegli_spazio("brit", "Nuovo Villaggio adiacente a un Centro economico", func(x): return prov(x) and int(X(x)["nv"]) == 0 and disponibili_nv() > 0 and SP[x]["adj"].any(func(a): return tipo(a) == "ec"), true, "ev_nv")
		if ferma() or sp == null:
			return
		X(sp)["nv"] = 1
		_dopo(sp)
	else:
		var sp = scegli_spazio(f, "Spazio con Nuovo Villaggio a Opposizione", func(x): return int(X(x)["nv"]) > 0, true, "ev_sup")
		if ferma():
			return
		if sp != null:
			set_sup(sp, -1)
		var ec = scegli_spazio(f, "Guerriglia in un Centro economico", func(x): return tipo(x) == "ec", false, "ev_ec")
		if ferma() or ec == null:
			return
		piazza(ec, "g", 1)


func ev_M21(f: String, l: String) -> void:
	var sp = scegli_spazio(f, "Spazio con Nuovo Villaggio", func(x): return int(X(x)["nv"]) > 0, false, "ev_nv")
	if ferma() or sp == null:
		return
	X(sp)["nv"] = 0
	if l == "u":
		set_sup(sp, 1)
	else:
		piazza(sp, "g", 1)


func ev_M22(f: String, l: String) -> void:
	if l == "u":
		_sposta_spazi(f, 2, 1, ok)
		cambia_pw(1, "partiti nazionalisti")
	else:
		op_rally("ins", {"gratis": true, "max": 3, "no_agitate": true})


func ev_M23(f: String, l: String) -> void:
	if l == "u":
		for id in ordine:
			if tipo(id) in ["ec", "kl"]:
				X(id)["sab"] = 0
				X(id)["ter"] = 0
	else:
		op_march("ins", {"gratis": true, "max": 1, "limitata": true})
		if ferma():
			return
		op_attack("ins", {"gratis": true, "max": 1, "limitata": true})


func ev_M24(f: String, _l: String) -> void:
	var v = chiedi(f, "Governo britannico:", [o("ris", "Risorse britanniche +6"), o("pw", "Volontà Politica −1")], {"tag": "ev_gov"})
	if ferma():
		return
	if v == "ris":
		cambia_ris("brit", 6)
	else:
		cambia_pw(-1, "nuova strategia")
	var d = chiedi(f, "Sposta il Comandante:", [o(-1, "Indietro"), o(1, "Avanti")], {"tag": "ev_com"})
	if ferma():
		return
	s["comandante"] = clamp(int(s["comandante"]) + int(d), 0, 2)
	nota("Comandante: %s." % ["Gurney", "Briggs", "Templer"][int(s["comandante"])])


func ev_M25(f: String, l: String) -> void:
	if l == "u":
		cambia_ris("brit", 6)
		for id in ordine:
			if tipo(id) == "ec":
				piazza(id, "p", 1)
	else:
		var sp = scegli_spazio(f, "Provincia da cui spostare tutte le Truppe", func(x): return prov(x) and int(X(x)["t"]) > 0, false, "ev_sp")
		if ferma() or sp == null:
			return
		var a = scegli_spazio(f, "Verso un Centro economico o Kuala Lumpur", func(x): return tipo(x) in ["ec", "kl"], false, "ev_sp2")
		if ferma() or a == null:
			return
		muovi(sp, a, "t", int(X(sp)["t"]))


func ev_M26(f: String, _l: String) -> void:
	var fatti: Array = []
	for k in 2:
		var sp = scegli_spazio(f, "Provincia a Controllo britannico con pezzi MCP", func(x): return not (x in fatti) and prov(x) and X(x)["ctrl"] == "brit" and ins_n(x) > 0, true, "ev_sp")
		if ferma() or sp == null:
			break
		fatti.append(sp)
		X(sp)["ter"] = int(X(sp)["ter"]) + 1
		set_sup(sp, 0)
	cambia_pw(-1, "punizioni collettive")


func ev_M29(f: String, l: String) -> void:
	if l == "u":
		var n = numero("brit", "Quante Risorse paghi (1 Guerriglia per Risorsa)?", 0, min(3, int(s["ris"]["brit"])), "ev_n")
		if ferma() or n == 0:
			return
		cambia_ris("brit", -n)
		rimuovi_scelta("brit", n, "g", ok, "Rimuovi una Guerriglia")
	else:
		var n: int = min(2, int(s["ris"]["brit"]))
		cambia_ris("brit", -n)
		cambia_ris("ins", n)


func ev_M30(f: String, l: String) -> void:
	if l == "u":
		cambia_ris("ins", -3)
		rimuovi_scelta(f, 2, "g", ok, "Rimuovi una Guerriglia")
	else:
		op_rally("ins", {"gratis": true, "max": 2, "no_agitate": true})
		if ferma():
			return
		agita("ins", 1, [], true)


func ev_M31(f: String, l: String) -> void:
	if l == "u":
		piazza_scelta(f, 4, "p", func(x): return X(x)["ctrl"] == "brit", "Piazza 1 Polizia")
	else:
		op_rally("ins", {"gratis": true, "max": 2, "no_agitate": true})
		if ferma():
			return
		_sposta_spazi("ins", 1, -1, ok)


func ev_M32(f: String, l: String) -> void:
	if l == "u":
		var vicino = func(x): return X(x)["ctrl"] == "brit" or SP[x]["adj"].any(func(a): return X(a)["ctrl"] == "brit")
		for k in 2:
			var sp = scegli_spazio("brit", "Sostituisci 1 Guerriglia con 1 Polizia", func(x): return gue(x) > 0 and brit_ok(x) and vicino.call(x), true, "ev_sep")
			if ferma() or sp == null:
				return
			rimuovi_g(sp, 1)
			piazza(sp, "p", 1)
	else:
		sa_intimidate("ins", {"max": 2})


# ================================================================ KENYA

func ev_K1(f: String, l: String) -> void:
	if l == "u":
		var b := int(X("nairobi")["b"])
		rimuovi("nairobi", "b", b)
		rimuovi_g("nairobi", 99)
		set_sup("nairobi", 1)
		sposta_pipeline(1)
		cambia_pw(b, "Basi rimosse")
	else:
		for k in 2:
			var v = "g"
			if int(X("nairobi")["b"]) < 2 and disp("b") > 0:
				v = chiedi(f, "Operazione Anvil: cosa piazzi a Nairobi (%d/2)?" % (k + 1), [o("g", "Guerriglia"), o("b", "Base")], {"tag": "ev_gb"})
				if ferma():
					return
			piazza("nairobi", v, 1)
		sposta_sup("nairobi", -1)


func ev_K2(_f: String, l: String) -> void:
	if l == "u":
		rimuovi_g("nairobi", 99)
		sposta_sup("nairobi", 1)
	else:
		piazza("nairobi", "g", 1)
		sposta_sup("nairobi", -1)


func ev_K4(f: String, _l: String) -> void:
	var sp = scegli_spazio(f, "Massacro di Lari: scegli una Provincia", func(x): return tipo(x) in ["prov_r", "prov_n"], false, "ev_sp")
	if ferma() or sp == null:
		return
	X(sp)["ter"] = int(X(sp)["ter"]) + 1
	set_sup(sp, 0)
	var altro := altra(f)
	var v = chiedi(altro, "Massacro di Lari: cosa piazzi a %s?" % nome_sp(sp), [o("g", "Una Guerriglia"), o("p", "Una Polizia"), o("no", "Nulla")], {"tag": "ev_lari"})
	if ferma() or v == "no":
		return
	piazza(sp, v, 1)


func ev_K6(f: String, l: String) -> void:
	if l == "u":
		_polizia_da_ovunque(f, 3, func(x): return tipo(x) == "prov_r" and X(x)["ctrl"] == "brit", 99)
	else:
		for id in ordine:
			if tipo(id) == "prov_r":
				var t := int(X(id)["ter"])
				X(id)["ter"] = 0
				piazza(id, "g", t)


## Piazza Polizia "da ovunque (anche fuori gioco)".
func _polizia_da_ovunque(f: String, n: int, filtro: Callable, per_spazio: int) -> void:
	var conta := {}
	for k in n:
		var sp = scegli_spazio(f, "Piazza 1 Polizia (%d/%d)" % [k + 1, n], func(x): return int(conta.get(x, 0)) < per_spazio and filtro.call(x), true, "ev_pol")
		if ferma() or sp == null:
			return
		conta[sp] = int(conta.get(sp, 0)) + 1
		if int(s["fuori"]) > 0:
			s["fuori"] = int(s["fuori"]) - 1
			X(sp)["p"] = int(X(sp)["p"]) + 1
			_dopo(sp)
		elif disp("p") > 0:
			piazza(sp, "p", 1)
		else:
			var da = scegli_spazio(f, "Da dove prendi la Polizia?", func(x): return x != sp and int(X(x)["p"]) > 0, true, "ev_pol_da")
			if ferma() or da == null:
				return
			muovi(da, sp, "p", 1)


func ev_K8(f: String, l: String) -> void:
	if l == "u":
		sposta_pipeline(1)
		var op = chiedi("brit", "Schieramento o Rastrellamento in 2 spazi?", [o("deploy", "Schieramento"), o("sweep", "Rastrellamento")], {"tag": "op"})
		if ferma():
			return
		call("op_" + op, "brit", {"max": 2, "gratis": true, "op": op})
	else:
		piazza_scelta("ins", 2, "g", func(x): return tipo(x) in ["prov_r", "prov_n"], "Piazza 1 Guerriglia in una Provincia", 1)


func ev_K9(f: String, l: String) -> void:
	if l == "u":
		for k in 2:
			operazione_limitata_scelta("brit")
			if ferma():
				return
		if si_no("brit", "Spostare la Pipeline di 1 a sinistra?", "ev_pipe"):
			sposta_pipeline(-1)
	else:
		if ordine.any(func(x): return int(X(x)["t"]) > 0 and int(X(x)["ter"]) > 0):
			cambia_pw(-1, "abusi")


func ev_K10(f: String, l: String) -> void:
	if l == "u":
		for id in ordine:
			if gue(id) > 2:
				rimuovi_g(id, 1)
	else:
		var sp = scegli_spazio("ins", "Spazio con Polizia", func(x): return int(X(x)["p"]) > 0, false, "ev_sp")
		if ferma() or sp == null:
			return
		piazza(sp, "g", 2)


func ev_K12(f: String, l: String) -> void:
	if l == "u":
		var fatti: Array = []
		for k in 2:
			var sp = scegli_spazio(f, "Attiva tutte le Guerriglie in una Provincia", func(x): return not (x in fatti) and tipo(x) in ["prov_r", "prov_n"] and int(X(x)["u"]) > 0, true, "ev_att")
			if ferma() or sp == null:
				return
			fatti.append(sp)
			attiva(sp, gue(sp))
	else:
		var sp = scegli_spazio(f, "Spazio con Mau Mau e Polizia", func(x): return ins_n(x) > 0 and int(X(x)["p"]) > 0, false, "ev_sp")
		if ferma() or sp == null:
			return
		rimuovi(sp, "p", 1)
		set_sup(sp, -1)


func ev_K13(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio(f, "Provincia non di Riserva a Lealtà", func(x): return tipo(x) == "prov_n" and popolazione(x) > 0, false, "ev_sp")
		if ferma() or sp == null:
			return
		set_sup(sp, 1)
		piazza(sp, "p", min(2, disp("p")), false)
	else:
		var da = scegli_spazio("ins", "Da quale spazio sposti le Truppe?", func(x): return int(X(x)["t"]) > 0, false, "ev_sp")
		if ferma() or da == null:
			return
		var a = scegli_spazio("ins", "Verso quale Provincia non di Riserva?", func(x): return x != da and tipo(x) == "prov_n", false, "ev_sp2")
		if ferma() or a == null:
			return
		muovi(da, a, "t", int(X(da)["t"]))


func ev_K14(f: String, l: String) -> void:
	for j in ["aberdares", "monte_kenya"]:
		if l == "u":
			rimuovi_g(j, 1)
	if l == "s":
		var j = scegli_spazio(f, "In quale Giungla di montagna?", func(x): return tipo(x) == "giungla", false, "ev_sp")
		if ferma() or j == null:
			return
		piazza(j, "b", 1)
		piazza(j, "g", 1)


func ev_K15(f: String, l: String) -> void:
	if l == "u":
		var nt = numero("brit", "Nairobi: quante Truppe piazzi?", 0, min(4, disp("t")), "ev_n")
		if ferma():
			return
		var np = numero("brit", "Nairobi: quanta Polizia piazzi?", 0, min(4 - nt, disp("p")), "ev_n")
		if ferma():
			return
		piazza("nairobi", "t", nt)
		piazza("nairobi", "p", np)
		op_sweep("brit", {"max": 1, "limitata": true, "filtro": func(x): return x == "nairobi"})
	else:
		piazza("nairobi", "g", 1)
		terrore_in("ins", "nairobi")


func ev_K16(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio("brit", "In quale spazio piazzi 4 Truppe?", ok, false, "ev_sp")
		if ferma() or sp == null:
			return
		piazza(sp, "t", 4)
		operazione_limitata_scelta("brit", func(x): return x == sp)
	else:
		var sp = scegli_spazio(f, "Provincia con Truppe a Resistenza", func(x): return tipo(x) in ["prov_r", "prov_n"] and int(X(x)["t"]) > 0, false, "ev_sp")
		if ferma() or sp == null:
			return
		set_sup(sp, -1)
		X(sp)["ter"] = int(X(sp)["ter"]) + 1


func ev_K17(f: String, l: String) -> void:
	if l == "u":
		var lista: Array = []
		for id in ordine:
			if tipo(id) == "prov_n":
				lista.append(id)
		for id in lista:
			_polizia_da_ovunque(f, 1, func(x): return x == id, 1)
			if ferma():
				return
	else:
		for id in ordine:
			if tipo(id) == "prov_n" and gue(id) > 0:
				rimuovi_g(id, 1)
				set_sup(id, -1)


func ev_K18(f: String, l: String) -> void:
	if l == "u":
		var j = scegli_spazio("brit", "In quale Giungla di montagna?", func(x): return tipo(x) == "giungla", false, "ev_sp")
		if ferma() or j == null:
			return
		op_sweep("brit", {"max": 1, "limitata": true, "filtro": func(x): return x == j})
		if ferma():
			return
		var m := 2
		rimuovi(j, "a", m)
	else:
		for j in ["aberdares", "monte_kenya"]:
			clandestine(j)


func ev_K19(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio(f, "Giungla con pezzi britannici in ogni spazio adiacente", func(x): return tipo(x) == "giungla" and int(X(x)["b"]) > 0 and SP[x]["adj"].all(func(a): return cubi(a) > 0), false, "ev_sp")
		if ferma() or sp == null:
			return
		rimuovi(sp, "b", 1)
		cambia_pw(1, "Base rimossa")
	else:
		var sp = scegli_spazio(f, "Provincia di Riserva a Resistenza", func(x): return tipo(x) == "prov_r" and popolazione(x) > 0, false, "ev_sp")
		if ferma() or sp == null:
			return
		set_sup(sp, -1)


func ev_K20(f: String, l: String) -> void:
	if l == "u":
		rimuovi_scelta(f, 2, "g", func(x): return int(X(x)["t"]) > 0, "Rimuovi 1 Guerriglia", "disp", 1)
	else:
		op_rally("ins", {"gratis": true, "max": 2})


func ev_K21(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio("brit", "Assalto in uno spazio", func(x): return int(X(x)["t"]) > 0 and ins_n(x) > 0, false, "ev_sp")
		if ferma() or sp == null:
			return
		assalto_in("brit", sp)
		attiva(sp, gue(sp))
	else:
		if rimuovi_scelta("ins", 1, "g", func(x): return int(X(x)["t"]) > 0, "Rimuovi 1 Guerriglia con Truppe") > 0:
			for id in ordine:
				clandestine(id)


func ev_K22(f: String, l: String) -> void:
	if l == "u":
		if rimuovi_scelta(f, 1, "b", func(x): return X(x)["ctrl"] == "brit", "Rimuovi 1 Base") > 0:
			cambia_pw(1, "Base rimossa")
	else:
		for k in 2:
			operazione_limitata_scelta("ins")
			if ferma():
				return


func ev_K23(f: String, l: String) -> void:
	if l == "u":
		_set_spazi(f, 2, 1, func(x): return tipo(x) in ["prov_n", "nairobi"] and popolazione(x) > 0)
		sposta_pipeline(1)
	else:
		_rimetti_pop(f)


func _set_spazi(f: String, n: int, v: int, filtro: Callable) -> void:
	var fatti: Array = []
	for k in n:
		var sp = scegli_spazio(f, "Porta uno spazio a %s" % nome_sup(v), func(x): return not (x in fatti) and filtro.call(x), true, "ev_sup")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		set_sup(sp, v)


func _rimetti_pop(f: String) -> void:
	var sp = scegli_spazio(f, "Rimetti 1 Popolazione in una Provincia di Riserva", func(x): return tipo(x) == "prov_r" and popolazione(x) < int(SP[x]["pop"]), false, "ev_pop")
	if ferma() or sp == null:
		return
	X(sp)["pop"] = popolazione(sp) + 1
	piazza(sp, "g", 1)
	_aggiorna_controllo(sp, true)
	nota("%s: Popolazione %d e una Guerriglia." % [nome_sp(sp), popolazione(sp)])


func ev_K24(f: String, l: String) -> void:
	if l == "u":
		op_deploy("brit", {"gratis": true})
		if ferma():
			return
		sa_reward("brit", {})
	else:
		cambia_pw(-int(s["pipeline"]), "repressione denunciata")
		sposta_pipeline(-1)


func ev_K25(_f: String, l: String) -> void:
	if l == "u":
		cambia_pw(2, "inchiesta")
		sposta_pipeline(-1)
	else:
		indignazione(true)


func ev_K26(f: String, _l: String) -> void:
	if rimuovi_scelta(f, 1, "b", func(x): return int(X(x)["t"]) > 0, "Rimuovi 1 Base") > 0:
		cambia_pw(1, "Base rimossa")
	if ferma():
		return
	indignazione(true)
	sposta_pipeline(1)


func ev_K27(f: String, l: String) -> void:
	if l == "u":
		sposta_pipeline(1)
		op_relocate("brit", {"max": 2, "max_reloc": 2})
	else:
		_rimetti_pop(f)


func ev_K29(f: String, l: String) -> void:
	if l == "u":
		_polizia_da_ovunque(f, 3, func(x): return tipo(x) == "prov_r" and X(x)["ctrl"] == "brit", 99)
	else:
		op_terror("ins", {"gratis": true, "max": 2})


func ev_K30(f: String, l: String) -> void:
	if l == "u":
		var sp = scegli_spazio(f, "Spazio in Resistenza da portare a Lealtà", func(x): return int(X(x)["sup"]) < 0, false, "ev_sup")
		if ferma() or sp == null:
			return
		set_sup(sp, 1)
		piazza(sp, "p", 1, false)
	else:
		var sp = scegli_spazio(f, "Spazio con Mau Mau e Polizia", func(x): return ins_n(x) > 0 and int(X(x)["p"]) > 0, false, "ev_sp")
		if ferma() or sp == null:
			return
		rimuovi(sp, "p", 1)
		set_sup(sp, -1)


func ev_K32(f: String, l: String) -> void:
	if l == "u":
		cambia_pw(1, "propaganda")
		var v = chiedi("brit", "Trasferimento o Rappresaglia in 1 spazio senza Indignazione?", [o("relocate", "Trasferimento"), o("reprisal", "Rappresaglia"), o("no", "Nessuno")], {"tag": "ev_k32"})
		if ferma() or v == "no":
			return
		if v == "relocate":
			op_relocate("brit", {"max": 1, "max_reloc": 1, "no_outrage": true})
		else:
			sa_reprisal("brit", {"max": 1, "no_outrage": true})
	else:
		cambia_pw(-int(s["pipeline"]), "atrocità svelate")
