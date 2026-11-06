## Nucleo del motore: stato della partita, domande/risposte deterministiche, sequenza di gioco.
##
## Ogni decisione di un giocatore è una "domanda" (chiedi). Un "atto" (il turno di una fazione su una carta,
## o un passo del Round di Propaganda) è una procedura che pone domande: si riesegue da capo sullo stato
## di partenza con l'elenco delle risposte date finora, finché non ne serve una nuova (need) o l'atto finisce.
## Così la partita è sempre ricostruibile da seme + risposte: salvataggi, gioco online e IA usano la stessa via.
class_name Nucleo
extends RefCounted

const FAZ := ["brit", "ins"]
const CASELLE := ["limitata", "evento", "opsa"]

static var _dati_cache: Dictionary = {}

var s: Dictionary = {}          # stato serializzabile
var D: Dictionary = {}          # dati fissi del gioco (mappa, carte)
var SP: Dictionary = {}         # id spazio -> dati fissi
var ordine: Array = []          # id spazi in ordine di mappa

# domande
var _ans: Array = []
var _i := 0
var need = null                 # domanda in sospeso (Dictionary) o null
var registro: Array = []        # righe di registro prodotte dall'atto corrente
var autorisposta: Callable       # se valida, risponde da sola alle domande (simulazioni dell'IA)


# ---------------------------------------------------------------- dati

static func carica_dati(gioco: String) -> Dictionary:
	if _dati_cache.has(gioco):
		return _dati_cache[gioco]
	var d: Dictionary = {}
	for parte in ["mappa", "carte"]:
		var f = FileAccess.open("res://dati/%s_%s.json" % [gioco, parte], FileAccess.READ)
		if f:
			var x = JSON.parse_string(f.get_as_text())
			if x is Dictionary:
				d.merge(x)
	_dati_cache[gioco] = d
	return d


func usa_dati(gioco: String) -> void:
	D = carica_dati(gioco)
	SP.clear()
	ordine.clear()
	for sp in D.get("spazi", []):
		SP[sp["id"]] = sp
		ordine.append(sp["id"])


func cellule() -> bool:
	return s["gioco"] == "palestina" or s["gioco"] == "cipro"


func gioco() -> String:
	return s["gioco"]


# ---------------------------------------------------------------- nomi

func nome_faz(f: String) -> String:
	if f == "brit":
		return "Britannici"
	return {"palestina": "Irgun", "cipro": "EOKA", "malesia": "MCP", "kenya": "Mau Mau"}[s["gioco"]]


func nome_pezzo(k: String, n: int = 1) -> String:
	var c := cellule()
	match k:
		"t": return "Truppa" if n == 1 else "Truppe"
		"p": return "Polizia" if n == 1 else "Poliziotti"
		"g", "u", "a":
			if c:
				return "Cellula" if n == 1 else "Cellule"
			return "Guerriglia" if n == 1 else "Guerriglie"
		"b":
			if c:
				return "Deposito d'armi" if n == 1 else "Depositi d'armi"
			return "Base" if n == 1 else "Basi"
	return k


func nome_sp(id: String) -> String:
	if SP.has(id):
		return SP[id]["nome"]
	return id


func pz(n: int, k: String) -> String:
	return "%d %s" % [n, nome_pezzo(k, n)]


func nota(t: String) -> void:
	registro.append(t)


# ---------------------------------------------------------------- nuova partita

func nuova(gioco_id: String, seme: int, opzioni: Dictionary = {}) -> void:
	usa_dati(gioco_id)
	s = {"gioco": gioco_id, "seme": seme, "rs": seme % 2147483647 + 1, "opz": opzioni, "atto_n": 0}
	var st: Dictionary = D["setup"]
	s["pw"] = int(st["pw"])
	s["pw_max"] = int(D["pw_track"]["max"])
	s["sp"] = {}
	for id in ordine:
		var x := {"t": 0, "p": 0, "u": 0, "a": 0, "b": 0, "cf": 0, "sab": 0, "ter": 0, "sup": 0, "ctrl": "", "nv": 0}
		if SP[id].has("pop"):
			x["pop"] = int(SP[id]["pop"])
		var su: Dictionary = st["spazi"].get(id, {})
		x["t"] = int(su.get("t", 0))
		x["p"] = int(su.get("p", 0))
		x["u"] = int(su.get("g", 0))
		x["b"] = int(su.get("b", 0))
		x["sup"] = int(su.get("sup", 0))
		s["sp"][id] = x
	var dp: Dictionary = st["disp"]
	s["disp"] = {"t": int(dp["t"]), "p": int(dp["p"]), "g": int(dp["g"]), "b": int(dp["b"])}
	s["fuori"] = int(st.get("fuori", 0))       # Kenya: Polizia fuori gioco
	s["fuori_g"] = 0                           # pezzi tolti dal gioco (eventi)
	s["prigione"] = 0
	s["ris"] = st.get("ris", {"brit": 0, "ins": 0}).duplicate()
	s["haganah"] = int(st.get("haganah", 0))
	s["haganah_pezzi"] = {"3": 0, "4": 0}       # pezzi tenuti sul tracciato (Cellule sotto 3, Cellule+Deposito sotto 4)
	s["opinione"] = int(st.get("opinione", 0))
	s["comandante"] = int(st.get("comandante", 0))
	s["pipeline"] = int(st.get("pipeline", 0))
	s["coprifuoco_tot"] = int(D.get("coprifuoco", 0))
	s["nv_tot"] = int(D.get("nuovi_villaggi", 0))
	s["borsa"] = [0, 0, 0, 1, 1, 1, 2, 2, 2]
	s["intel"] = []
	s["cap"] = {}
	s["tmp"] = {}
	s["primo"] = st["primo"]
	s["scelte"] = {}
	s["carta"] = ""
	s["mazzo"] = _costruisci_mazzo(opzioni.get("lungo", false))
	s["giocate"] = []
	s["prop_fatte"] = 0
	s["prop_tot"] = 3
	s["fine"] = {}
	s["coda"] = []
	for id in ordine:
		_aggiorna_controllo(id, false)
	_pesca_carta()


func _rand(n: int) -> int:
	s["rs"] = (int(s["rs"]) * 48271) % 2147483647
	return int(s["rs"]) % n


func dado() -> int:
	return 1 + _rand(6)


func _mescola(a: Array) -> Array:
	var b := a.duplicate()
	for i in range(b.size() - 1, 0, -1):
		var j := _rand(i + 1)
		var t = b[i]
		b[i] = b[j]
		b[j] = t
	return b


func _costruisci_mazzo(lungo: bool) -> Array:
	var eventi: Array = []
	var prop: Array = []
	for c in D.get("carte", []):
		if c.get("propaganda", false):
			prop.append(c["id"])
		else:
			eventi.append(c["id"])
	eventi = _mescola(eventi)
	var mazzo: Array = []
	var per_pila = 8 if lungo else 6
	var sotto = 4 if lungo else 2
	var k := 0
	for i in 3:
		var pila: Array = eventi.slice(k, k + per_pila)
		k += per_pila
		var basso: Array = pila.slice(4, 4 + sotto)
		basso.append(prop[i])
		basso = _mescola(basso)
		mazzo += pila.slice(0, 4) + basso
	if lungo:
		s["prop_tot"] = 3
	return mazzo


func carta_dati(id: String) -> Dictionary:
	for c in D.get("carte", []):
		if c["id"] == id:
			return c
	return {}


# ---------------------------------------------------------------- domande

## Pone una domanda alla fazione f. opzioni: Array di {v, t} (valore, testo). Restituisce il valore scelto
## o null se manca la risposta (allora need è impostato e la procedura deve fermarsi: controllare ferma()).
func chiedi(f: String, testo: String, opzioni: Array, extra: Dictionary = {}):
	if need != null:
		return null
	if opzioni.is_empty():
		return null
	if opzioni.size() == 1 and extra.get("auto", true) and not extra.get("mostra", false):
		return opzioni[0]["v"]
	if _i < _ans.size():
		var v = _ans[_i]
		if v is float and v == floor(v):
			v = int(v)
		_i += 1
		for o in opzioni:
			if str(o["v"]) == str(v):
				return o["v"]
		if not autorisposta.is_valid():
			push_warning("risposta non valida: %s per %s" % [str(v), testo])
		_ans.resize(_i - 1)
		_i -= 1
	var q := {"f": f, "testo": testo, "opz": opzioni, "x": extra}
	if autorisposta.is_valid():
		var w = autorisposta.call(self, q)
		_ans.append(w)
		_i += 1
		return w
	need = q
	return null


func ferma() -> bool:
	return need != null


func o(v, t: String) -> Dictionary:
	return {"v": v, "t": t}


func si_no(f: String, testo: String, tag: String = "") -> bool:
	var v = chiedi(f, testo, [o("si", "Sì"), o("no", "No")], {"tag": tag})
	return v == "si"


func numero(f: String, testo: String, minn: int, maxn: int, tag: String = "", extra: Dictionary = {}) -> int:
	if maxn <= minn:
		return maxn
	var ops: Array = []
	for i in range(minn, maxn + 1):
		ops.append(o(i, str(i)))
	var x := {"tag": tag, "num": true}
	x.merge(extra)
	var v = chiedi(f, testo, ops, x)
	return 0 if v == null else int(v)


## Sceglie uno spazio fra quelli che soddisfano filtro; con facoltativo=true c'è anche "fine".
func scegli_spazio(f: String, testo: String, filtro: Callable, facoltativo: bool = false, tag: String = "", testo_fine: String = "Fine"):
	var ops: Array = []
	for id in ordine:
		if filtro.call(id):
			ops.append(o(id, nome_sp(id)))
	if ops.is_empty():
		return null
	if facoltativo:
		ops.append(o("fine", testo_fine))
	var v = chiedi(f, testo, ops, {"tag": tag, "spazi": true})
	if v == null or v == "fine":
		return null
	return v


## Sceglie fino a maxn spazi diversi (uno alla volta).
func scegli_spazi(f: String, testo: String, filtro: Callable, maxn: int, minn: int = 0, tag: String = "") -> Array:
	var scelti: Array = []
	while scelti.size() < maxn:
		var v = scegli_spazio(f, testo + " (%d/%d)" % [scelti.size() + 1, maxn], func(id): return not (id in scelti) and filtro.call(id), scelti.size() >= minn, tag)
		if ferma() or v == null:
			break
		scelti.append(v)
	return scelti


# ---------------------------------------------------------------- pezzi e segnalini

func X(id: String) -> Dictionary:
	return s["sp"][id]


func tipo(id: String) -> String:
	return SP[id]["tipo"]


func ins_n(id: String) -> int:
	var x = X(id)
	return int(x["u"]) + int(x["a"]) + int(x["b"])


func gue(id: String) -> int:
	return int(X(id)["u"]) + int(X(id)["a"])


func cubi(id: String) -> int:
	return int(X(id)["t"]) + int(X(id)["p"])


func brit_n(id: String) -> int:
	return cubi(id)


func disp(k: String) -> int:
	return int(s["disp"][k])


## Piazza n pezzi (k: t, p, g = Guerriglia/Cellula clandestina, b) dagli Disponibili. Restituisce quanti piazzati.
func piazza(id: String, k: String, n: int, da_mappa_ok: bool = true) -> int:
	var fatti := 0
	for i in n:
		if k == "b":
			if int(X(id)["b"]) >= 2 or not base_ok(id):
				break
		if k in ["t", "p"] and not brit_ok(id):
			break
		var dk = "g" if k == "g" else k
		if disp(dk) > 0:
			s["disp"][dk] = disp(dk) - 1
		elif da_mappa_ok and not cellule() and _prendi_da_mappa(id, k):
			pass
		else:
			break
		X(id)["u" if k == "g" else k] = int(X(id)["u" if k == "g" else k]) + 1
		fatti += 1
	if fatti > 0:
		_dopo(id)
	return fatti


## Malesia/Kenya: se un pezzo non è Disponibile lo si può prendere dalla mappa (1.4.1).
func _prendi_da_mappa(dest: String, k: String) -> bool:
	if ferma():
		return false
	var f = "brit" if k in ["t", "p"] else "ins"
	var chiavi := ["u", "a"] if k == "g" else [k]
	var cand := func(id):
		if id == dest:
			return false
		for c in chiavi:
			if int(X(id)[c]) > 0:
				return true
		return false
	var da = scegli_spazio(f, "Nessun pezzo disponibile: da dove prendi 1 %s?" % nome_pezzo(k), cand, true, "prendi", "Non piazzare")
	if da == null:
		return false
	for c in chiavi:
		if int(X(da)[c]) > 0:
			X(da)[c] = int(X(da)[c]) - 1
			_dopo(da)
			return true
	return false


func base_ok(id: String) -> bool:
	var t := tipo(id)
	if s["gioco"] == "palestina":
		return t != "ferrovia"
	if s["gioco"] == "cipro":
		return t != "base"
	if s["gioco"] == "malesia":
		return t != "ec"
	return true


func brit_ok(id: String) -> bool:
	return tipo(id) != "thai"


## Rimuove n pezzi di tipo k ("t","p","u","a","b"); dest: "disp", "prigione", "fuori".
func rimuovi(id: String, k: String, n: int, dest: String = "disp") -> int:
	var fatti: int = min(n, int(X(id)[k]))
	if fatti <= 0:
		return 0
	X(id)[k] = int(X(id)[k]) - fatti
	var dk = "g" if k in ["u", "a"] else k
	if dest == "prigione" and dk == "g":
		s["prigione"] = int(s["prigione"]) + fatti
	elif dest == "fuori":
		if dk == "p":
			s["fuori"] = int(s["fuori"]) + fatti
		else:
			s["fuori_g"] = int(s["fuori_g"]) + fatti
	else:
		s["disp"][dk] = disp(dk) + fatti
	_dopo(id)
	return fatti


## Rimuove n Cellule/Guerriglie preferendo le Attive (o le clandestine se prima_clandestine).
func rimuovi_g(id: String, n: int, dest: String = "disp", prima_clandestine: bool = false) -> int:
	var tot := 0
	for k in (["u", "a"] if prima_clandestine else ["a", "u"]):
		if tot < n:
			tot += rimuovi(id, k, n - tot, dest)
	return tot


func muovi(da: String, a: String, k: String, n: int) -> int:
	var m: int = min(n, int(X(da)[k]))
	if m <= 0:
		return 0
	X(da)[k] = int(X(da)[k]) - m
	X(a)[k] = int(X(a)[k]) + m
	_dopo(da)
	_dopo(a)
	return m


func attiva(id: String, n: int) -> int:
	var m: int = min(n, int(X(id)["u"]))
	X(id)["u"] = int(X(id)["u"]) - m
	X(id)["a"] = int(X(id)["a"]) + m
	return m


func clandestine(id: String, n: int = 99) -> int:
	var m: int = min(n, int(X(id)["a"]))
	X(id)["a"] = int(X(id)["a"]) - m
	X(id)["u"] = int(X(id)["u"]) + m
	return m


## Dopo ogni cambiamento in uno spazio: Coprifuoco senza Britannici, Controllo, Nuovi Villaggi.
func _dopo(id: String) -> void:
	var x = X(id)
	if cellule():
		if int(x["cf"]) > 0 and cubi(id) == 0:
			x["cf"] = 0
	else:
		_aggiorna_controllo(id, true)
		if s["gioco"] == "malesia" and int(x["nv"]) > 0:
			if (x["ctrl"] == "brit" and int(x["sup"]) > 0 and ins_n(id) == 0) or (ins_n(id) > 0 and cubi(id) == 0):
				x["nv"] = 0
				nota("Il Nuovo Villaggio in %s viene rimosso." % nome_sp(id))


func controllabile(id: String) -> bool:
	if cellule():
		return false
	return tipo(id) != "ec"


func _aggiorna_controllo(id: String, effetti: bool) -> void:
	if not controllabile(id):
		return
	var x = X(id)
	var b := cubi(id)
	var i := ins_n(id)
	var nuovo = "brit" if b > i else ("ins" if i > b else "")
	var vecchio: String = x["ctrl"]
	if nuovo == vecchio:
		return
	x["ctrl"] = nuovo
	if effetti:
		var pop := popolazione(id)
		if nuovo == "ins" and pop > 0:
			cambia_pw(-pop, "%s passa sotto Controllo %s" % [nome_sp(id), nome_faz("ins")])
		elif vecchio == "ins" and pop > 0:
			cambia_pw(pop, "%s non è più sotto Controllo %s" % [nome_sp(id), nome_faz("ins")])


func popolazione(id: String) -> int:
	return int(X(id).get("pop", SP[id].get("pop", 0)))


func cambia_pw(d: int, motivo: String = "") -> void:
	if d == 0:
		return
	var v: int = clamp(int(s["pw"]) + d, 0, int(s["pw_max"]))
	if v == int(s["pw"]):
		return
	s["pw"] = v
	nota("Volontà Politica %s%d%s: ora %d" % ["+" if d > 0 else "", d, (" (" + motivo + ")") if motivo != "" else "", v])


func cambia_ris(f: String, d: int) -> void:
	var v: int = clamp(int(s["ris"][f]) + d, 0, 20)
	if v != int(s["ris"][f]):
		s["ris"][f] = v
		nota("Risorse %s %s%d: ora %d" % [nome_faz(f), "+" if d > 0 else "", d, v])


## Sposta il Supporto/Lealtà (d=+1) o Opposizione/Resistenza (d=-1).
func sposta_sup(id: String, d: int) -> void:
	if not puo_sup(id):
		return
	var v: int = clamp(int(X(id)["sup"]) + d, -1, 1)
	X(id)["sup"] = v
	_dopo(id)


func set_sup(id: String, v: int) -> void:
	if not puo_sup(id):
		return
	X(id)["sup"] = v
	_dopo(id)


func puo_sup(id: String) -> bool:
	if cellule():
		return false
	var t := tipo(id)
	if s["gioco"] == "malesia":
		return t in ["prov_m", "prov_g", "kl"]
	return t != "giungla" and popolazione(id) > 0


func nome_sup(v: int) -> String:
	if s["gioco"] == "kenya":
		return ["Resistenza", "Neutrale", "Lealtà"][v + 1]
	return ["Opposizione", "Neutrale", "Supporto"][v + 1]


# ---------------------------------------------------------------- Intel

func pesca_intel(n: int = 1) -> void:
	for i in n:
		var b: Array = s["borsa"]
		if b.is_empty():
			return
		var j := _rand(b.size())
		var v: int = b[j]
		b.remove_at(j)
		s["intel"].append(v)
		nota("I Britannici pescano un Intel di valore %d." % v)


func scarta_intel(v: int) -> void:
	var a: Array = s["intel"]
	var j := a.find(v)
	if j >= 0:
		a.remove_at(j)
		s["borsa"].append(v)


func intel_tot() -> int:
	var t := 0
	for v in s["intel"]:
		t += int(v)
	return t


# ---------------------------------------------------------------- capacità e varie

func cap(id: String) -> String:
	return str(s["cap"].get(id, ""))


func fine_partita(vincitore: String, motivo: String) -> void:
	s["fine"] = {"v": vincitore, "m": motivo}
	s["coda"] = []
	nota("FINE PARTITA: " + motivo)


func finita() -> bool:
	return not s["fine"].is_empty()


# ---------------------------------------------------------------- sequenza di gioco

func secondo() -> String:
	return "ins" if s["primo"] == "brit" else "brit"


func altra(f: String) -> String:
	return "ins" if f == "brit" else "brit"


func _pesca_carta() -> void:
	if finita():
		return
	if (s["mazzo"] as Array).is_empty():
		fine_partita("pareggio", "Mazzo esaurito.")
		return
	var c: String = s["mazzo"].pop_front()
	s["carta"] = c
	s["giocate"].append(c)
	s["scelte"] = {}
	var cd := carta_dati(c)
	if cd.get("propaganda", false):
		s["prop_fatte"] = int(s["prop_fatte"]) + 1
		nota("— Carta Propaganda (%d di %d) —" % [int(s["prop_fatte"]), int(s["prop_tot"])])
		s["coda"] = [{"t": "prop", "f": "", "passo": "inizio"}]
	else:
		nota("— Carta: %s —" % cd.get("titolo", c))
		s["coda"] = [{"t": "turno", "f": s["primo"]}]


func atto_corrente() -> Dictionary:
	if finita() or (s["coda"] as Array).is_empty():
		return {}
	return s["coda"][0]


## Esegue l'atto in testa alla coda con le risposte date. Restituisce true se l'atto è concluso
## (allora lo stato avanza fino al prossimo atto che richiede decisioni).
func esegui(risposte: Array) -> bool:
	_ans = risposte.duplicate()
	_i = 0
	need = null
	registro = []
	var a := atto_corrente()
	if a.is_empty():
		return true
	_esegui_atto(a)
	if ferma():
		return false
	s["coda"].pop_front()
	s["atto_n"] = int(s["atto_n"]) + 1
	_avanza()
	return true


func _avanza() -> void:
	while not finita():
		if not (s["coda"] as Array).is_empty():
			var a: Dictionary = s["coda"][0]
			if a["t"] == "prop" and a["f"] == "":
				call("prop_" + a["passo"])
				s["coda"].pop_front()
				continue
			return
		_fine_carta()


func _fine_carta() -> void:
	var cd = carta_dati(s["carta"])
	if not cd.get("propaganda", false):
		# idoneità: chi sta nella casella più a sinistra diventa primo
		for b in CASELLE:
			if s["scelte"].has(b):
				s["primo"] = s["scelte"][b]
				break
		s["tmp"].erase("passa_forzato_usato")
	_pesca_carta()


func _esegui_atto(a: Dictionary) -> void:
	match a["t"]:
		"turno":
			_turno(a["f"])
			if not ferma() and (s["scelte"] as Dictionary).size() == 1 and not finita():
				accoda([{"t": "turno", "f": altra(a["f"])}])
		"prop":
			call("prop_" + a["passo"])
		_:
			if has_method("atto_" + a["t"]):
				call("atto_" + a["t"], a)


func _turno(f: String) -> void:
	var primo: bool = s["scelte"].is_empty()
	var cd = carta_dati(s["carta"])
	var opts: Array = []
	var lab := {"limitata": "Operazione Limitata", "evento": "Evento", "opsa": "Operazione + Attività Speciale"}
	for b in CASELLE:
		if not s["scelte"].has(b):
			opts.append(o(b, lab[b]))
	var forzato: bool = s["tmp"].get("passa_forzato", "") == f
	var b = chiedi(f, "%s: scegli una casella del tracciato dell'Iniziativa" % nome_faz(f), opts, {"tag": "casella", "mostra": true})
	if ferma():
		return
	s["scelte"][b] = f
	var azione = "passa"
	if forzato:
		nota("%s devono passare (evento)." % nome_faz(f))
		s["tmp"].erase("passa_forzato")
	else:
		var opz2: Array = [o("esegui", "Esegui: " + lab[b]), o("passa", "Passa (" + testo_passa(f) + ")")]
		azione = chiedi(f, "Eseguire l'azione o passare?", opz2, {"tag": "esegui", "mostra": true})
		if ferma():
			return
	nota("%s: %s%s" % [nome_faz(f), lab[b], "" if azione == "esegui" else " — passano"])
	if azione == "passa":
		if not forzato:
			passa(f)
		return
	match b:
		"limitata":
			operazione(f, true, false)
		"opsa":
			operazione(f, false, true)
		"evento":
			evento(f, cd)


func testo_passa(f: String) -> String:
	match s["gioco"]:
		"palestina":
			return "pesca 1 Intel" if f == "brit" else "Rapina in 1 spazio"
		"cipro":
			return "pesca 1 Intel" if f == "brit" else "Imboscata in 1 spazio"
		"malesia":
			return "+2 Risorse" if f == "brit" else "+1 Risorsa"
		"kenya":
			return "sposta la Pipeline di 1" if f == "brit" else "+1 Risorsa"
	return ""


func passa(f: String) -> void:
	match s["gioco"]:
		"palestina", "cipro":
			if f == "brit":
				pesca_intel(1)
			else:
				var op = "rob" if s["gioco"] == "palestina" else "ambush"
				if si_no(f, "Vuoi eseguire %s in 1 spazio?" % ("una Rapina" if op == "rob" else "un'Imboscata"), "passa_op"):
					call("op_" + op, f, {"limitata": true, "max": 1, "passaggio": true})
		"malesia":
			cambia_ris(f, 2 if f == "brit" else 1)
		"kenya":
			if f == "brit":
				var v = chiedi(f, "Pipeline: in che direzione la sposti?", [o(-1, "A sinistra (-1)"), o(0, "Non spostare"), o(1, "A destra (+1)")], {"tag": "pipeline"})
				if not ferma():
					sposta_pipeline(int(v))
			else:
				cambia_ris(f, 1)


func sposta_pipeline(d: int) -> void:
	var v: int = clamp(int(s["pipeline"]) + d, 0, 4)
	if v != int(s["pipeline"]):
		s["pipeline"] = v
		nota("Pipeline: ora %d (%s)" % [v, ["Stato di diritto", "Poteri d'emergenza", "Villaggizzazione", "Sistema carcerario", "Gulag"][v]])


# Ridefinite nelle classi derivate.
func operazione(_f: String, _limitata: bool, _con_sa: bool) -> void:
	pass


func evento(_f: String, _cd: Dictionary) -> void:
	pass


## Inserisce atti subito dopo quello in corso (che verrà tolto dalla coda).
func accoda(lista: Array) -> void:
	var c: Array = s["coda"]
	for i in lista.size():
		c.insert(1 + i, lista[i])


func prop_inizio() -> void:
	pass


# ---------------------------------------------------------------- utilità

## Riesegue l'atto corrente partendo da una copia dello stato base.
func prova(base: Dictionary, risposte: Array) -> bool:
	s = base.duplicate(true)
	return esegui(risposte)


## Risposte effettivamente usate dall'ultimo esegui (comprese quelle date dall'autorisposta).
func risposte_usate() -> Array:
	return _ans.slice(0, _i)


func clona() -> Nucleo:
	var m = get_script().new()
	m.D = D
	m.SP = SP
	m.ordine = ordine
	m.s = s.duplicate(true)
	return m


## Ricostruisce una partita da seme e registro delle risposte (un Array di Array per atto).
static func ricostruisci(script: Script, gioco_id: String, seme: int, opz: Dictionary, atti: Array) -> Nucleo:
	var m = script.new()
	m.nuova(gioco_id, seme, opz)
	for r in atti:
		m.esegui(r)
	return m
