## Campagna «End of Empire»: Prestigio imperiale, Politica coloniale, eventi di campagna e tabelle pre-belliche.
## I dati di campagna di una partita stanno in s["camp"]; tra una partita e l'altra li porta main.gd.
class_name Campagna
extends Eventi

const ORDINE := ["palestina", "malesia", "kenya", "cipro"]
const NOMI_ESITO := {"influenza": "Influenza", "uscita": "Uscita", "abbandono": "Abbandono", "resa": "Resa"}
const NOMI_POLITICA := {"stay": "Mantenere la rotta", "firm": "Tenere duro", "concessions": "Concessioni"}
const TABELLA := {
	"firm": {"influenza": 2, "uscita": 1, "abbandono": -3, "resa": -5},
	"stay": {"influenza": 1, "uscita": 0, "abbandono": -2, "resa": -4},
	"concessions": {"influenza": 0, "uscita": -1, "abbandono": -1, "resa": -3},
}
const PREBELLICHE := {
	"palestina": ["L'Agenzia Ebraica rifiuta il Movimento di Resistenza Unito: Haganah a Supporto (3) con 1 Deposito e 2 Cellule sul tracciato, Volontà Politica 16.",
		"Repressione preventiva: i Britannici mandano in Prigione una Cellula di una Città e vi piazzano un Coprifuoco.",
		"Nasce il Movimento di Resistenza Unito (storico): nessun cambiamento.",
		"Nasce il Movimento di Resistenza Unito (storico): nessun cambiamento.",
		"Attacchi coordinati alle ferrovie: l'Irgun piazza 2 Cellule disponibili sulle Ferrovie.",
		"Alleanza Irgun-Haganah: in gioco il Palmach (P13) ombreggiato; l'Irgun non può usare il Terrore con l'Haganah a 3 o 4."],
	"malesia": ["I piantatori chiedono repressione: Terrore al posto di una Guerriglia a Johore e a Perak; Volontà Politica 10, Risorse MCP 8.",
		"Gent chiede rinforzi: 4 Truppe in più a Kuala Lumpur.",
		"Piantatori uccisi, dichiarata l'Emergenza (storico): nessun cambiamento.",
		"Piantatori uccisi, dichiarata l'Emergenza (storico): nessun cambiamento.",
		"L'MCP organizza scioperi: una Guerriglia in ogni Centro economico.",
		"I Britannici sottovalutano l'MCP: Volontà Politica 14 e l'MCP è primo idoneo."],
	"kenya": ["I Britannici reprimono i militanti: Pipeline a 2, Volontà Politica 13; via i Mau Mau da Nairobi, che passa alla Resistenza.",
		"Arrivano i King's African Rifles: 4 Truppe in più a Nairobi.",
		"Operazione Jock Scott (storico): nessun cambiamento.",
		"Operazione Jock Scott (storico): nessun cambiamento.",
		"I giuramenti si diffondono in città: una Guerriglia in più a Nairobi, che passa alla Resistenza.",
		"Reti Mau Mau non scoperte: in gioco l'Ala passiva (K3) ombreggiata; Volontà Politica 14."],
	"cipro": ["Aumentano le pattuglie navali: in gioco il Blocco della Royal Navy (C9) chiaro; Opinione internazionale a Criticata (3).",
		"Makarios contrario alla guerriglia: via la Cellula dei Monti Troodos; l'EOKA sposta il Deposito in una Città con Cellula.",
		"Sequestrata l'Agios Georgios (storico): nessun cambiamento.",
		"Sequestrata l'Agios Georgios (storico): nessun cambiamento.",
		"Scoppiano rivolte: una Cellula attiva e un Sabotaggio in una Città a caso.",
		"L'Agios Georgios sfugge per un pelo: Cellula e Deposito nei Monti di Kyrenia; i Britannici pescano 2 Intel."],
}

static var _camp_dati: Dictionary = {}


static func dati_campagna() -> Dictionary:
	if _camp_dati.is_empty():
		var f := FileAccess.open("res://dati/campagna.json", FileAccess.READ)
		if f:
			var x = JSON.parse_string(f.get_as_text())
			if x is Dictionary:
				for e in x["eventi_campagna"]:
					_camp_dati[e["id"]] = e
	return _camp_dati


func in_campagna() -> bool:
	return not (s.get("camp", {}) as Dictionary).is_empty()


func camp_attivo(id: String) -> bool:
	return in_campagna() and (s["camp"]["attivi"] as Dictionary).has(id)


func cambia_prestigio(d: int, motivo: String) -> void:
	if not in_campagna() or d == 0:
		return
	var v: int = clamp(int(s["camp"]["prestigio"]) + d, 0, 15)
	s["camp"]["prestigio"] = v
	nota("Prestigio imperiale %s%d (%s): ora %d" % ["+" if d > 0 else "", d, motivo, v])


# ---------------------------------------------------------------- preparazione

func _prepara_campagna(c: Dictionary) -> void:
	s["camp"] = {"prestigio": int(c.get("prestigio", 13)), "politica": "stay", "eventi": c.get("eventi", []),
		"prev": str(c.get("prev", "")), "prewar": 0, "attivi": {}, "truppe_carta": 0, "truppe_dove": "", "esito": "", "storia": []}
	var pw = c.get("prewar", 0)
	var r := 0
	if str(pw) == "caso":
		r = dado()
	elif int(pw) > 0:
		r = int(pw)
	s["camp"]["prewar"] = r
	if r == 0:
		return
	var esclusi: Array = []
	match gioco():
		"palestina":
			match r:
				1:
					s["haganah"] = 3
					s["pw"] = 16
					s["disp"]["g"] = disp("g") - 2
					s["disp"]["b"] = disp("b") - 1
					s["haganah_pezzi"]["4"] = 2 + 10
				6:
					s["cap"]["P13"] = "s"
					esclusi.append("P13")
		"malesia":
			match r:
				1:
					for id in ["johore", "perak"]:
						if gue(id) > 0:
							rimuovi_g(id, 1)
						X(id)["ter"] = 1
					s["pw"] = 10
					s["ris"]["ins"] = 8
				2:
					s["disp"]["t"] = disp("t") - 4
					X("kl")["t"] = int(X("kl")["t"]) + 4
				5:
					for id in ["ec_stagno", "ec_gomma"]:
						s["disp"]["g"] = disp("g") - 1
						X(id)["u"] = int(X(id)["u"]) + 1
				6:
					s["pw"] = 14
					s["primo"] = "ins"
		"kenya":
			match r:
				1:
					s["pipeline"] = 2
					s["pw"] = 13
					var x := X("nairobi")
					s["disp"]["g"] = disp("g") + int(x["u"]) + int(x["a"])
					s["disp"]["b"] = disp("b") + int(x["b"])
					x["u"] = 0
					x["a"] = 0
					x["b"] = 0
					x["sup"] = -1
				2:
					s["disp"]["t"] = disp("t") - 4
					X("nairobi")["t"] = int(X("nairobi")["t"]) + 4
				5:
					s["disp"]["g"] = disp("g") - 1
					X("nairobi")["u"] = int(X("nairobi")["u"]) + 1
					X("nairobi")["sup"] = -1
				6:
					s["cap"]["K3"] = "s"
					esclusi.append("K3")
					s["pw"] = 14
		"cipro":
			match r:
				1:
					s["cap"]["C9"] = "u"
					esclusi.append("C9")
					s["opinione"] = 3
				6:
					X("kyrenia")["u"] = int(X("kyrenia")["u"]) + 1
					X("kyrenia")["b"] = int(X("kyrenia")["b"]) + 1
					s["disp"]["g"] = disp("g") - 1
					s["disp"]["b"] = disp("b") - 1
	s["esclusi"] = esclusi
	for id in ordine:
		_aggiorna_controllo(id, false)


## Primo atto della partita di campagna: parti della tabella pre-bellica con scelte, poi il primo evento di campagna.
func camp_inizio(_a: Dictionary) -> void:
	var r := int(s["camp"]["prewar"])
	if r > 0:
		nota("Tabella pre-bellica (%d): %s" % [r, PREBELLICHE[gioco()][r - 1]])
	match gioco():
		"palestina":
			if r == 2:
				var c = scegli_spazio("brit", "Repressione preventiva: in quale Città arresti una Cellula?", func(x): return tipo(x) == "citta" and gue(x) > 0, false, "pre_citta")
				if ferma():
					return
				if c != null:
					rimuovi_g(c, 1, "prigione")
					_piazza_coprifuoco("brit", c)
			elif r == 5:
				for k in 2:
					var f = scegli_spazio("ins", "Attacchi alle ferrovie: su quale Ferrovia piazzi una Cellula? (%d/2)" % (k + 1), func(x): return tipo(x) == "ferrovia", false, "pre_ferr")
					if ferma():
						return
					if f != null:
						piazza(f, "g", 1)
		"cipro":
			if r == 2:
				rimuovi_g("troodos", 1)
				if int(X("troodos")["b"]) > 0:
					var c = scegli_spazio("ins", "Makarios: in quale Città con Cellula sposti il Deposito dei Troodos?", func(x): return tipo(x) == "citta" and gue(x) > 0 and int(X(x)["b"]) < 2, false, "pre_dep")
					if ferma():
						return
					if c != null:
						muovi("troodos", c, "b", 1)
			elif r == 5:
				var citta: Array = []
				for id in ordine:
					if tipo(id) == "citta":
						citta.append(id)
				var c: String = citta[dado() - 1] if citta.size() >= 6 else citta[0]
				if disp("g") > 0:
					s["disp"]["g"] = disp("g") - 1
					X(c)["a"] = int(X(c)["a"]) + 1
				X(c)["sab"] = int(X(c)["sab"]) + 1
				nota("Rivolte a %s: Cellula attiva e Sabotaggio." % nome_sp(c))
			elif r == 6:
				pesca_intel(2)
	camp_evento({"n": 0})


func camp_evento(a: Dictionary) -> void:
	var lista: Array = s["camp"]["eventi"]
	var n := int(a.get("n", 0))
	if n >= lista.size():
		return
	var id: String = lista[n]
	var e: Dictionary = dati_campagna().get(id, {})
	s["camp"]["ultimo"] = id
	nota("— Evento di campagna: %s —" % e.get("titolo", id))
	if has_method("ce_" + id):
		call("ce_" + id)


func camp_politica(_a: Dictionary) -> void:
	var opz: Array = []
	for k in ["stay", "firm", "concessions"]:
		var t: Dictionary = TABELLA[k]
		opz.append(o(k, "%s (Influenza %+d, Uscita %+d, Abbandono %+d, Resa %+d)" % [NOMI_POLITICA[k], t["influenza"], t["uscita"], t["abbandono"], t["resa"]]))
	var v = chiedi("brit", "Politica coloniale per il resto della partita:", opz, {"tag": "politica", "mostra": true})
	if ferma():
		return
	s["camp"]["politica"] = v
	nota("Politica coloniale: %s." % NOMI_POLITICA[v])


func camp_ritorno(_a: Dictionary) -> void:
	var n := int(s["camp"]["truppe_carta"])
	if n <= 0:
		return
	var dove: String = s["camp"]["truppe_dove"]
	var filtro := func(x):
		if dove == "nairobi_base":
			return tipo(x) in ["nairobi", "base"]
		if gioco() == "malesia":
			return tipo(x) == "kl"
		return tipo(x) in ["citta", "nairobi", "kl"]
	var dest = scegli_spazio("brit", "Le %s sulla carta di campagna tornano in gioco: dove?" % pz(n, "t"), filtro, false, "camp_ritorno")
	if ferma():
		return
	if dest == null:
		s["disp"]["t"] = disp("t") + n
	else:
		X(dest)["t"] = int(X(dest)["t"]) + n
		_dopo(dest)
		nota("%s tornano a %s." % [pz(n, "t"), nome_sp(dest)])
	s["camp"]["truppe_carta"] = 0


## Mette fino a n Truppe sulla carta di campagna (da Disponibili, poi dalla mappa).
func _truppe_su_carta(n: int, dove: String, silenzioso: bool = false) -> int:
	var prese := 0
	while prese < n and disp("t") > 0:
		s["disp"]["t"] = disp("t") - 1
		prese += 1
	while prese < n:
		var sp = scegli_spazio("brit", "Da dove prendi una Truppa per la carta? (%d/%d)" % [prese + 1, n], func(x): return int(X(x)["t"]) > 0, false, "camp_truppe")
		if ferma() or sp == null:
			break
		X(sp)["t"] = int(X(sp)["t"]) - 1
		_dopo(sp)
		prese += 1
	s["camp"]["truppe_carta"] = int(s["camp"]["truppe_carta"]) + prese
	s["camp"]["truppe_dove"] = dove
	if prese and not silenzioso:
		nota("%s sulla carta di campagna fino al prossimo Reset." % pz(prese, "t"))
	return prese


func _truppe_totali() -> int:
	var t := disp("t")
	for id in ordine:
		t += int(X(id)["t"])
	return t


# ---------------------------------------------------------------- eventi di campagna

func ce_E1() -> void:
	var n := numero("brit", "Spartizione: quante Truppe metti sulla carta (ogni 2 riducono la perdita di 1)?", 0, min(4, _truppe_totali()), "camp_n")
	if ferma():
		return
	n = _truppe_su_carta(n, "citta")
	if ferma():
		return
	cambia_prestigio(-(3 - n / 2), "Spartizione")


func ce_E2() -> void:
	var n := numero("brit", "Birmania: quante Truppe metti sulla carta (fino a 3)?", 0, min(3, _truppe_totali()), "camp_n")
	if ferma():
		return
	n = _truppe_su_carta(n, "citta")
	if ferma():
		return
	var d := dado()
	nota("Dado %d contro %d Truppe." % [d, n])
	cambia_prestigio(1 if d <= n else -2, "Birmania")


func _scelta_truppe(nome: String, dove: String) -> void:
	var opz: Array = [o("perdi", "Prestigio imperiale −1")]
	if _truppe_totali() >= 2:
		opz.append(o("truppe", "2 Truppe sulla carta e un dado (1-4: +1, 5-6: −2)"))
	var v = chiedi("brit", nome + ":", opz, {"tag": "camp_scelta", "mostra": true})
	if ferma():
		return
	if v == "perdi":
		cambia_prestigio(-1, nome)
		return
	_truppe_su_carta(2, dove)
	if ferma():
		return
	var d := dado()
	nota("Dado: %d." % d)
	cambia_prestigio(1 if d <= 4 else -2, nome)


func ce_E3() -> void:
	_scelta_truppe("Costa d'Oro", "citta")


func ce_E4() -> void:
	if gioco() == "palestina":
		cambia_pw(2, "Guerra fredda")
		cambia_prestigio(1, "Guerra fredda")
	elif int(s["ris"]["brit"]) >= 20:
		cambia_prestigio(1, "Guerra fredda")
	else:
		s["ris"]["brit"] = 20
		nota("Risorse britanniche a 20.")


func ce_E5() -> void:
	if gioco() == "palestina":
		if si_no("brit", "«Banditi»: vuoi Perquisire 1 spazio (e fare lì una Detenzione di massa)?", "camp_si"):
			var sp = scegli_spazio("brit", "In quale spazio perquisisci?", func(_x): return true, false, "camp_sp")
			if ferma() or sp == null:
				return
			op_search("brit", {"max": 1, "limitata": true, "filtro": func(x): return x == sp})
			if ferma():
				return
			if tipo(sp) == "citta" and int(X(sp)["cf"]) > 0 and int(X(sp)["t"]) >= 3:
				detenzione_in(sp)
		if ferma():
			return
		if ordine.any(func(x): return _rob_ok(x)) and si_no("ins", "«Banditi»: l'Irgun vuole Rapinare in 1 spazio?", "camp_si"):
			op_rob("ins", {"max": 1, "limitata": true, "passaggio": true})
	else:
		if si_no("brit", "«Banditi»: vuoi fare Rappresaglia in 1 spazio?", "camp_si"):
			sa_reprisal("brit", {"max": 1})
		if ferma():
			return
		if si_no("ins", "«Banditi»: l'MCP vuole fare Estorsione in 2 spazi?", "camp_si"):
			sa_extort("ins", {})


func ce_E6() -> void:
	var ok_sp := func(x): return gue(x) > 0 and cubi(x) > ins_n(x)
	if not ordine.any(ok_sp):
		return
	if not si_no("brit", "Guerra sporca: Prestigio imperiale −1 per rimuovere fino a 3 %s?" % nome_pezzo("g", 2), "camp_si"):
		return
	cambia_prestigio(-1, "Guerra sporca")
	var fatti: Array = []
	for k in 3:
		var sp = scegli_spazio("brit", "Guerra sporca: da dove rimuovi (%d/3)?" % (k + 1), ok_sp, true, "camp_sp")
		if ferma() or sp == null:
			break
		rimuovi_g(sp, 1)
		if gioco() == "malesia" and not (sp in fatti):
			X(sp)["ter"] = int(X(sp)["ter"]) + 1
		fatti.append(sp)


func ce_E7() -> void:
	if gioco() == "palestina":
		s["camp"]["attivi"]["E7"] = "reset"
		nota("Fino al prossimo Reset le Operazioni britanniche scelgono al massimo 2 spazi.")
	else:
		var ec = scegli_spazio("brit", "Stanchezza della guerra: in quale Centro economico metti il Sabotaggio?", func(x): return tipo(x) == "ec", false, "camp_ec")
		if ferma() or ec == null:
			return
		X(ec)["sab"] = 1


func ce_E8() -> void:
	s["camp"]["attivi"]["E8"] = "pw"


func ce_E9() -> void:
	s["camp"]["attivi"]["E9"] = "reset" if gioco() == "palestina" else "supporto"


func ce_E10() -> void:
	_scelta_truppe("Nyasaland", "nairobi_base")


func ce_E11() -> void:
	var opz: Array = [o("perdi", "Prestigio imperiale −2")]
	if _truppe_totali() >= 2:
		opz.append(o("truppe", "Togli per sempre 2 Truppe da questa partita e Prestigio −1"))
	var v = chiedi("brit", "Zona del Canale:", opz, {"tag": "camp_scelta", "mostra": true})
	if ferma():
		return
	if v == "perdi":
		cambia_prestigio(-2, "Zona del Canale")
		return
	var prima := int(s["camp"]["truppe_carta"])
	_truppe_su_carta(2, "", true)
	if ferma():
		return
	var tolte: int = int(s["camp"]["truppe_carta"]) - prima
	s["camp"]["truppe_carta"] = prima
	s["fuori_g"] = int(s["fuori_g"]) + tolte
	nota("%s tolte da questa partita." % pz(tolte, "t"))
	cambia_prestigio(-1, "Zona del Canale")


func ce_E12() -> void:
	var v = chiedi("brit", "Operazione Musketeer:", [o("perdi", "Prestigio imperiale −1"), o("dadi", "Tirano entrambi: se vince il britannico +2, altrimenti meno la differenza")], {"tag": "camp_scelta", "mostra": true})
	if ferma():
		return
	if v == "perdi":
		cambia_prestigio(-1, "Musketeer")
		return
	var b := dado()
	var i := dado()
	nota("Dado britannico %d, dado insorto %d." % [b, i])
	cambia_prestigio(2 if b > i else -(i - b), "Musketeer")


func ce_E13() -> void:
	if gioco() == "kenya":
		var fatti: Array = []
		for k in 2:
			if int(s["fuori"]) <= 0:
				break
			var sp = scegli_spazio("brit", "Guerra civile kikuyu: 1 Polizia fuori gioco in uno spazio a Controllo britannico con Guerriglie", func(x): return not (x in fatti) and X(x)["ctrl"] == "brit" and gue(x) > 0, true, "camp_sp")
			if ferma() or sp == null:
				break
			fatti.append(sp)
			s["fuori"] = int(s["fuori"]) - 1
			X(sp)["p"] = int(X(sp)["p"]) + 1
			_dopo(sp)
	else:
		var sp = scegli_spazio("ins", "Scontri tra comunità: Sabotaggio in uno spazio con Cellule e Polizia?", func(x): return gue(x) > 0 and int(X(x)["p"]) > 0, true, "camp_sp")
		if ferma() or sp == null:
			return
		X(sp)["sab"] = int(X(sp)["sab"]) + 1


func ce_E14() -> void:
	var prev: String = s["camp"]["prev"]
	var bene := prev in ["influenza", "uscita"]
	var primo := "brit" if bene else "ins"
	nota("Lezioni apprese: partita precedente %s." % NOMI_ESITO.get(prev, "sconosciuta"))
	for k in 2:
		operazione_limitata_scelta(primo)
		if ferma():
			return
	operazione_limitata_scelta(altra(primo))


func ce_E15() -> void:
	s["camp"]["attivi"]["E15"] = "reset" if gioco() == "kenya" else "pw"


func ce_E16() -> void:
	s["camp"]["attivi"]["E16"] = "pw"


func ce_E17() -> void:
	s["camp"]["attivi"]["E17"] = "pw"


func ce_E18() -> void:
	s["camp"]["attivi"]["E18"] = "pw"


## Alla fase di Volontà Politica: effetti degli eventi di campagna (prima della verifica della vittoria).
func camp_fase_pw() -> void:
	if not in_campagna():
		return
	var at: Dictionary = s["camp"]["attivi"]
	var pw := int(s["pw"])
	if at.has("E8"):
		if gioco() == "palestina" and coprifuochi_mappa() > 1:
			cambia_prestigio(-1, "Nazioni Unite")
		elif gioco() == "malesia":
			var sup := 0
			var opp := 0
			for id in ordine:
				if int(X(id)["sup"]) > 0:
					sup += popolazione(id)
				elif int(X(id)["sup"]) < 0:
					opp += popolazione(id)
			if opp > sup:
				cambia_prestigio(-1, "Nazioni Unite")
	if at.has("E16"):
		if (gioco() == "kenya" and int(s["pipeline"]) > 2) or (gioco() == "cipro" and coprifuochi_mappa() > 2):
			cambia_prestigio(-1, "Convenzione dei diritti umani")
	var soglia := 10 if gioco() == "kenya" else 5
	if at.has("E17") and pw > soglia:
		cambia_prestigio(1, "Partito conservatore")
	if at.has("E18") and pw < soglia:
		cambia_prestigio(-1, "Movimento per la libertà coloniale")
	for k in at.keys():
		if at[k] == "pw":
			at.erase(k)


func camp_fine_reset() -> void:
	if not in_campagna():
		return
	var at: Dictionary = s["camp"]["attivi"]
	for k in at.keys():
		if at[k] == "reset":
			at.erase(k)
	var nuovi: Array = []
	if int(s["camp"]["truppe_carta"]) > 0:
		nuovi.append({"t": "camp", "f": "brit", "passo": "ritorno"})
	if int(s["prop_fatte"]) == 1:
		nuovi.append({"t": "camp", "f": "brit", "passo": "politica"})
		nuovi.append({"t": "camp", "f": "brit", "passo": "evento", "n": 1})
	elif int(s["prop_fatte"]) == 2:
		nuovi.append({"t": "camp", "f": "brit", "passo": "evento", "n": 2})
	accoda(nuovi)


# ---------------------------------------------------------------- esito della partita

func esito_per(pw: int, prop: int) -> String:
	if cellule():
		if pw <= 0:
			return "abbandono" if prop >= int(s["prop_tot"]) else "resa"
		return "influenza" if pw >= 6 else "uscita"
	if pw >= 18:
		return "influenza"
	if pw >= 10:
		return "uscita"
	if pw >= 3:
		return "abbandono"
	return "resa"


func fine_partita(vincitore: String, motivo: String) -> void:
	super.fine_partita(vincitore, motivo)
	if not in_campagna() or s["camp"]["esito"] != "":
		return
	var es := esito_per(int(s["pw"]), int(s["prop_fatte"]))
	s["camp"]["esito"] = es
	var d: int = TABELLA[s["camp"]["politica"]][es]
	nota("Esito della campagna in %s: %s (politica %s)." % [{"palestina": "Palestina", "malesia": "Malesia", "kenya": "Kenya", "cipro": "Cipro"}[gioco()], NOMI_ESITO[es], NOMI_POLITICA[s["camp"]["politica"]]])
	cambia_prestigio(d, "esito della partita")


## Stima del Prestigio in palio se la partita finisse adesso (usata dall'IA).
func stima_prestigio() -> float:
	if not in_campagna():
		return 0.0
	var pw: int = clamp(int(s["pw"]) + int(call("stima_propaganda")), 0, int(s["pw_max"]))
	var es := esito_per(pw, int(s["prop_tot"]))
	return float(int(s["camp"]["prestigio"]) + int(TABELLA[s["camp"]["politica"]][es]))
