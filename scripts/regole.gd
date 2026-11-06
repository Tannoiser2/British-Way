## Operazioni, Attività Speciali e Round di Propaganda dei quattro giochi di The British Way.
class_name Regole
extends Nucleo

const OPS := {
	"palestina": {"brit": ["deploy", "patrol", "search", "assault"], "ins": ["recruit", "travel", "sabotage", "rob"]},
	"cipro": {"brit": ["deploy", "patrol", "search", "assault"], "ins": ["recruit", "travel", "sabotage", "ambush"]},
	"malesia": {"brit": ["train", "garrison", "sweep", "assault"], "ins": ["rally", "march", "attack", "terror"]},
	"kenya": {"brit": ["deploy", "relocate", "sweep", "assault"], "ins": ["rally", "march", "terror"]},
}
## Attività speciali: id -> operazioni che possono accompagnare ([] = tutte).
const SAS := {
	"palestina": {"brit": {"restore": ["deploy"], "negotiate": ["deploy", "patrol", "search"], "detention": ["search", "assault"]},
		"ins": {"silence": [], "propagandize": [], "terror": ["sabotage"]}},
	"cipro": {"brit": {"restore": ["deploy"], "diplomacy": ["deploy", "patrol", "search"], "interrogate": ["search", "assault"]},
		"ins": {"smuggle": ["recruit", "travel"], "infiltrate": [], "propagandize": []}},
	"malesia": {"brit": {"resettle": ["train"], "reprisal": ["garrison", "sweep", "assault"], "airstrike": []},
		"ins": {"extort": ["rally", "march", "terror"], "intimidate": ["rally", "terror"], "ambush": ["attack"]}},
	"kenya": {"brit": {"reward": ["deploy", "relocate"], "reprisal": ["sweep", "assault"], "airstrike": []},
		"ins": {"supply": [], "oath": [], "raid": []}},
}
const NOMI_OP := {
	"deploy": "Schieramento", "patrol": "Pattuglia", "search": "Perquisizione", "assault": "Assalto",
	"recruit": "Reclutamento", "travel": "Spostamento", "sabotage": "Sabotaggio", "rob": "Rapina", "ambush": "Imboscata",
	"train": "Addestramento", "garrison": "Presidio", "sweep": "Rastrellamento", "rally": "Raduno", "march": "Marcia",
	"attack": "Attacco", "terror": "Terrore", "relocate": "Trasferimento",
	"restore": "Ripristino", "negotiate": "Negoziato", "detention": "Detenzione di massa", "silence": "Silenziare",
	"propagandize": "Propaganda", "diplomacy": "Diplomazia", "interrogate": "Interrogatorio", "smuggle": "Contrabbando",
	"infiltrate": "Infiltrazione", "resettle": "Reinsediamento", "reprisal": "Rappresaglia", "airstrike": "Attacco aereo",
	"extort": "Estorsione", "intimidate": "Intimidazione", "reward": "Ricompensa", "supply": "Rifornimento",
	"oath": "Giuramento", "raid": "Incursione",
}
const DESC_OP := {
	"palestina": {
		"deploy": "1 Polizia in Distretti/Città con più Truppe che Irgun; poi Truppe da ovunque verso 1 spazio.",
		"patrol": "Sposta Polizia verso spazi con Cellule; in 1 spazio manda in Prigione 1 Cellula attiva per Polizia.",
		"search": "Truppe adiacenti entrano; attiva Cellule (1 ogni 2 cubi; nelle Città Coprifuoco e 1 ogni 3).",
		"assault": "Rimuove 1 pezzo Irgun attivo ogni 2 Truppe; Depositi solo senza Cellule (+1 VP, +1 Intel).",
		"recruit": "Fino a 2 Cellule dove c'è un Deposito vicino; 1 nelle Città senza; mai con Coprifuoco.",
		"travel": "Sposta le Cellule di 1-3 spazi d'origine ovunque e le rende clandestine.",
		"sabotage": "Attiva 1 Cellula clandestina e tira: oltre 2 (−1 per Polizia, +2 col Deposito) piazza Sabotaggio.",
		"rob": "Dove le Cellule superano la Polizia: con più di 2 al dado piazza un Deposito d'armi.",
	},
	"cipro": {
		"deploy": "1 Polizia in Città/Basi con più Truppe che EOKA; poi Truppe da ovunque verso 1 spazio.",
		"patrol": "Sposta Polizia verso spazi (non Monti) con Cellule; in 1 spazio manda in Prigione 1 Cellula attiva per Polizia.",
		"search": "Truppe adiacenti entrano; attiva Cellule (1 per cubo; nelle Città Coprifuoco e 1 ogni 3).",
		"assault": "Rimuove 1 pezzo EOKA attivo per Truppa (ogni 2 nei Monti); Depositi solo senza Cellule.",
		"recruit": "1 Cellula in Città/Monti senza Coprifuoco con o vicino a un Deposito (2 nei Monti col Deposito).",
		"travel": "Sposta le Cellule di 1-3 spazi d'origine ovunque e le rende clandestine.",
		"sabotage": "In Città/Basi: attiva 1 Cellula clandestina e tira: oltre 2 (−1 per Polizia, +2 col Deposito) piazza Sabotaggio.",
		"ambush": "In Città: attiva 1 Cellula, rimuovi 1 Polizia; se il dado supera i cubi rimasti piazza un Deposito.",
	},
	"malesia": {
		"train": "2 Risorse/spazio: fino a 4 cubi a Kuala Lumpur, 2 Polizia nelle Province; poi Pacificazione in 1 spazio.",
		"garrison": "2 Risorse: cubi verso i Centri economici, Kuala Lumpur e 1 Provincia; attiva Guerriglie nei CE.",
		"sweep": "2 Risorse/spazio: Truppe adiacenti entrano; attiva 1 Guerriglia per cubo (Giungla: 1 ogni 2).",
		"assault": "2 Risorse/spazio: rimuove 1 pezzo attivo per Truppa (Montagna: ogni 2; KL/CE: per cubo).",
		"rally": "1 Risorsa/spazio: 1 Guerriglia o 2 Guerriglie diventano Base; con Base più Guerriglie o tutte clandestine.",
		"march": "1 Risorsa/destinazione: Guerriglie dagli spazi adiacenti.",
		"attack": "1 Risorsa/spazio: attiva tutte le Guerriglie; dado ≤ Guerriglie: rimuovi fino a 2 cubi.",
		"terror": "1 Risorsa/spazio: attiva 1 Guerriglia, Terrore (Sabotaggio nei CE), sposta verso l'Opposizione.",
	},
	"kenya": {
		"deploy": "Fino a 4 cubi a Nairobi, 2 Polizia nelle Province controllate; poi Truppe verso 1 spazio non di giungla.",
		"relocate": "Province di Riserva controllate: −1 Popolazione, 1 Polizia rientra in gioco; tiro per l'Indignazione.",
		"sweep": "Truppe adiacenti entrano; attiva 1 Guerriglia per cubo (Giungla di montagna: 1 ogni 2).",
		"assault": "Rimuove 1 pezzo attivo per Truppa (Giungla: ogni 2; Nairobi: per cubo); +1 VP per Base.",
		"rally": "1 Risorsa/spazio: 1 Guerriglia o 2 diventano Base; con Base più Guerriglie o tutte clandestine.",
		"march": "1 Risorsa/destinazione: Guerriglie dagli spazi adiacenti.",
		"terror": "1 Risorsa/spazio: attiva 1 Guerriglia e Terrore + verso la Resistenza, oppure rimuovi fino a 2 Polizia.",
	},
}


const DESC_SA := {
	"restore": "Con lo Schieramento: in 1 spazio con Truppe, Polizia e niente insorti toglie Coprifuoco e Sabotaggi.",
	"negotiate": "Dado (+1 per Terrore): se supera l'Haganah, la sposta a sinistra; a 0 dà 1 Intel.",
	"detention": "In 1 Città con Coprifuoco e 3 Truppe: un dado di Cellule in Prigione (Città e Distretto); l'eccesso costa VP.",
	"silence": "In 1 spazio con almeno tante Cellule clandestine quanta Polizia: rimuove 1 Polizia.",
	"propagandize": "Palestina: fino a 2 Città con Cellula e Coprifuoco, −1 VP ciascuna. Cipro: 1 spazio con Cellula e Sabotaggio (−1 VP) o Coprifuoco (Opinione +2).",
	"terror": "In 1 Città del Sabotaggio: Terrore invece di Sabotaggio; con 6 o più, 2 Terrori e l'Haganah scende.",
	"diplomacy": "Opinione internazionale −1 (se più di 3 Città hanno Sabotaggi o Coprifuochi serve un dado maggiore dell'Opinione).",
	"interrogate": "1 Intel ogni 2 Cellule in Prigione.",
	"smuggle": "Piazza un Deposito dove c'è una Cellula e niente cubi, o spostalo tra spazi adiacenti con Cellule (non a Opinione 0; 2 a Opinione 4).",
	"infiltrate": "In 1 spazio con Polizia e almeno altrettante Cellule clandestine: sostituisce 1 Polizia con 1 Cellula e scarta l'Intel più alto.",
	"resettle": "Con l'Addestramento: Nuovo Villaggio in 1 Provincia a Controllo britannico, che si sposta verso l'Opposizione.",
	"reprisal": "Spazio con Truppe a Neutrale, Terrore, 1 Guerriglia spostata in uno spazio adiacente.",
	"airstrike": "Rimuove Guerriglie attive (Malesia: 1 in fino a 2 Province con forze britanniche; Kenya: 1, o 2 in una Giungla).",
	"extort": "Fino a 2 spazi con Guerriglia clandestina e senza Nuovo Villaggio: attiva 1 Guerriglia, +1 Risorsa.",
	"intimidate": "Fino a 2 spazi con Guerriglia clandestina: rimuove 1 Polizia, o il Nuovo Villaggio e il Supporto.",
	"ambush": "In 1 spazio dell'Attacco: successo sicuro, attiva 1 sola Guerriglia, rimuove 1 cubo.",
	"reward": "1 spazio popolato a Controllo britannico: toglie 1 Terrore e sposta verso la Lealtà.",
	"supply": "+1 Risorsa per Base a Nairobi o collegata a Nairobi da spazi con Guerriglie o Resistenza.",
	"oath": "1 Provincia di Riserva popolata con Guerriglia clandestina: +1 Guerriglia e verso la Resistenza.",
	"raid": "Provincia vicina a una Giungla: entra con 1-2 Guerriglie e fai un'Operazione Limitata gratuita, o ritirati nella giungla.",
}


func descrizione(id: String) -> String:
	if DESC_OP.get(gioco(), {}).has(id):
		return DESC_OP[gioco()][id]
	return DESC_SA.get(id, "")


func nome_op(id: String) -> String:
	return NOMI_OP.get(id, id)


# ================================================================ operazione con attività speciale

func operazione(f: String, limitata: bool, con_sa: bool) -> void:
	var ops: Array = []
	for id in OPS[gioco()][f]:
		if op_possibile(f, id, limitata):
			ops.append(o(id, nome_op(id)))
	if ops.is_empty():
		nota("Nessuna operazione possibile.")
		return
	var op = chiedi(f, "Scegli l'Operazione" + (" Limitata" if limitata else ""), ops, {"tag": "op", "mostra": true})
	if ferma():
		return
	var p := {"limitata": limitata, "max": max_spazi(f, limitata), "op": op}
	if con_sa:
		var sas: Array = []
		for id in SAS[gioco()][f]:
			var acc: Array = SAS[gioco()][f][id]
			if (acc.is_empty() or op in acc) and sa_possibile(f, id, op):
				sas.append(o(id, nome_op(id)))
		sas.append(o("nessuna", "Nessuna Attività Speciale"))
		var sa = chiedi(f, "Attività Speciale che accompagna %s" % nome_op(op), sas, {"tag": "sa", "mostra": true})
		if ferma():
			return
		if sa in ["terror", "ambush"] and (gioco() == "palestina" and sa == "terror" or gioco() == "malesia" and sa == "ambush"):
			p[sa] = true
			nota("%s: %s con %s" % [nome_faz(f), nome_op(op), nome_op(sa)])
			call("op_" + op, f, p)
			return
		if sa != "nessuna":
			var quando = chiedi(f, "Quando esegui %s?" % nome_op(sa), [o("prima", "Prima dell'Operazione"), o("dopo", "Dopo l'Operazione")], {"tag": "quando"})
			if ferma():
				return
			nota("%s: %s con %s" % [nome_faz(f), nome_op(op), nome_op(sa)])
			if quando == "prima":
				call("sa_" + sa, f, {"op": op})
				if ferma():
					return
				call("op_" + op, f, p)
			else:
				call("op_" + op, f, p)
				if ferma():
					return
				p["op"] = op
				call("sa_" + sa, f, p)
			return
	nota("%s: %s%s" % [nome_faz(f), nome_op(op), " limitata" if limitata else ""])
	call("op_" + op, f, p)


func max_spazi(f: String, limitata: bool) -> int:
	if limitata:
		var n := 1
		if gioco() == "palestina" and f == "ins" and haganah_extra():
			n += 1
		return n
	if cellule():
		var n := 3
		if f == "brit" and cap("P9") == "s":
			n = 2
		if f == "brit" and s["tmp"].get("loans", false):
			n = 4
		if f == "brit" and (s.get("camp", {}) as Dictionary).get("attivi", {}).has("E7"):
			n = min(n, 2)
		if gioco() == "palestina" and f == "ins" and haganah_extra():
			n += 1
		return n
	return 99


func haganah_extra() -> bool:
	var h := int(s["haganah"])
	if h == 4 and cap("P13") != "u":
		return true
	if h == 3 and cap("P13") == "s":
		return true
	return false


## Può essere eseguita in almeno uno spazio?
func op_possibile(f: String, id: String, _limitata: bool) -> bool:
	match id:
		"deploy", "patrol", "search", "travel", "train", "garrison", "sweep", "march":
			if id == "travel":
				return ordine.any(func(x): return gue(x) > 0)
			if id == "patrol":
				return ordine.any(func(x): return gue(x) > 0) and (disp("p") > 0 or ordine.any(func(x): return int(X(x)["p"]) > 0))
			if gioco() == "malesia":
				return int(s["ris"]["brit"]) >= 2
			if id == "march":
				return int(s["ris"]["ins"]) >= 1 and ordine.any(func(x): return gue(x) > 0)
			return true
		"assault":
			return ordine.any(func(x): return int(X(x)["t"]) > 0 and ins_n(x) > 0) and (gioco() != "malesia" or int(s["ris"]["brit"]) >= 2)
		"relocate":
			return limite_pipeline("relocate") > 0 and ordine.any(func(x): return _relocate_ok(x))
		"recruit":
			return ordine.any(func(x): return _recruit_max(x) > 0)
		"sabotage":
			return ordine.any(func(x): return _sabotage_ok(x))
		"rob":
			return ordine.any(func(x): return _rob_ok(x))
		"ambush":
			return ordine.any(func(x): return tipo(x) == "citta" and int(X(x)["u"]) > 0)
		"rally":
			return int(s["ris"]["ins"]) >= 1 and ordine.any(func(x): return _rally_ok(x))
		"attack":
			return int(s["ris"]["ins"]) >= 1 and ordine.any(func(x): return gue(x) > 0 and cubi(x) > 0)
		"terror":
			return int(s["ris"]["ins"]) >= 1 and ordine.any(func(x): return int(X(x)["u"]) > 0)
	return true


# ---------------------------------------------------------------- ciclo sugli spazi

## Sceglie ed esegue gli spazi uno alla volta. extra: "intel" o "deposito" se si può aggiungere uno spazio.
func ciclo(f: String, p: Dictionary, testo: String, filtro: Callable, esegui_sp: Callable, extra: String = "") -> Array:
	var fatti: Array = []
	var limite: int = int(p.get("max", 3))
	while true:
		var cand = func(id): return not (id in fatti) and filtro.call(id)
		if not ordine.any(cand):
			break
		if fatti.size() >= limite:
			if extra != "" and not p.get("extra_fatto", false) and _extra_possibile(f, extra):
				var lab = "Spendi un Intel per uno spazio in più" if extra == "intel" else "Togli un Deposito d'armi per uno spazio in più (Offensiva)"
				var v = chiedi(f, "Hai raggiunto il limite di spazi.", [o("extra", lab), o("fine", "Basta così")], {"tag": "extra"})
				if ferma() or v != "extra":
					break
				_paga_extra(f, extra)
				if ferma():
					break
				p["extra_fatto"] = true
				limite += 1
				continue
			break
		var sp = scegli_spazio(f, testo + (" (%d/%d)" % [fatti.size() + 1, limite] if limite < 50 else ""), cand, true, "spazio_" + str(p.get("op", "")))
		if ferma() or sp == null:
			break
		fatti.append(sp)
		esegui_sp.call(sp)
		if ferma():
			break
	return fatti


func _extra_possibile(f: String, extra: String) -> bool:
	if extra == "intel":
		return f == "brit" and not (s["intel"] as Array).is_empty() and cap("P6_no_intel") == ""
	return f == "ins" and ordine.any(func(id): return int(X(id)["b"]) > 0 and cubi(id) == 0)


func _paga_extra(f: String, extra: String) -> void:
	if extra == "intel":
		var v = chiedi(f, "Quale Intel scarti?", _opz_intel(), {"tag": "intel_extra"})
		if ferma():
			return
		scarta_intel(int(v))
		nota("Pista d'intelligence: un Intel torna nel sacchetto, uno spazio in più.")
	else:
		var sp = scegli_spazio(f, "Da dove togli il Deposito d'armi?", func(id): return int(X(id)["b"]) > 0 and cubi(id) == 0, false, "offensiva")
		if ferma() or sp == null:
			return
		rimuovi(sp, "b", 1)
		nota("Offensiva: un Deposito d'armi in %s torna disponibile, uno spazio in più." % nome_sp(sp))


func _opz_intel() -> Array:
	var r: Array = []
	var visti := {}
	for v in s["intel"]:
		if not visti.has(v):
			visti[v] = true
			r.append(o(v, "Intel di valore %d" % v))
	return r


## Sposta pezzi k verso dest da spazi che soddisfano origine (una domanda per spazio d'origine).
func raccogli(f: String, dest: String, k: String, origine: Callable, testo: String = "", tag: String = "muovi") -> int:
	var tot := 0
	var fonti: Array = []
	for id in ordine:
		if id != dest and int(X(id)[k]) > 0 and origine.call(id):
			fonti.append(id)
	if fonti.size() >= 2:
		var opz: Array = [o("si", "Scegli spazio per spazio (%d spazi)" % fonti.size()), o("no", "Nessuno")]
		var v = chiedi(f, "%s: vuoi spostare %s verso %s?" % [testo, nome_pezzo(k, 2) if k != "p" else "Polizia", nome_sp(dest)], opz, {"tag": tag + "_si", "a": dest})
		if ferma() or v == "no":
			return 0
	for j in fonti.size():
		var id: String = fonti[j]
		if int(X(id)[k]) <= 0:
			continue
		var dom: String = "%s: quante %s da %s a %s?" % [testo, nome_pezzo(k, 2), nome_sp(id), nome_sp(dest)] if k != "p" else "%s: quanta Polizia da %s a %s?" % [testo, nome_sp(id), nome_sp(dest)]
		var n: int = numero(f, dom, 0, int(X(id)[k]), tag, {"da": id, "a": dest, "basta": j < fonti.size() - 1})
		if ferma():
			return tot
		if n < 0:
			break
		if n > 0:
			muovi(id, dest, k, n)
			tot += n
	if tot > 0:
		nota("%s in %s." % [pz(tot, k), nome_sp(dest)])
	return tot


## Spende Intel per rimuovere n Cellule clandestine: sceglie la combinazione di valore minimo ≥ n.
func spendi_intel_per(n: int) -> bool:
	if n <= 0:
		return true
	var a: Array = s["intel"]
	var best: Array = []
	var best_sum := 999
	for mask in range(1, 1 << a.size()):
		var tot := 0
		var sel: Array = []
		for i in a.size():
			if mask & (1 << i):
				tot += int(a[i])
				sel.append(a[i])
		if tot >= n and (tot < best_sum or (tot == best_sum and sel.size() < best.size())):
			best_sum = tot
			best = sel
	if best.is_empty():
		return false
	for v in best:
		scarta_intel(int(v))
	nota("Spesi Intel per un valore di %d." % best_sum)
	return true


## Quante clandestine si possono pagare con gli Intel attuali (somma totale, limitata).
func intel_massimo() -> int:
	return intel_tot()


# ================================================================ BRITANNICI — giochi a Cellule

func op_deploy(f: String, p: Dictionary) -> void:
	if gioco() == "kenya":
		_deploy_kenya(f, p)
		return
	var filtro := func(id):
		var t := tipo(id)
		var ok = (t in ["distretto", "citta"]) if gioco() == "palestina" else (t in ["citta", "base"])
		return ok and int(X(id)["t"]) > ins_n(id) and p.get("filtro", func(_x): return true).call(id)
	ciclo(f, p, "Schieramento: scegli dove piazzare 1 Polizia", filtro, func(id):
		if piazza(id, "p", 1) > 0:
			nota("1 Polizia in %s." % nome_sp(id))
	)
	if ferma():
		return
	var dest = scegli_spazio(f, "Schieramento: verso quale spazio sposti Truppe?", func(_id): return true, true, "deploy_dest", "Non spostare Truppe")
	if ferma() or dest == null:
		return
	raccogli(f, dest, "t", func(_id): return true, "Schieramento")


func op_patrol(f: String, p: Dictionary) -> void:
	var filtro = func(id): return gue(id) > 0 and (gioco() != "cipro" or tipo(id) != "montagna")
	var dests := ciclo(f, p, "Pattuglia: scegli uno spazio di destinazione con Cellule", filtro, func(id):
		var prima := int(X(id)["p"])
		raccogli(f, id, "p", func(_x): return true, "Pattuglia", "patrol_muovi")
		if cap("P23") == "s" and int(X(id)["sab"]) > 0 and int(X(id)["p"]) > prima:
			var d := dado()
			if d <= 3:
				rimuovi(id, "p", 1)
				nota("Mine stradali: 1 Polizia rimossa in %s (dado %d)." % [nome_sp(id), d])
	, "intel")
	if ferma():
		return
	var quante = 2 if cap("P23") == "u" else 1
	var fatti: Array = []
	for k in quante:
		var sp = scegli_spazio(f, "Pattuglia: in quale spazio rimuovi Cellule?", func(id): return id in dests and not (id in fatti) and int(X(id)["p"]) > 0 and gue(id) > 0, true, "patrol_arresto", "Nessun arresto")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		var cap_n := int(X(sp)["p"])
		if cap("C17") == "s":
			cap_n = cap_n / 2
		_arresta(f, sp, cap_n, "prigione", false)
		if ferma():
			return


## Rimuove fino a cap_n Cellule (attive, più clandestine pagando Intel). alterna: alternanza Disponibili/Prigione.
func _arresta(f: String, sp: String, cap_n: int, dest: String, alterna: bool) -> int:
	if cap_n <= 0:
		return 0
	var maxu: int = min(min(int(X(sp)["u"]), cap_n), intel_tot())
	var nu := 0
	if maxu > 0:
		nu = numero(f, "Quante Cellule clandestine rimuovi in %s spendendo Intel (hai %d punti)?" % [nome_sp(sp), intel_tot()], 0, maxu, "intel_u")
		if ferma():
			return 0
		if not spendi_intel_per(nu):
			nu = 0
	var na: int = min(int(X(sp)["a"]), cap_n - nu)
	var tot := 0
	var turno_disp := true
	for i in na + nu:
		var k = "a" if i < na else "u"
		var d := dest
		if alterna:
			d = "disp" if turno_disp else "prigione"
			turno_disp = not turno_disp
		rimuovi(sp, k, 1, d)
		tot += 1
	if tot > 0:
		nota("%s rimoss%s da %s." % [pz(tot, "g"), "a" if tot == 1 else "e", nome_sp(sp)])
	return tot


func op_search(f: String, p: Dictionary) -> void:
	if not cellule():
		_sweep(f, p)
		return
	var no_intel: bool = p.get("no_intel", false)
	ciclo(f, p, "Perquisizione: scegli uno spazio di destinazione", func(id): return p.get("filtro", func(_x): return true).call(id), func(id):
		raccogli(f, id, "t", func(x): return id in SP[x]["adj"], "Perquisizione", "search_muovi")
		if ferma():
			return
		_search_effetto(f, id, no_intel)
	, "" if no_intel else "intel")


func _search_effetto(f: String, id: String, no_intel: bool) -> void:
	var c := cubi(id)
	var t := tipo(id)
	var n := 0
	if t == "citta":
		var usa := false
		if not no_intel and not (s["intel"] as Array).is_empty() and gue(id) > 0:
			var v = chiedi(f, "Perquisizione in %s: Coprifuoco o Intel?" % nome_sp(id), [o("cf", "Piazza Coprifuoco (1 Cellula ogni %d cubi)" % (4 if cap("P17") == "s" else 3)), o("intel", "Scarta 1 Intel (1 Cellula per cubo, niente Coprifuoco)")], {"tag": "search_citta"})
			if ferma():
				return
			usa = v == "intel"
		if usa:
			var iv = chiedi(f, "Quale Intel scarti?", _opz_intel(), {"tag": "intel_scarta"})
			if ferma():
				return
			scarta_intel(int(iv))
			n = c
		else:
			_piazza_coprifuoco(f, id)
			n = c / (4 if cap("P17") == "s" else 3)
	elif gioco() == "palestina":
		n = c / 2
	else:
		n = c
	var m := attiva(id, n)
	if m > 0:
		nota("%s attivat%s in %s." % [pz(m, "g"), "a" if m == 1 else "e", nome_sp(id)])


func coprifuochi_mappa() -> int:
	var t := 0
	for id in ordine:
		t += int(X(id)["cf"])
	return t


func _piazza_coprifuoco(f: String, id: String) -> void:
	if int(X(id)["cf"]) > 0:
		return
	if coprifuochi_mappa() >= int(s["coprifuoco_tot"]):
		if gioco() != "cipro":
			return
		var da = scegli_spazio(f, "Nessun Coprifuoco disponibile: da dove lo togli?", func(x): return int(X(x)["cf"]) > 0, false, "coprifuoco_da")
		if ferma() or da == null:
			return
		X(da)["cf"] = 0
	X(id)["cf"] = 1
	nota("Coprifuoco a %s." % nome_sp(id))


func op_assault(f: String, p: Dictionary) -> void:
	var paga = gioco() == "malesia" and not p.get("gratis", false)
	var filtro = func(id): return int(X(id)["t"]) > 0 and ins_n(id) > 0 and (not paga or int(s["ris"]["brit"]) >= 2) and p.get("filtro", func(_x): return true).call(id)
	ciclo(f, p, "Assalto: scegli uno spazio", filtro, func(id):
		if paga:
			cambia_ris("brit", -2)
		assalto_in(f, id, p)
	, "intel" if cellule() else "")


func assalto_cap(id: String) -> int:
	var t := int(X(id)["t"])
	var ty := tipo(id)
	match gioco():
		"palestina":
			return t if cap("P18") == "u" else t / 2
		"cipro":
			return t / 2 if ty == "montagna" else t
		"malesia":
			if ty in ["kl", "ec"]:
				return cubi(id)
			return t / 2 if ty == "prov_m" else t
		"kenya":
			if ty == "nairobi":
				return cubi(id)
			return t / 2 if ty == "giungla" else t
	return t


func assalto_in(f: String, id: String, p: Dictionary = {}) -> void:
	var capn := assalto_cap(id)
	var tolti := 0
	if cellule():
		var dest = "disp" if cap("P18") == "s" else ""
		tolti = _arresta(f, id, capn, dest if dest != "" else "disp", dest == "")
		if ferma():
			return
	else:
		if gioco() == "malesia" and cap("M2") == "u" and not s["tmp"].get("minyuen_usato", false) and int(X(id)["b"]) > 0:
			if si_no(f, "Min Yuen: rimuovere prima le Basi in %s?" % nome_sp(id), "minyuen"):
				s["tmp"]["minyuen_usato"] = true
				while tolti < capn and int(X(id)["b"]) > 0:
					rimuovi(id, "b", 1)
					tolti += 1
					cambia_pw(1, "Base rimossa")
			if ferma():
				return
		var n: int = min(int(X(id)["a"]), capn - tolti)
		rimuovi(id, "a", n)
		tolti += n
		if n > 0:
			nota("%s rimoss%s da %s." % [pz(n, "g"), "a" if n == 1 else "e", nome_sp(id)])
	while tolti < capn and gue(id) == 0 and int(X(id)["b"]) > 0:
		rimuovi(id, "b", 1)
		tolti += 1
		nota("%s %s da %s." % [nome_pezzo("b"), "rimosso" if cellule() else "rimossa", nome_sp(id)])
		if cellule():
			var doppio = gioco() == "palestina" and cap("P25") == "u"
			cambia_pw(2 if doppio else 1, "Deposito d'armi rimosso")
			pesca_intel(2 if doppio else 1)
		else:
			cambia_pw(1, "Base rimossa")


# ================================================================ INSORTI — giochi a Cellule

func _vicino_deposito(id: String) -> bool:
	if int(X(id)["b"]) > 0:
		return true
	for a in SP[id]["adj"]:
		if int(X(a)["b"]) > 0:
			return true
	return false


func _recruit_max(id: String) -> int:
	var x = X(id)
	if int(x["cf"]) > 0:
		return 0
	if gioco() == "palestina":
		if _vicino_deposito(id):
			return 2
		return 1 if tipo(id) == "citta" else 0
	if gioco() == "cipro":
		if not (tipo(id) in ["citta", "montagna"]) or not _vicino_deposito(id):
			return 0
		return 2 if tipo(id) == "montagna" and int(x["b"]) > 0 else 1
	return 0


func op_recruit(f: String, p: Dictionary) -> void:
	ciclo(f, p, "Reclutamento: scegli uno spazio", func(id): return _recruit_max(id) > 0 and disp("g") > 0, func(id):
		var mx: int = min(_recruit_max(id), disp("g"))
		var n := numero(f, "Quante Cellule piazzi in %s?" % nome_sp(id), 1, mx, "recruit_n")
		if ferma():
			return
		var k := piazza(id, "g", n)
		nota("%s in %s." % [pz(k, "g"), nome_sp(id)])
	, "deposito")


func op_travel(f: String, p: Dictionary) -> void:
	ciclo(f, p, "Spostamento: scegli uno spazio d'origine con Cellule", func(id): return gue(id) > 0 and p.get("filtro", func(_x): return true).call(id), func(orig):
		var tot := gue(orig)
		# tutte le Cellule dell'origine "si muovono" (anche verso l'origine stessa)
		var arrivi := {}
		var rimaste := tot
		while rimaste > 0:
			var dest = scegli_spazio(f, "Spostamento da %s: dove vanno altre Cellule? (%d da sistemare)" % [nome_sp(orig), rimaste], func(x): return x != orig, true, "travel_dest", "Le altre restano a %s" % nome_sp(orig))
			if ferma():
				return
			if dest == null:
				break
			var n = numero(f, "Quante Cellule da %s a %s?" % [nome_sp(orig), nome_sp(dest)], 1, rimaste, "travel_n")
			if ferma():
				return
			arrivi[dest] = int(arrivi.get(dest, 0)) + n
			rimaste -= n
		arrivi[orig] = int(arrivi.get(orig, 0)) + rimaste
		# togli tutte dall'origine e rimettile secondo gli arrivi
		var xo = X(orig)
		xo["u"] = 0
		xo["a"] = 0
		var singola_ok := cap("C18") == "s"
		for dest in arrivi:
			var n: int = arrivi[dest]
			if n <= 0:
				continue
			var att := false
			var t := tipo(dest)
			var speciale = (t == "ferrovia" or int(X(dest)["cf"]) > 0) if gioco() == "palestina" else (t == "base" or int(X(dest)["cf"]) > 0)
			if speciale and n + cubi(dest) > 3:
				att = true
			if gioco() == "cipro" and int(X(dest)["cf"]) > 0:
				if cap("C18") == "u":
					att = true
				elif singola_ok and n == 1:
					att = false
			X(dest)["a" if att else "u"] = int(X(dest)["a" if att else "u"]) + n
			_dopo(dest)
			if dest != orig:
				nota("%s da %s a %s%s." % [pz(n, "g"), nome_sp(orig), nome_sp(dest), " (attive)" if att else ""])
		_dopo(orig)
	)


func _sabotage_ok(id: String) -> bool:
	if int(X(id)["u"]) <= 0:
		return cap("C23") == "s" and not s["tmp"].get("riots_usato", false) and int(X(id)["a"]) > 0 and (gioco() != "cipro" or tipo(id) in ["citta", "base"])
	if gioco() == "cipro":
		return tipo(id) in ["citta", "base"]
	return true


func op_sabotage(f: String, p: Dictionary) -> void:
	ciclo(f, p, "Sabotaggio: scegli uno spazio", func(id): return _sabotage_ok(id) and p.get("filtro", func(_x): return true).call(id), func(id):
		sabotaggio_in(f, id, p)
	, "" if p.get("no_extra", false) else "deposito")


func sabotaggio_in(f: String, id: String, p: Dictionary = {}) -> bool:
	if gioco() == "cipro" and cap("C23") == "u" and cubi(id) > 0 and gue(id) > 1:
		rimuovi_g(id, 1)
		nota("Moti di piazza: 1 Cellula rimossa in %s." % nome_sp(id))
	if int(X(id)["u"]) > 0:
		attiva(id, 1)
	elif cap("C23") == "s" and int(X(id)["a"]) > 0:
		s["tmp"]["riots_usato"] = true
	else:
		return false
	var terr := false
	if p.get("terror", false) and not p.get("terror_usato", false) and tipo(id) == "citta":
		terr = si_no(f, "Terrore: trasformi il Sabotaggio a %s in Terrore?" % nome_sp(id), "terrore")
		if ferma():
			return false
		if terr:
			p["terror_usato"] = true
	var bonus := 0
	var dep = func(x): return int(X(x)["b"]) > 0 and (x == id or x in SP[id]["adj"])
	if ordine.any(dep):
		var sp = scegli_spazio(f, "Sabotaggio a %s: spendi un Deposito d'armi (+2 al dado)?" % nome_sp(id), dep, true, "sab_deposito", "No")
		if ferma():
			return false
		if sp != null:
			rimuovi(sp, "b", 1)
			bonus = 2
	var d := dado()
	var pol = 0 if cap("C31") != "" else int(X(id)["p"])
	var r = d + bonus - pol
	nota("Sabotaggio a %s: dado %d%s%s = %d." % [nome_sp(id), d, " +2" if bonus else "", (" −%d Polizia" % pol) if pol else "", r])
	if gioco() == "palestina" and cap("P32") == "u" and d == 1:
		rimuovi(id, "a", 1)
		nota("Detonazione accidentale: la Cellula è rimossa.")
	if r > 2:
		if terr:
			var due = r >= 6 and cap("P17") != "u"
			X(id)["ter"] = int(X(id)["ter"]) + (2 if due else 1)
			nota("Terrore a %s%s." % [nome_sp(id), " (2 segnalini)" if due else ""])
			if r >= 6:
				sposta_haganah(-1)
		else:
			X(id)["sab"] = int(X(id)["sab"]) + 1
			nota("Sabotaggio riuscito a %s." % nome_sp(id))
		return true
	nota("Sabotaggio fallito.")
	return false


func _rob_ok(id: String) -> bool:
	return tipo(id) in ["distretto", "citta"] and gue(id) > int(X(id)["p"])


func op_rob(f: String, p: Dictionary) -> void:
	ciclo(f, p, "Rapina: scegli uno spazio", func(id): return _rob_ok(id), func(id):
		var d := dado()
		if cap("P32") == "s" or d > 2:
			if piazza(id, "b", 1) > 0:
				nota("Rapina a %s riuscita (dado %d): nuovo Deposito d'armi." % [nome_sp(id), d])
			else:
				nota("Rapina a %s riuscita, ma nessun Deposito da piazzare." % nome_sp(id))
		else:
			nota("Rapina a %s fallita (dado %d)." % [nome_sp(id), d])
		if int(X(id)["p"]) > 0:
			attiva(id, 1)
	, "" if p.get("passaggio", false) else "deposito")


func op_ambush(f: String, p: Dictionary) -> void:
	ciclo(f, p, "Imboscata: scegli una Città", func(id): return tipo(id) == "citta" and int(X(id)["u"]) > 0, func(id):
		attiva(id, 1)
		var lorry := false
		if cap("C32") == "s" and int(X(id)["t"]) > 0 and not s["tmp"].get("lorries", false):
			lorry = si_no(f, "Camion attaccati: niente Polizia rimossa ma −1 VP se riesce?", "lorries")
			if ferma():
				return
			if lorry:
				s["tmp"]["lorries"] = true
		if not lorry:
			rimuovi(id, "p", 1)
		var d := dado()
		nota("Imboscata a %s: dado %d contro %d cubi." % [nome_sp(id), d, cubi(id)])
		if cap("C32") == "u" and int(X(id)["t"]) > 0:
			rimuovi(id, "a", 1)
		if d > cubi(id):
			if lorry:
				cambia_pw(-1, "camion attaccati")
			var dove = scegli_spazio(f, "Imboscata riuscita: dove piazzi il Deposito d'armi?", func(x): return (x == id or (x in SP[id]["adj"] and tipo(x) in ["citta", "montagna"])) and base_ok(x) and int(X(x)["b"]) < 2, true, "ambush_dep", "Nessun Deposito")
			if ferma():
				return
			if dove != null and piazza(dove, "b", 1) > 0:
				nota("Deposito d'armi a %s." % nome_sp(dove))
	, "" if p.get("passaggio", false) else "deposito")


# ================================================================ Attività speciali — Palestina e Cipro

func sa_possibile(f: String, id: String, op: String) -> bool:
	match id:
		"restore":
			return ordine.any(func(x): return _restore_ok(x))
		"negotiate", "diplomacy", "interrogate", "terror", "ambush", "supply", "airstrike":
			if id == "terror" and gioco() == "palestina" and int((s.get("camp", {}) as Dictionary).get("prewar", 0)) == 6 and int(s["haganah"]) >= 3:
				return false
			if id == "airstrike":
				return ordine.any(func(x): return _airstrike_ok(x))
			return true
		"detention":
			return ordine.any(func(x): return tipo(x) == "citta" and int(X(x)["cf"]) > 0 and int(X(x)["t"]) >= 3)
		"silence":
			return ordine.any(func(x): return int(X(x)["p"]) > 0 and int(X(x)["u"]) >= int(X(x)["p"]))
		"propagandize":
			return ordine.any(func(x): return _propag_ok(x))
		"smuggle":
			return int(s["opinione"]) > 0
		"infiltrate":
			return ordine.any(func(x): return _infiltrate_ok(x))
		"resettle":
			return disponibili_nv() > 0
		"reprisal":
			return limite_reprisal() > 0
		"extort":
			return ordine.any(func(x): return int(X(x)["u"]) > 0 and int(X(x)["nv"]) == 0)
		"intimidate":
			return ordine.any(func(x): return int(X(x)["u"]) > 0)
		"reward":
			return true
		"oath":
			return ordine.any(func(x): return _oath_ok(x))
		"raid":
			return ordine.any(func(x): return _raid_ok(x))
	return true


func _restore_ok(id: String) -> bool:
	return int(X(id)["t"]) > 0 and int(X(id)["p"]) > 0 and ins_n(id) == 0


func sa_restore(f: String, p: Dictionary) -> void:
	var n: int = int(p.get("max", 1))
	for k in n:
		var sp = scegli_spazio(f, "Ripristino: scegli uno spazio con Truppe, Polizia e niente insorti", func(x): return _restore_ok(x) and (p.get("libero", false) or true), true, "restore")
		if ferma() or sp == null:
			return
		X(sp)["cf"] = 0
		X(sp)["sab"] = 0
		if gioco() == "palestina":
			X(sp)["sab"] = int(X(sp)["ter"])
			X(sp)["ter"] = 0
		nota("Ripristino a %s: tolti Coprifuoco e Sabotaggi." % nome_sp(sp))


func sa_negotiate(f: String, _p: Dictionary) -> void:
	var terr := 0
	for id in ordine:
		terr += int(X(id)["ter"])
	if int(s["haganah"]) == 0:
		pesca_intel(1)
		return
	var d := dado()
	nota("Negoziato: dado %d +%d Terrore contro Haganah %d." % [d, terr, int(s["haganah"])])
	if d + terr > int(s["haganah"]):
		sposta_haganah(-1)
		if int(s["haganah"]) == 0:
			pass


func sa_detention(f: String, _p: Dictionary) -> void:
	var sp = scegli_spazio(f, "Detenzione di massa: scegli una Città con Coprifuoco e almeno 3 Truppe", func(x): return tipo(x) == "citta" and int(X(x)["cf"]) > 0 and int(X(x)["t"]) >= 3, false, "detention")
	if ferma() or sp == null:
		return
	detenzione_in(sp)


func detenzione_in(sp: String) -> void:
	var d := dado()
	var dest = "disp" if cap("P18") == "s" else "prigione"
	var tolte := 0
	var distr := ""
	for a in SP[sp]["adj"]:
		if tipo(a) == "distretto":
			distr = a
	for id in [sp, distr]:
		if id == "":
			continue
		var n: int = min(d - tolte, gue(id))
		tolte += rimuovi_g(id, n, dest)
	nota("Detenzione di massa a %s: dado %d, %s arrestate." % [nome_sp(sp), d, pz(tolte, "g")])
	if d > tolte:
		cambia_pw(-(d - tolte), "detenzione di massa")


func sa_silence(f: String, _p: Dictionary) -> void:
	var sp = scegli_spazio(f, "Silenziare: scegli uno spazio con almeno tante Cellule clandestine quanta Polizia", func(x): return int(X(x)["p"]) > 0 and int(X(x)["u"]) >= int(X(x)["p"]), false, "silence")
	if ferma() or sp == null:
		return
	rimuovi(sp, "p", 1)
	nota("1 Polizia eliminata a %s." % nome_sp(sp))


func _propag_ok(id: String) -> bool:
	if gue(id) == 0:
		return false
	if gioco() == "palestina":
		return tipo(id) == "citta" and int(X(id)["cf"]) > 0
	return int(X(id)["sab"]) > 0 or int(X(id)["cf"]) > 0


func sa_propagandize(f: String, p: Dictionary) -> void:
	var n = 2 if gioco() == "palestina" or cap("C13") == "s" else 1
	n = int(p.get("max", n))
	var senza_cellula: bool = p.get("senza_cellula", false)
	var fatti: Array = []
	for k in n:
		var sp = scegli_spazio(f, "Propaganda: scegli uno spazio", func(x): return not (x in fatti) and (_propag_ok(x) or (senza_cellula and int(X(x)["cf"]) > 0)) and p.get("filtro", func(_y): return true).call(x), k > 0, "propag")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		if int(X(sp)["a"]) == 0 and int(X(sp)["u"]) > 0:
			attiva(sp, 1)
		if gioco() == "palestina":
			var e9: bool = (s.get("camp", {}) as Dictionary).get("attivi", {}).has("E9")
			cambia_pw(-2 if cap("P25") == "s" or e9 else -1, "Propaganda a " + nome_sp(sp))
		else:
			var scelta = "sab" if int(X(sp)["sab"]) > 0 else "cf"
			if int(X(sp)["sab"]) > 0 and int(X(sp)["cf"]) > 0:
				scelta = chiedi(f, "Propaganda a %s: cosa ottieni?" % nome_sp(sp), [o("sab", "−1 Volontà Politica"), o("cf", "Opinione internazionale +%d" % (1 if cap("C13") == "u" else 2))], {"tag": "propag_scelta"})
				if ferma():
					return
			if scelta == "sab":
				cambia_pw(-1, "Propaganda a " + nome_sp(sp))
			else:
				sposta_opinione(1 if cap("C13") == "u" else 2)


func sa_diplomacy(_f: String, _p: Dictionary) -> void:
	var n := 0
	for id in ordine:
		if tipo(id) == "citta" and (int(X(id)["sab"]) > 0 or int(X(id)["cf"]) > 0):
			n += 1
	if n <= 3:
		sposta_opinione(-1)
	else:
		var d := dado()
		nota("Diplomazia: dado %d contro Opinione %d." % [d, int(s["opinione"])])
		if d > int(s["opinione"]):
			sposta_opinione(-1)


func sa_interrogate(f: String, _p: Dictionary) -> void:
	var n := int(s["prigione"]) if cap("C10") == "u" else int(s["prigione"]) / 2
	if cap("C17") == "u":
		var alt := 0
		for id in ordine:
			if int(X(id)["p"]) > 0 and gue(id) > 0:
				alt += 1
		if alt > n:
			n = alt
	nota("Interrogatorio: %d Intel." % n)
	pesca_intel(n)
	if cap("C10") == "s":
		cambia_pw(-1, "accuse di tortura")


func sa_smuggle(f: String, _p: Dictionary) -> void:
	var n = 2 if int(s["opinione"]) >= 4 else 1
	for k in n:
		var modi: Array = []
		var dove_piazza = func(x): return (tipo(x) in ["citta", "montagna"]) and int(X(x)["b"]) < 2 and (cap("C9") == "s" or (gue(x) > 0 and cubi(x) == 0))
		if disp("b") > 0 and ordine.any(dove_piazza):
			modi.append(o("piazza", "Piazza un Deposito d'armi"))
		var da_muovere = func(x): return int(X(x)["b"]) > 0 and gue(x) > 0 and SP[x]["adj"].any(func(a): return tipo(a) in ["citta", "montagna"] and gue(a) > 0 and int(X(a)["b"]) < 2)
		if ordine.any(da_muovere):
			modi.append(o("muovi", "Sposta un Deposito d'armi"))
		if modi.is_empty():
			return
		modi.append(o("fine", "Basta così"))
		var m = chiedi(f, "Contrabbando:", modi, {"tag": "smuggle"})
		if ferma() or m == "fine":
			return
		if m == "piazza":
			var sp = scegli_spazio(f, "Contrabbando: dove piazzi il Deposito?", dove_piazza, false, "smuggle_dove")
			if ferma() or sp == null:
				return
			if cap("C9") == "u":
				var d := dado()
				if d <= 3:
					nota("Blocco navale: contrabbando intercettato (dado %d)." % d)
					continue
			piazza(sp, "b", 1)
			nota("Deposito d'armi contrabbandato a %s." % nome_sp(sp))
		else:
			var da = scegli_spazio(f, "Da dove sposti il Deposito?", da_muovere, false, "smuggle_da")
			if ferma() or da == null:
				return
			var a = scegli_spazio(f, "Verso dove?", func(x): return x in SP[da]["adj"] and tipo(x) in ["citta", "montagna"] and gue(x) > 0 and int(X(x)["b"]) < 2, false, "smuggle_a")
			if ferma() or a == null:
				return
			muovi(da, a, "b", 1)
			nota("Deposito d'armi da %s a %s." % [nome_sp(da), nome_sp(a)])


func _infiltrate_ok(id: String) -> bool:
	var p := int(X(id)["p"])
	if p > 0 and int(X(id)["u"]) >= p:
		return true
	return cap("C25") == "s" and p > 0 and int(X(id)["u"]) > 0


func sa_infiltrate(f: String, _p: Dictionary) -> void:
	var sp = scegli_spazio(f, "Infiltrazione: scegli uno spazio", func(x): return _infiltrate_ok(x), false, "infiltrate")
	if ferma() or sp == null:
		return
	var sostituisci := cap("C31") == ""
	var scarta := cap("C31") == ""
	if cap("C25") == "u":
		var v = chiedi(f, "Infiltrazione: sostituisci la Polizia o scarti un Intel?", [o("sost", "Sostituisci 1 Polizia con 1 Cellula"), o("intel", "Scarta l'Intel più alto")], {"tag": "infiltr"})
		if ferma():
			return
		sostituisci = sostituisci and v == "sost"
		scarta = v == "intel"
		if v == "sost" and cap("C31") != "":
			rimuovi(sp, "p", 1)
	if cap("C25") != "u" or sostituisci:
		rimuovi(sp, "p", 1)
		if sostituisci:
			piazza(sp, "g", 1)
	nota("Infiltrazione a %s." % nome_sp(sp))
	if scarta and not (s["intel"] as Array).is_empty():
		var mx := 0
		for v in s["intel"]:
			mx = max(mx, int(v))
		scarta_intel(mx)
		nota("Scartato un Intel di valore %d." % mx)


func sposta_haganah(d: int) -> void:
	var v: int = clamp(int(s["haganah"]) + d, 0, 4)
	var vecchio := int(s["haganah"])
	if v == vecchio:
		return
	s["haganah"] = v
	nota("Haganah: %s." % ["Condanna (0)", "Critica (1)", "Neutrale (2)", "Supporto (3)", "Coordinamento (4)"][v])
	# pezzi sotto le caselle 3 e 4
	if d > 0:
		if vecchio < 3 and v >= 3:
			_rilascia_haganah("3")
		if vecchio < 4 and v >= 4:
			_rilascia_haganah("4")
	else:
		if vecchio >= 4 and v < 4:
			_ritira_haganah("4", 2, 1)
		if vecchio >= 3 and v < 3:
			_ritira_haganah("3", 3, 0)


func _rilascia_haganah(k: String) -> void:
	var hp: Dictionary = s["haganah_pezzi"]
	if k == "3":
		s["disp"]["g"] = disp("g") + int(hp.get("3", 0))
		hp["3"] = 0
	else:
		var v: int = int(hp.get("4", 0))
		s["disp"]["g"] = disp("g") + (v % 10)
		s["disp"]["b"] = disp("b") + v / 10
		hp["4"] = 0
	nota("L'Haganah rende pezzi all'Irgun.")


func _ritira_haganah(k: String, celle: int, dep: int) -> void:
	var prese_c := 0
	var prese_b := 0
	while prese_c < celle:
		if disp("g") > 0:
			s["disp"]["g"] = disp("g") - 1
		elif ordine.any(func(x): return gue(x) > 0):
			# l'Irgun sceglierebbe: prende dalla mappa dove ce ne sono di più
			var best := ""
			for id in ordine:
				if gue(id) > 0 and (best == "" or gue(id) > gue(best)):
					best = id
			X(best)["a" if int(X(best)["a"]) > 0 else "u"] = int(X(best)["a" if int(X(best)["a"]) > 0 else "u"]) - 1
			_dopo(best)
		elif int(s["prigione"]) > 0:
			s["prigione"] = int(s["prigione"]) - 1
		else:
			break
		prese_c += 1
	while prese_b < dep:
		if disp("b") > 0:
			s["disp"]["b"] = disp("b") - 1
		elif ordine.any(func(x): return int(X(x)["b"]) > 0):
			for id in ordine:
				if int(X(id)["b"]) > 0:
					X(id)["b"] = int(X(id)["b"]) - 1
					break
		else:
			break
		prese_b += 1
	s["haganah_pezzi"][k] = prese_c + prese_b * 10
	nota("L'Haganah ritira %s%s." % [pz(prese_c, "g"), (" e " + pz(prese_b, "b")) if prese_b else ""])


func sposta_opinione(d: int) -> void:
	var v: int = clamp(int(s["opinione"]) + d, 0, 4)
	if v != int(s["opinione"]):
		s["opinione"] = v
		nota("Opinione internazionale: %s (%d)." % [nome_opinione(v), v])


func nome_opinione(v: int) -> String:
	return ["Ignorata", "Discussa", "Dibattuta", "Criticata", "Condannata"][v]


# ================================================================ Malesia e Kenya — Britannici

func op_train(f: String, p: Dictionary) -> void:
	var gratis: bool = p.get("gratis", false)
	var filtro = func(id): return (tipo(id) == "kl" or (tipo(id) in ["prov_m", "prov_g"] and X(id)["ctrl"] != "ins")) and p.get("filtro", func(_x): return true).call(id)
	var spazi := ciclo(f, p, "Addestramento: scegli uno spazio", filtro, func(id):
		var costo = 0 if gratis else 2
		if tipo(id) == "kl":
			var mx := 4
			var nt = numero(f, "Kuala Lumpur: quante Truppe piazzi (poi Polizia fino a 4 cubi)?", 0, min(mx, disp("t")), "train_t")
			if ferma():
				return
			var np = numero(f, "Kuala Lumpur: quanta Polizia piazzi?", 0, min(mx - nt, disp("p")), "train_p")
			if ferma():
				return
			if nt + np == 0:
				return
			if nt > 0 and cap("M18") == "s" and not gratis:
				costo = 4
			if int(s["ris"]["brit"]) < costo:
				nota("Risorse insufficienti.")
				return
			cambia_ris("brit", -costo)
			piazza(id, "t", nt)
			piazza(id, "p", np)
			nota("Addestramento a Kuala Lumpur: %s, %s." % [pz(nt, "t"), pz(np, "p")])
		else:
			var np: int = numero(f, "%s: quanta Polizia piazzi?" % nome_sp(id), 0, 2, "train_p")
			if ferma() or np == 0:
				return
			if int(s["ris"]["brit"]) < costo:
				return
			var k := piazza(id, "p", np)
			if k > 0:
				cambia_ris("brit", -costo)
				nota("Addestramento a %s: %s." % [nome_sp(id), pz(k, "p")])
	)
	if ferma():
		return
	var quante = 2 if comandante_attivo() == 2 and not p.get("limitata", false) else 1
	pacifica(f, quante, spazi)


func comandante_attivo() -> int:
	if s["tmp"].get("gurney", false):
		return -1
	return int(s["comandante"])


func _pacify_ok(id: String) -> bool:
	return X(id)["ctrl"] == "brit" and int(X(id)["t"]) > 0 and int(X(id)["p"]) > 0 and puo_sup(id)


func pacifica(f: String, quante: int, tra: Array = []) -> void:
	var costo = 3 if cap("M28") == "s" else 2
	if s["tmp"].get("pacifica_gratis", false):
		costo = 0
	var fatti: Array = []
	for k in quante:
		var sp = scegli_spazio(f, "Pacificazione (%d Risorse per passo): scegli uno spazio" % costo, func(x): return not (x in fatti) and (tra.is_empty() or x in tra) and _pacify_ok(x) and (int(X(x)["ter"]) > 0 or int(X(x)["sup"]) < 1) and int(s["ris"]["brit"]) >= costo, true, "pacify", "Nessuna Pacificazione")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		while int(X(sp)["ter"]) > 0 and int(s["ris"]["brit"]) >= costo:
			X(sp)["ter"] = int(X(sp)["ter"]) - 1
			cambia_ris("brit", -costo)
		var passi = 2 if cap("M28") == "u" else 1
		for i in passi:
			if int(X(sp)["ter"]) == 0 and int(X(sp)["sup"]) < 1 and int(s["ris"]["brit"]) >= costo:
				if i > 0 and not si_no(f, "Spostare %s di un altro livello verso il Supporto?" % nome_sp(sp), "pacify2"):
					break
				sposta_sup(sp, 1)
				cambia_ris("brit", -costo)
		nota("Pacificazione a %s: ora %s." % [nome_sp(sp), nome_sup(int(X(sp)["sup"]))])


func op_garrison(f: String, p: Dictionary) -> void:
	if not p.get("gratis", false):
		cambia_ris("brit", -2)
	var dests: Array = []
	var limitata: bool = p.get("limitata", false)
	var prov_usata := [false]
	while true:
		if limitata and dests.size() >= 1:
			break
		var dest = scegli_spazio(f, "Presidio: scegli una destinazione (Centri economici, Kuala Lumpur, 1 Provincia)", func(x): return not (x in dests) and (tipo(x) in ["ec", "kl"] or (tipo(x) in ["prov_m", "prov_g"] and not prov_usata[0])), true, "garrison_dest")
		if ferma() or dest == null:
			break
		dests.append(dest)
		if tipo(dest) in ["prov_m", "prov_g"]:
			prov_usata[0] = true
		raccogli(f, dest, "t", func(x): return x != dest, "Presidio")
		if ferma():
			return
		raccogli(f, dest, "p", func(x): return x != dest, "Presidio")
		if ferma():
			return
	var ecs: Array = []
	for id in ordine:
		if tipo(id) == "ec" and (not limitata or id in dests):
			ecs.append(id)
			var m := attiva(id, cubi(id))
			if m > 0:
				nota("%s attivate in %s." % [pz(m, "g"), nome_sp(id)])
	var sp = scegli_spazio(f, "Presidio: Assalto gratuito in un Centro economico?", func(x): return x in ecs and ins_n(x) > 0 and cubi(x) > 0, true, "garrison_ass", "Nessun Assalto")
	if ferma() or sp == null:
		return
	assalto_in(f, sp)


func _sweep(f: String, p: Dictionary) -> void:
	var paga = gioco() == "malesia" and not p.get("gratis", false)
	var filtro := func(id):
		var ok = (tipo(id) in ["prov_m", "prov_g", "kl"]) if gioco() == "malesia" else true
		return ok and (not paga or int(s["ris"]["brit"]) >= 2) and p.get("filtro", func(_x): return true).call(id)
	ciclo(f, p, "Rastrellamento: scegli una destinazione", filtro, func(id):
		if paga:
			cambia_ris("brit", -2)
		raccogli(f, id, "t", func(x): return id in SP[x]["adj"] and tipo(x) != "thai", "Rastrellamento", "sweep_muovi")
		if ferma():
			return
		var c := cubi(id)
		var n := c
		if gioco() == "malesia" and tipo(id) == "prov_g" and cap("M18") != "u":
			n = c / 2
		if gioco() == "kenya" and tipo(id) == "giungla":
			n = c if cap("K7") == "u" else c / 2
		var m := attiva(id, n)
		if m > 0:
			nota("%s attivat%s in %s." % [pz(m, "g"), "a" if m == 1 else "e", nome_sp(id)])
		if gioco() == "kenya" and tipo(id) == "giungla" and cap("K7") == "u" and gue(id) > 0:
			rimuovi_g(id, 1)
			nota("Pseudo-bande: 1 Guerriglia rimossa in %s." % nome_sp(id))
	)


func op_sweep(f: String, p: Dictionary) -> void:
	_sweep(f, p)


func _deploy_kenya(f: String, p: Dictionary) -> void:
	var solo_uno := cap("K7") == "s"
	var modo = "entrambi"
	if solo_uno:
		modo = chiedi(f, "Addestramento supplementare: Schieramento piazza cubi o sposta Truppe?", [o("piazza", "Piazza cubi"), o("muovi", "Sposta Truppe")], {"tag": "k7"})
		if ferma():
			return
	if modo != "muovi":
		ciclo(f, p, "Schieramento: scegli dove piazzare", func(id): return tipo(id) == "nairobi" or (tipo(id) in ["prov_r", "prov_n"] and X(id)["ctrl"] == "brit"), func(id):
			if tipo(id) == "nairobi":
				var nt = numero(f, "Nairobi: quante Truppe piazzi?", 0, min(4, disp("t")), "deploy_t")
				if ferma():
					return
				var np = numero(f, "Nairobi: quanta Polizia piazzi?", 0, min(4 - nt, disp("p")), "deploy_p")
				if ferma():
					return
				piazza(id, "t", nt)
				piazza(id, "p", np)
				nota("Nairobi: %s, %s." % [pz(nt, "t"), pz(np, "p")])
			else:
				var np = numero(f, "%s: quanta Polizia piazzi?" % nome_sp(id), 0, min(2, disp("p")), "deploy_p")
				if ferma():
					return
				piazza(id, "p", np)
				if np:
					nota("%s a %s." % [pz(np, "p"), nome_sp(id)])
		)
		if ferma():
			return
	if modo != "piazza":
		var dest = scegli_spazio(f, "Schieramento: verso quale spazio (non giungla) sposti Truppe?", func(x): return tipo(x) != "giungla", true, "deploy_dest", "Non spostare Truppe")
		if ferma() or dest == null:
			return
		raccogli(f, dest, "t", func(_x): return true, "Schieramento")


func limite_pipeline(cosa: String) -> int:
	var pl := int(s["pipeline"])
	if cosa == "relocate":
		return [0, 0, 1, 1, 2][pl]
	return [0, 1, 1, 2, 2][pl]


func limite_reprisal() -> int:
	if gioco() == "kenya":
		return limite_pipeline("reprisal")
	return 2 if comandante_attivo() == 0 else 1


func indignazione(forzata_due: bool = false) -> void:
	var pl := int(s["pipeline"])
	if pl <= 1 and not forzata_due:
		return
	if (s.get("camp", {}) as Dictionary).get("attivi", {}).has("E15"):
		nota("Operazione Legacy: nessun tiro per l'Indignazione.")
		return
	var d := dado()
	nota("Tiro per l'Indignazione: %d contro Pipeline %d." % [d, pl])
	if d < pl:
		cambia_pw(-2 if forzata_due else -1, "indignazione")


func _relocate_ok(id: String) -> bool:
	return tipo(id) == "prov_r" and X(id)["ctrl"] == "brit" and popolazione(id) > 0


func op_relocate(f: String, p: Dictionary) -> void:
	var q := p.duplicate()
	q["max"] = min(int(p.get("max", 99)), limite_pipeline("relocate") if not p.has("max_reloc") else int(p["max_reloc"]))
	var fatti := ciclo(f, q, "Trasferimento: scegli una Provincia di Riserva", func(id): return _relocate_ok(id), func(id):
		X(id)["pop"] = popolazione(id) - 1
		if popolazione(id) == 0:
			X(id)["sup"] = 0
		_aggiorna_controllo(id, true)
		if int(s["fuori"]) > 0:
			s["fuori"] = int(s["fuori"]) - 1
			s["disp"]["p"] = disp("p") + 1
		nota("Trasferimento a %s: Popolazione ora %d." % [nome_sp(id), popolazione(id)])
		s["tmp"]["ultimo_reloc"] = id
	)
	if fatti.size() > 0 and not p.get("no_outrage", false):
		indignazione()


func _airstrike_ok(id: String) -> bool:
	if int(X(id)["a"]) <= 0:
		return false
	if gioco() == "malesia":
		return tipo(id) in ["prov_m", "prov_g"] and cubi(id) > 0
	if cap("K5") == "s":
		return tipo(id) == "giungla"
	return tipo(id) in ["prov_r", "prov_n", "giungla"]


func sa_airstrike(f: String, _p: Dictionary) -> void:
	var n = 2 if gioco() == "malesia" or cap("K5") == "u" else 1
	var fatti: Array = []
	for k in n:
		var sp = scegli_spazio(f, "Attacco aereo: scegli uno spazio con Guerriglie attive", func(x): return not (x in fatti) and _airstrike_ok(x), k > 0, "airstrike")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		var m = 2 if gioco() == "kenya" and tipo(sp) == "giungla" else 1
		var t := rimuovi(sp, "a", m)
		nota("Attacco aereo a %s: %s rimoss%s." % [nome_sp(sp), pz(t, "g"), "a" if t == 1 else "e"])


func disponibili_nv() -> int:
	var n := 0
	for id in ordine:
		n += int(X(id)["nv"])
	return int(s["nv_tot"]) - n


func sa_resettle(f: String, _p: Dictionary) -> void:
	var n = 2 if comandante_attivo() == 1 else 1
	for k in n:
		var sp = scegli_spazio(f, "Reinsediamento: scegli una Provincia sotto Controllo britannico senza Nuovo Villaggio", func(x): return tipo(x) in ["prov_m", "prov_g"] and X(x)["ctrl"] == "brit" and int(X(x)["nv"]) == 0 and disponibili_nv() > 0, k > 0, "resettle")
		if ferma() or sp == null:
			return
		X(sp)["nv"] = 1
		if cap("M1") == "u" and int(X(sp)["sup"]) < 0:
			set_sup(sp, 0)
		else:
			sposta_sup(sp, -1)
		_dopo(sp)
		nota("Nuovo Villaggio a %s (%s)." % [nome_sp(sp), nome_sup(int(X(sp)["sup"]))])


func sa_reprisal(f: String, p: Dictionary) -> void:
	var n := int(p.get("max", limite_reprisal()))
	var fatti: Array = []
	for k in n:
		var sp = scegli_spazio(f, "Rappresaglia: scegli uno spazio con Truppe", func(x): return not (x in fatti) and int(X(x)["t"]) > 0 and (tipo(x) in ["prov_m", "prov_g"] if gioco() == "malesia" else popolazione(x) > 0), k > 0, "reprisal")
		if ferma() or sp == null:
			break
		fatti.append(sp)
		set_sup(sp, 0)
		if int(X(sp)["ter"]) == 0:
			X(sp)["ter"] = 1
		nota("Rappresaglia a %s: Neutrale e Terrore." % nome_sp(sp))
		if gue(sp) > 0:
			var a = scegli_spazio(f, "Rappresaglia: dove sposti 1 Guerriglia da %s?" % nome_sp(sp), func(x): return x in SP[sp]["adj"] and tipo(x) != "thai" or (x in SP[sp]["adj"] and gioco() == "malesia"), false, "reprisal_g")
			if ferma():
				return
			if a != null:
				muovi(sp, a, "a" if int(X(sp)["a"]) > 0 else "u", 1)
	if fatti.size() > 0 and gioco() == "kenya" and not p.get("no_outrage", false):
		indignazione()


func _reward_ok(id: String) -> bool:
	return X(id)["ctrl"] == "brit" and popolazione(id) > 0 and tipo(id) != "giungla"


func sa_reward(f: String, p: Dictionary) -> void:
	var n = 2 if cap("K11") == "u" else 1
	var fatti: Array = []
	for k in n:
		var sp = scegli_spazio(f, "Ricompensa: scegli uno spazio popolato sotto Controllo britannico", func(x): return not (x in fatti) and _reward_ok(x), true, "reward")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		if int(X(sp)["ter"]) > 0:
			X(sp)["ter"] = int(X(sp)["ter"]) - 1
		sposta_sup(sp, 1)
		nota("Ricompensa a %s: ora %s." % [nome_sp(sp), nome_sup(int(X(sp)["sup"]))])
		if cap("K11") == "s":
			var g = scegli_spazio("ins", "Riforme limitate: piazzi 1 Guerriglia in una Giungla di montagna?", func(x): return tipo(x) == "giungla", true, "k11", "No")
			if ferma():
				return
			if g != null:
				piazza(g, "g", 1)


# ================================================================ Malesia e Kenya — Insorti

func _rally_ok(id: String) -> bool:
	var x = X(id)
	var t := tipo(id)
	if gioco() == "malesia":
		if not (t in ["prov_m", "prov_g", "thai", "kl"]):
			return false
		if int(x["sup"]) > 0:
			return false
		if int(x["nv"]) > 0 and not (cap("M1") == "s" and int(x["sup"]) < 0):
			return false
		return true
	return t == "prov_r" or int(x["sup"]) <= 0


func op_rally(f: String, p: Dictionary) -> void:
	var gratis: bool = p.get("gratis", false)
	var spazi = ciclo(f, p, "Raduno: scegli uno spazio", func(id): return _rally_ok(id) and (gratis or int(s["ris"]["ins"]) >= 1) and p.get("filtro", func(_x): return true).call(id), func(id):
		if not gratis:
			cambia_ris("ins", -1)
		raduno_in(f, id)
	)
	if ferma() or gioco() != "malesia" or p.get("no_agitate", false):
		return
	agita(f, 1, spazi)


func raduno_in(f: String, id: String) -> void:
	var x = X(id)
	var opz: Array = [o("g", "Piazza 1 Guerriglia")]
	if gue(id) >= 2 and int(x["b"]) < 2 and base_ok(id):
		opz.append(o("b", "Sostituisci 2 Guerriglie con 1 Base"))
	if int(x["b"]) > 0:
		opz.append(o("molte", "Piazza fino a %d Guerriglie" % (popolazione(id) + int(x["b"]))))
		if int(x["a"]) > 0:
			opz.append(o("sotto", "Rendi clandestine tutte le Guerriglie"))
	var v = chiedi(f, "Raduno a %s:" % nome_sp(id), opz, {"tag": "rally_modo"})
	if ferma():
		return
	match v:
		"g":
			piazza(id, "g", 1)
			nota("Raduno a %s: 1 Guerriglia." % nome_sp(id))
		"b":
			var t := rimuovi(id, "a", 2)
			rimuovi(id, "u", 2 - t)
			piazza(id, "b", 1)
			nota("Raduno a %s: nuova Base." % nome_sp(id))
		"molte":
			var mx = popolazione(id) + int(x["b"])
			var n := numero(f, "Quante Guerriglie piazzi a %s?" % nome_sp(id), 1, mx, "rally_n")
			if ferma():
				return
			var k := piazza(id, "g", n)
			nota("Raduno a %s: %s." % [nome_sp(id), pz(k, "g")])
		"sotto":
			clandestine(id)
			nota("Raduno a %s: Guerriglie clandestine." % nome_sp(id))


func agita(f: String, quante: int, tra: Array = [], gratis: bool = false) -> void:
	var fatti: Array = []
	for k in quante:
		var ok := func(x):
			if x in fatti or (not tra.is_empty() and not (x in tra)) or not puo_sup(x):
				return false
			if not gratis and int(s["ris"]["ins"]) < 1:
				return false
			if tra.is_empty():
				return ins_n(x) > 0 and X(x)["ctrl"] != "brit" and (int(X(x)["ter"]) > 0 or int(X(x)["sup"]) > -1)
			return X(x)["ctrl"] == "ins" and int(X(x)["b"]) > 0 and (int(X(x)["ter"]) > 0 or int(X(x)["sup"]) > -1)
		var sp = scegli_spazio(f, "Agitazione (1 Risorsa per passo): scegli uno spazio", ok, true, "agitate", "Nessuna Agitazione")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		while int(X(sp)["ter"]) > 0 and (gratis or int(s["ris"]["ins"]) >= 1):
			X(sp)["ter"] = int(X(sp)["ter"]) - 1
			if not gratis:
				cambia_ris("ins", -1)
		if int(X(sp)["ter"]) == 0 and int(X(sp)["sup"]) > -1 and (gratis or int(s["ris"]["ins"]) >= 1):
			sposta_sup(sp, -1)
			if not gratis:
				cambia_ris("ins", -1)
		nota("Agitazione a %s: ora %s." % [nome_sp(sp), nome_sup(int(X(sp)["sup"]))])


func op_march(f: String, p: Dictionary) -> void:
	var gratis: bool = p.get("gratis", false)
	ciclo(f, p, "Marcia: scegli una destinazione", func(id):
		var costo = 0 if gratis or (gioco() == "malesia" and tipo(id) == "ec") else 1
		return int(s["ris"]["ins"]) >= costo and SP[id]["adj"].any(func(a): return gue(a) > 0) and p.get("filtro", func(_x): return true).call(id)
	, func(id):
		var costo = 0 if gratis or (gioco() == "malesia" and tipo(id) == "ec") else 1
		if costo:
			cambia_ris("ins", -costo)
		for a in SP[id]["adj"]:
			if gue(a) == 0:
				continue
			var nu = numero(f, "Marcia verso %s: quante Guerriglie clandestine da %s?" % [nome_sp(id), nome_sp(a)], 0, int(X(a)["u"]), "march_u")
			if ferma():
				return
			var na = numero(f, "Marcia verso %s: quante Guerriglie attive da %s?" % [nome_sp(id), nome_sp(a)], 0, int(X(a)["a"]), "march_a")
			if ferma():
				return
			if nu + na == 0:
				continue
			var att := false
			var t := tipo(id)
			if gioco() == "malesia":
				att = (t == "ec" or int(X(id)["sup"]) > 0) and nu + na + cubi(id) > 3
			else:
				att = ((t in ["prov_n", "nairobi"] and popolazione(id) > 0) or (t == "prov_r" and int(X(id)["sup"]) > 0)) and nu + na + cubi(id) > 3
			muovi(a, id, "u", nu)
			muovi(a, id, "a", na)
			if att:
				attiva(id, nu)
			nota("%s da %s a %s%s." % [pz(nu + na, "g"), nome_sp(a), nome_sp(id), " (attivate)" if att else ""])
	)


func op_attack(f: String, p: Dictionary) -> void:
	var gratis: bool = p.get("gratis", false)
	ciclo(f, p, "Attacco: scegli uno spazio con Guerriglie e cubi britannici", func(id): return gue(id) > 0 and cubi(id) > 0 and (gratis or int(s["ris"]["ins"]) >= 1) and p.get("filtro", func(_x): return true).call(id), func(id):
		if not gratis:
			cambia_ris("ins", -1)
		var amb := false
		if p.get("ambush", false) and not p.get("ambush_usato", false) and int(X(id)["u"]) > 0:
			amb = si_no(f, "Imboscata a %s (successo sicuro, 1 sola Guerriglia attivata)?" % nome_sp(id), "ambush")
			if ferma():
				return
		if amb:
			p["ambush_usato"] = true
			attiva(id, 1)
			_colpisci(f, id, 2 if cap("M8") == "s" else 1)
			return
		var g := gue(id)
		attiva(id, g)
		var d := dado()
		nota("Attacco a %s: dado %d contro %d Guerriglie." % [nome_sp(id), d, g])
		if d <= g:
			_colpisci(f, id, 2)
	)


func _colpisci(f: String, id: String, n: int) -> void:
	var tolti_t := 0
	if cap("M8") == "s":
		for i in n:
			if cubi(id) == 0:
				break
			var k = "p"
			if int(X(id)["t"]) > 0 and int(X(id)["p"]) > 0:
				k = chiedi(f, "Ala armata: quale cubo rimuovi a %s?" % nome_sp(id), [o("p", "Polizia"), o("t", "Truppa")], {"tag": "mnla"})
				if ferma():
					return
			elif int(X(id)["p"]) == 0:
				k = "t"
			rimuovi(id, k, 1)
			if k == "t":
				tolti_t += 1
	else:
		var np := rimuovi(id, "p", n)
		tolti_t = rimuovi(id, "t", n - np)
	nota("Attacco riuscito a %s." % nome_sp(id))
	if tolti_t > 0:
		cambia_pw(-1, "Truppe uccise")
		if cap("M8") == "u":
			rimuovi(id, "a", tolti_t)


func op_terror(f: String, p: Dictionary) -> void:
	var gratis: bool = p.get("gratis", false)
	ciclo(f, p, "Terrore: scegli uno spazio con una Guerriglia clandestina", func(id):
		var costo = 0 if gratis or (gioco() == "malesia" and tipo(id) == "ec") else 1
		return int(X(id)["u"]) > 0 and int(s["ris"]["ins"]) >= costo and p.get("filtro", func(_x): return true).call(id)
	, func(id):
		var costo = 0 if gratis or (gioco() == "malesia" and tipo(id) == "ec") else 1
		if costo:
			cambia_ris("ins", -costo)
		terrore_in(f, id)
	)


func terrore_in(f: String, id: String) -> void:
	attiva(id, 1)
	if gioco() == "malesia":
		if tipo(id) == "ec":
			if int(X(id)["sab"]) == 0:
				X(id)["sab"] = 1
			nota("Sabotaggio al %s." % nome_sp(id))
		else:
			if int(X(id)["ter"]) == 0:
				X(id)["ter"] = 1
			sposta_sup(id, -1)
			nota("Terrore a %s: ora %s." % [nome_sp(id), nome_sup(int(X(id)["sup"]))])
		if cap("M27") == "s" and int(X(id)["p"]) > 0:
			rimuovi(id, "p", 1)
			nota("1 Polizia uccisa a %s." % nome_sp(id))
		return
	var modo = "terrore"
	if int(X(id)["p"]) > 0:
		modo = chiedi(f, "Terrore a %s:" % nome_sp(id), [o("terrore", "Terrore e verso la Resistenza"), o("polizia", "Rimuovi fino a 2 Polizia")], {"tag": "terror_modo"})
		if ferma():
			return
	if modo == "polizia":
		var t := rimuovi(id, "p", 2)
		nota("Terrore a %s: %s eliminat%s." % [nome_sp(id), pz(t, "p"), "a" if t == 1 else "i"])
	else:
		if int(X(id)["ter"]) == 0:
			X(id)["ter"] = 1
		sposta_sup(id, -1)
		nota("Terrore a %s: ora %s." % [nome_sp(id), nome_sup(int(X(id)["sup"]))])


func sa_extort(f: String, _p: Dictionary) -> void:
	var fatti: Array = []
	for k in 2:
		var sp = scegli_spazio(f, "Estorsione: scegli uno spazio con Guerriglia clandestina e senza Nuovo Villaggio", func(x): return not (x in fatti) and int(X(x)["u"]) > 0 and int(X(x)["nv"]) == 0, k > 0, "extort")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		attiva(sp, 1)
		var g := 1
		if cap("M2") == "s" and X(sp)["ctrl"] == "ins":
			g = max(1, popolazione(sp))
		cambia_ris("ins", g)


func sa_intimidate(f: String, _p: Dictionary) -> void:
	var n = 1 if cap("M27") == "u" else 2
	n = int(_p.get("max", n))
	var fatti: Array = []
	for k in n:
		var sp = scegli_spazio(f, "Intimidazione: scegli uno spazio con Guerriglia clandestina", func(x): return not (x in fatti) and int(X(x)["u"]) > 0 and (int(X(x)["p"]) > 0 or int(X(x)["nv"]) > 0), k > 0, "intimidate")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		if cap("M27") == "u":
			attiva(sp, 1)
		var modo = "p"
		if int(X(sp)["nv"]) > 0 and gue(sp) > cubi(sp):
			modo = "nv" if int(X(sp)["p"]) == 0 else chiedi(f, "Intimidazione a %s:" % nome_sp(sp), [o("p", "Rimuovi 1 Polizia"), o("nv", "Rimuovi il Nuovo Villaggio e il Supporto")], {"tag": "intim"})
			if ferma():
				return
		if modo == "p":
			rimuovi(sp, "p", 1)
			nota("Intimidazione a %s: 1 Polizia rimossa." % nome_sp(sp))
		else:
			X(sp)["nv"] = 0
			if int(X(sp)["sup"]) > 0:
				set_sup(sp, 0)
			nota("Intimidazione a %s: Nuovo Villaggio rimosso." % nome_sp(sp))


func sa_ambush(f: String, p: Dictionary) -> void:
	# usata come Attività Speciale libera da un Evento: un Attacco gratuito con Imboscata in 1 spazio
	var q := {"gratis": true, "max": 1, "ambush": true, "limitata": true}
	op_attack(f, q)


func sa_supply(_f: String, _p: Dictionary) -> void:
	var tot := 0
	var raggiunti := _collegati_nairobi()
	for id in ordine:
		var b := int(X(id)["b"])
		if b == 0:
			continue
		if id == "nairobi" or id in raggiunti:
			tot += b * (2 if cap("K3") == "s" else 1)
	nota("Rifornimento: %d Risorse." % tot)
	cambia_ris("ins", tot)


## Spazi raggiungibili da Nairobi attraverso spazi con Guerriglie o Resistenza (K3: Controllo o Resistenza).
func _collegati_nairobi() -> Array:
	var via := func(id):
		if cap("K3") == "u":
			return X(id)["ctrl"] == "ins" or int(X(id)["sup"]) < 0
		return gue(id) > 0 or int(X(id)["sup"]) < 0
	var visti := {"nairobi": true}
	var fronte := ["nairobi"]
	var raggiunti: Array = []
	while not fronte.is_empty():
		var c: String = fronte.pop_back()
		for a in SP[c]["adj"]:
			if visti.has(a):
				continue
			visti[a] = true
			raggiunti.append(a)
			if via.call(a):
				fronte.append(a)
	return raggiunti


func _oath_ok(id: String) -> bool:
	if int(X(id)["u"]) <= 0 or popolazione(id) <= 0:
		return false
	if cap("K28") == "u" and X(id)["ctrl"] == "brit":
		return false
	if cap("K28") == "s":
		return tipo(id) != "giungla"
	return tipo(id) == "prov_r"


func sa_oath(f: String, _p: Dictionary) -> void:
	var n = 2 if cap("K28") == "s" else 1
	var fatti: Array = []
	for k in n:
		var sp = scegli_spazio(f, "Giuramento: scegli una Provincia di Riserva popolata con Guerriglia clandestina", func(x): return not (x in fatti) and _oath_ok(x), k > 0, "oath")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		piazza(sp, "g", 1)
		sposta_sup(sp, -1)
		nota("Giuramento a %s: ora %s." % [nome_sp(sp), nome_sup(int(X(sp)["sup"]))])


func _raid_ok(id: String) -> bool:
	if not (tipo(id) in ["prov_r", "prov_n"]):
		return false
	var adj_j: bool = SP[id]["adj"].any(func(a): return tipo(a) == "giungla")
	if not adj_j:
		return false
	return gue(id) > 0 or SP[id]["adj"].any(func(a): return tipo(a) == "giungla" and gue(a) > 0)


func sa_raid(f: String, _p: Dictionary) -> void:
	var n = 2 if cap("K31") == "s" else 1
	var fatti: Array = []
	for k in n:
		var sp = scegli_spazio(f, "Incursione: scegli una Provincia adiacente a una Giungla di montagna", func(x): return not (x in fatti) and _raid_ok(x), k > 0, "raid")
		if ferma() or sp == null:
			return
		fatti.append(sp)
		var opz: Array = []
		if SP[sp]["adj"].any(func(a): return tipo(a) == "giungla" and gue(a) > 0):
			opz.append(o("dentro", "Entra con 1-2 Guerriglie e fai un'Operazione Limitata gratuita"))
		if gue(sp) > 0:
			opz.append(o("fuori", "Ritira le Guerriglie nella giungla (clandestine)"))
		var v = chiedi(f, "Incursione a %s:" % nome_sp(sp), opz, {"tag": "raid_modo"})
		if ferma():
			return
		if v == "dentro":
			var j = scegli_spazio(f, "Da quale Giungla?", func(a): return a in SP[sp]["adj"] and tipo(a) == "giungla" and gue(a) > 0, false, "raid_j")
			if ferma():
				return
			var mx: int = min(2, gue(j))
			var q := numero(f, "Quante Guerriglie entrano?", 1, mx, "raid_n")
			if ferma():
				return
			var nu: int = min(q, int(X(j)["u"]))
			muovi(j, sp, "u", nu)
			muovi(j, sp, "a", q - nu)
			nota("Incursione: %s da %s a %s." % [pz(q, "g"), nome_sp(j), nome_sp(sp)])
			var ops: Array = []
			for op in ["rally", "terror"]:
				ops.append(o(op, nome_op(op)))
			var op = chiedi(f, "Operazione Limitata gratuita a %s:" % nome_sp(sp), ops, {"tag": "raid_op"})
			if ferma():
				return
			call("op_" + op, f, {"gratis": true, "max": 1, "limitata": true, "filtro": func(x): return x == sp})
			if ferma():
				return
		else:
			var j = scegli_spazio(f, "Verso quale Giungla?", func(a): return a in SP[sp]["adj"] and tipo(a) == "giungla", false, "raid_j2")
			if ferma():
				return
			var nu := int(X(sp)["u"])
			var na := int(X(sp)["a"])
			muovi(sp, j, "u", nu)
			muovi(sp, j, "a", na)
			clandestine(j)
			nota("Incursione: %s ritirate in %s." % [pz(nu + na, "g"), nome_sp(j)])
