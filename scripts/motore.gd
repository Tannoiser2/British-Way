## Motore completo (regole + eventi) con la valutazione delle posizioni usata dall'IA.
class_name Motore
extends Campagna


# ---------------------------------------------------------------- stima della Propaganda (senza effetti)

func stima_propaganda() -> int:
	var d := 0
	match gioco():
		"palestina":
			var ferr := 0
			for id in ordine:
				var x = X(id)
				match tipo(id):
					"distretto":
						d -= int(x["sab"]) + int(x["ter"])
					"ferrovia":
						if int(x["sab"]) > 0:
							ferr += 1
							d -= 2
					"citta":
						var v = 2 * int(x["sab"]) + 3 * int(x["ter"])
						d -= v
						if v == 0:
							d += 1
			if ferr == 0:
				d += 2
		"cipro":
			d -= int(s["opinione"])
			var pulite := 0
			var dep := false
			for id in ordine:
				var x = X(id)
				if tipo(id) in ["citta", "base"]:
					d -= int(x["sab"]) * int(SP[id].get("valore", 1))
				if tipo(id) == "citta" and int(x["sab"]) == 0:
					pulite += 1
				if tipo(id) == "montagna" and int(x["b"]) > 0:
					dep = true
			if not dep:
				d += 2
			d += pulite / 2
		"malesia":
			for id in ordine:
				var x = X(id)
				if int(x["sup"]) > 0:
					d += popolazione(id)
				elif int(x["sup"]) < 0 and int(x["nv"]) == 0:
					d -= popolazione(id)
				if tipo(id) == "ec" and (int(x["sab"]) > 0 or gue(id) > cubi(id)):
					d -= 1
			if int(X("kl")["ter"]) > 0:
				d -= 1
		"kenya":
			var le := 0
			var re := 0
			for id in ordine:
				if int(X(id)["sup"]) > 0:
					le += popolazione(id)
				elif int(X(id)["sup"]) < 0:
					re += popolazione(id)
				if tipo(id) in ["prov_n", "nairobi"] and popolazione(id) > 0 and int(X(id)["ter"]) > 0:
					d -= 1
			if re > le:
				d -= re - le
			if ins_n("nairobi") == 0:
				d += 2
			var fuori := false
			for id in ordine:
				if tipo(id) != "giungla" and int(X(id)["b"]) > 0:
					fuori = true
			if not fuori:
				d += 2
	return d


## Valutazione dal punto di vista britannico (più alta = meglio per i Britannici).
func valuta_brit() -> float:
	if finita():
		var v: String = s["fine"]["v"]
		return 10000.0 if v == "brit" else (-10000.0 if v == "ins" else 0.0)
	var pw := float(s["pw"])
	var v := pw * 10.0
	# quanto pesa la prossima Propaganda: di più se è vicina
	var carte_a_prop := 0
	for c in s["mazzo"]:
		if carta_dati(c).get("propaganda", false):
			break
		carte_a_prop += 1
	var peso = 7.0 if carte_a_prop <= 2 else 4.0
	var stima := float(stima_propaganda())
	v += stima * peso
	if cellule():
		# minaccia: Sabotaggi probabili nei prossimi turni (spazi con Cellule clandestine)
		var minacce: Array = []
		for id in ordine:
			var x := X(id)
			if int(x["u"]) <= 0:
				continue
			var t := tipo(id)
			var val := 0.0
			if gioco() == "palestina":
				val = 2.0 if t == "citta" else (2.0 if t == "ferrovia" and int(x["sab"]) == 0 else (1.0 if t == "distretto" else 0.0))
			else:
				val = float(SP[id].get("valore", 0)) if t in ["citta", "base"] else 0.0
			if val <= 0.0:
				continue
			var bonus := 2 if _vicino_deposito(id) else 0
			var pol := 0 if cap("C31") != "" else int(x["p"])
			var ok := 0
			for d in range(1, 7):
				if d + bonus - pol > 2:
					ok += 1
			minacce.append(val * ok / 6.0)
		minacce.sort()
		minacce.reverse()
		var minaccia := 0.0
		for i in min(4, minacce.size()):
			minaccia += float(minacce[i])
		v -= minaccia * (5.0 if carte_a_prop <= 2 else 3.0)
		var soglia := pw + stima
		if soglia <= 0:
			v -= 400.0 if carte_a_prop <= 2 else 120.0
		v += intel_tot() * 3.0 + (s["intel"] as Array).size() * 1.5
		v += float(s["prigione"]) * 2.5
		for id in ordine:
			var x = X(id)
			v -= float(x["u"]) * 3.0 + float(x["a"]) * 1.6 + float(x["b"]) * 5.0
			if gioco() == "cipro" and tipo(id) == "montagna":
				v -= float(x["b"]) * 4.0
			v += float(x["p"]) * 0.8 + float(x["t"]) * 0.3
			# presenza britannica dove ci sono Cellule (pressione)
			if gue(id) > 0 and cubi(id) > 0:
				v += 1.0
		v -= float(disp("g")) * 0.6 + float(disp("b")) * 1.5
		if gioco() == "palestina":
			v -= float(s["haganah"]) * 4.0
		else:
			v -= float(s["opinione"]) * 5.0
	else:
		if pw + stima <= 2:
			v -= 300.0 if carte_a_prop <= 2 else 80.0
		if pw + stima >= 18:
			v += 300.0 if carte_a_prop <= 2 else 80.0
		for id in ordine:
			var x = X(id)
			var pop := float(popolazione(id))
			v += float(x["sup"]) * pop * 3.0
			if x["ctrl"] == "brit":
				v += pop * 1.5 + 0.5
			elif x["ctrl"] == "ins":
				v -= pop * 2.0 + 0.8
			v -= float(x["b"]) * 6.0 + float(x["u"]) * 1.8 + float(x["a"]) * 1.0
			v -= float(x["ter"]) * 1.5
			v += float(x["nv"]) * 1.0
			v += float(x["t"]) * 0.3 + float(x["p"]) * 0.5
			if gioco() == "kenya" and tipo(id) != "giungla":
				v -= float(x["b"]) * 3.0
		v -= float(s["ris"]["ins"]) * 0.8
		if gioco() == "malesia":
			v += float(s["ris"]["brit"]) * 0.6
		else:
			v -= float(s["pipeline"]) * 1.0
	return v


## Criteri di lungo periodo tratti dalle guide strategiche ufficiali (Strategy Guide dei quattro regolamenti)
## e dalle discussioni dei giocatori. Valore dal punto di vista britannico. Si può spegnere per lato (banco di prova).
static var strategia := {"brit": true, "ins": true}
static var spenti: Array = []


func strategia_brit() -> float:
	if finita():
		return 0.0
	var v := 0.0
	if "gioco" in spenti:
		return v
	match gioco():
		"malesia":
			for id in ordine:
				var x := X(id)
				var t := tipo(id)
				# «Economic attrition»: i Centri economici scoperti sono il bersaglio preferito dell'MCP
				if t == "ec":
					var minaccia := 0
					for a in SP[id]["adj"]:
						minaccia += int(X(a)["u"])
					minaccia += int(x["u"])
					if int(x["sab"]) == 0:
						v -= max(0, min(minaccia, 3) - cubi(id)) * 1.5
					else:
						v -= 3.0
					v += min(cubi(id), 2) * 0.8
				# Base in Thailandia: quasi intoccabile e rende Risorse per tutta la partita
				if t == "thai":
					v -= float(x["b"]) * 4.0
				# «Clear, Secure, Pacify»: Polizia e Nuovi Villaggi dove l'MCP non controlla, presto
				if t in ["prov_g", "prov_m", "kl"]:
					var pop := popolazione(id)
					if x["ctrl"] != "ins" and pop > 0:
						v += min(int(x["p"]), 2) * 0.6
						if int(x["nv"]) > 0 and int(x["sup"]) >= 0:
							v += 1.0
					# «Maintain presence»: l'MCP vuole essere ovunque la popolazione conta
					if pop > 0 and gue(id) > 0 and cubi(id) == 0:
						v -= 0.8 * pop
		"kenya":
			for id in ordine:
				var x := X(id)
				var t := tipo(id)
				# «Protect the settlers»: Nairobi e Province non di Riserva scoperte con Guerriglie vicine
				if t in ["nairobi", "prov_n"]:
					var vicine := int(x["u"])
					for a in SP[id]["adj"]:
						vicine += int(X(a)["u"])
					if int(x["ter"]) == 0 and cubi(id) < 2:
						v -= min(vicine, 2) * 1.2
				# «Secure the Reserves»: Riserve popolate con presenza Mau Mau
				if t == "prov_r" and ins_n(id) > 0:
					v -= float(popolazione(id)) * 1.0
				# spingerli nelle Giungle di montagna: fuori dalle giungle i Mau Mau pesano di più
				if t != "giungla":
					v -= float(gue(id)) * 0.8
			# «Maintain pressure»: le Risorse Mau Mau sono scarse e decisive
			v -= float(s["ris"]["ins"]) * 0.8
		"cipro":
			for id in ordine:
				var x := X(id)
				var t := tipo(id)
				# «Buddy system»: la Polizia isolata è il bersaglio di Infiltrazione (e costa Intel)
				if t == "citta" and int(x["p"]) == 1 and int(x["t"]) == 0:
					var cellule_vicine := int(x["u"])
					for a in SP[id]["adj"]:
						cellule_vicine += int(X(a)["u"])
					if cellule_vicine > 0:
						v -= 1.5
				# «Prepare and then strike»: Depositi in Città con Cellule clandestine = Sabotaggio imminente
				if t in ["citta", "base"] and int(x["b"]) > 0 and int(x["u"]) > 0 and int(x["sab"]) == 0:
					v -= 1.5
				# Coprifuoco senza Cellule: Città messa in sicurezza (vale fino a 2 VP a fine campagna)
				if t == "citta" and int(x["cf"]) > 0:
					v += 1.0 if gue(id) == 0 else -1.0
			# «Follow the intel»: Intel e Prigione si alimentano a vicenda
			v += min(float(s["prigione"]), 6.0) * 0.8
	return v


func valuta(f: String) -> float:
	var v := valuta_brit()
	# Dal banco di prova (partite IA contro IA, 40 per configurazione): i criteri aiutano i Britannici in Malesia,
	# Kenya e Cipro e l'EOKA a Cipro; in Palestina e per MCP e Mau Mau peggioravano il gioco, quindi restano spenti.
	if strategia.get(f, true) and gioco() != "palestina" and (f == "brit" or gioco() == "cipro"):
		v += strategia_brit()
	if in_campagna() and not finita():
		v += stima_prestigio() * 12.0
	elif in_campagna():
		v += float(s["camp"]["prestigio"]) * 12.0
	return v if f == "brit" else -v
