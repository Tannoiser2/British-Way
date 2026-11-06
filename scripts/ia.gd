## Giocatore artificiale: prova molte giocate casuali dell'atto in corso su copie dello stato
## (con dadi diversi, così non "vede" il futuro) e sceglie quella che porta alla posizione migliore.
class_name IA
extends RefCounted

const PASSIVE := ["fine", "passa", "no", "nessuna"]


static func politica_casuale(_m, q: Dictionary, rng: RandomNumberGenerator):
	var opz: Array = q["opz"]
	var tag: String = str(q.get("x", {}).get("tag", ""))
	var pesi: Array = []
	var tot := 0.0
	for o in opz:
		var w := 1.0
		var v = o["v"]
		if v is String and v in PASSIVE:
			w = 0.15 if tag == "esegui" else 0.45
		if q.get("x", {}).get("num", false):
			w = 1.0 + float(v) * 0.6
		if v is String and v == "si":
			w = 1.6
		pesi.append(w)
		tot += w
	var r := rng.randf() * tot
	for i in opz.size():
		r -= pesi[i]
		if r <= 0.0:
			return opz[i]["v"]
	return opz[-1]["v"]


## Sceglie la sequenza di risposte migliore per la fazione f partendo dallo stato base e dalle risposte già date.
static func pianifica(base: Dictionary, prefisso: Array, f: String, n_sim: int, rng: RandomNumberGenerator) -> Array:
	var best := -INF
	var best_ans: Array = prefisso.duplicate()
	for k in n_sim:
		var m := Motore.new()
		m.usa_dati(base["gioco"])
		m.s = base.duplicate(true)
		m.s["rs"] = 1 + rng.randi() % 2147483640
		m.autorisposta = func(mm, q): return politica_casuale(mm, q, rng)
		m.esegui(prefisso)
		var v := m.valuta(f) + rng.randf() * 0.5
		if v > best:
			best = v
			best_ans = m.risposte_usate()
	return best_ans


## Risposta dell'IA alla domanda q (need) dell'atto in corso; piano: Array condiviso con il piano corrente.
static func rispondi(base: Dictionary, risposte: Array, q: Dictionary, piano: Array, rng: RandomNumberGenerator, n_sim: int = 28):
	var i := risposte.size()
	var valido := func(v):
		for o in q["opz"]:
			if str(o["v"]) == str(v):
				return true
		return false
	if piano.size() > i and piano.slice(0, i) == risposte and valido.call(piano[i]):
		return piano[i]
	var nuovo = pianifica(base, risposte, q["f"], n_sim if i == 0 else max(8, n_sim / 2), rng)
	piano.clear()
	piano.append_array(nuovo)
	if nuovo.size() > i and valido.call(nuovo[i]):
		return nuovo[i]
	return politica_casuale(null, q, rng)
