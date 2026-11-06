## Vista della mappa: tabellone originale, pezzi di legno disegnati, segnalini, spazi selezionabili.
## Rotella o +/− per lo zoom, trascinamento per spostare, click sugli spazi evidenziati per sceglierli.
class_name MappaView
extends Control

signal spazio_cliccato(id: String)
signal spazio_sopra(id: String)

var m: Motore
var tex: Texture2D
var zoom := 1.0
var off := Vector2.ZERO
var candidati: Array = []
var selezionati: Array = []
var sopra := ""
var _trascina := false
var _press_pos := Vector2.ZERO
var _t := 0.0
var _seg: Dictionary = {}
var _pronto := false
var ultimo_cambiato: Dictionary = {}   # id -> tempo, per un breve lampeggio

const COL_TRUPPA := Color("d9c9a3")
const COL_POLIZIA := Color("3f8fd0")
const COL_CELLULA := Color("c0392b")
const COL_BASE := Color("a8301f")


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	for n in ["sabotaggio", "terrore", "coprifuoco", "nuovo_villaggio", "supporto", "opposizione", "lealta", "resistenza",
			"controllo_brit", "controllo_mcp", "controllo_brit_k", "controllo_maumau", "volonta", "pop0", "pop1"]:
		_seg[n] = load("res://assets/segnalini/%s.png" % n)
	resized.connect(adatta)


func imposta(motore: Motore) -> void:
	m = motore
	tex = load("res://assets/mappe/%s.webp" % m.gioco())
	_pronto = false
	adatta()


func adatta() -> void:
	if tex == null or size.x < 10:
		return
	var ts := tex.get_size()
	zoom = min(size.x / ts.x, size.y / ts.y)
	off = (size - ts * zoom) * 0.5
	_pronto = true
	queue_redraw()


func zoom_a(z: float, centro: Vector2) -> void:
	if tex == null:
		return
	var ts := tex.get_size()
	var minz: float = min(size.x / ts.x, size.y / ts.y) * 0.9
	var nz: float = clamp(z, minz, minz * 4.0)
	var p := (centro - off) / zoom
	zoom = nz
	off = centro - p * zoom
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	if not candidati.is_empty() or not ultimo_cambiato.is_empty():
		queue_redraw()


func pos_spazio(id: String) -> Vector2:
	var sp: Dictionary = m.SP[id]
	var ts := tex.get_size()
	return off + Vector2(float(sp["x"]) * ts.x, float(sp["y"]) * ts.y) * zoom


func _gui_input(e: InputEvent) -> void:
	if m == null:
		return
	if e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_WHEEL_UP and e.pressed:
			zoom_a(zoom * 1.12, e.position)
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN and e.pressed:
			zoom_a(zoom / 1.12, e.position)
		elif e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed:
				_trascina = true
				_press_pos = e.position
			else:
				_trascina = false
				if e.position.distance_to(_press_pos) < 8:
					var id := spazio_a(e.position)
					if id != "":
						spazio_cliccato.emit(id)
	elif e is InputEventMouseMotion:
		if _trascina and (e.button_mask & MOUSE_BUTTON_MASK_LEFT) and e.position.distance_to(_press_pos) >= 8:
			off += e.relative
			queue_redraw()
		var id := spazio_a(e.position)
		if id != sopra:
			sopra = id
			spazio_sopra.emit(id)
			queue_redraw()
	elif e is InputEventMagnifyGesture:
		zoom_a(zoom * e.factor, e.position)
	elif e is InputEventPanGesture:
		off -= e.delta * 8.0
		queue_redraw()


## Spazio sotto il punto: prima i cerchi (Città, Basi, CE), poi il più vicino (preferendo i candidati).
func spazio_a(p: Vector2) -> String:
	if m == null or tex == null:
		return ""
	var ts := tex.get_size()
	for id in m.ordine:
		var r := float(m.SP[id].get("r", 0)) * ts.x * zoom
		if r > 0 and pos_spazio(id).distance_to(p) <= r:
			return id
	var best := ""
	var bd := 1e9
	var lim := 0.11 * ts.x * zoom
	for id in m.ordine:
		var d := pos_spazio(id).distance_to(p)
		if not candidati.is_empty() and id in candidati:
			d *= 0.7
		if d < bd and d < lim:
			bd = d
			best = id
	return best


# ---------------------------------------------------------------- disegno

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Tema.BG)
	if m == null or tex == null:
		return
	var ts := tex.get_size()
	draw_texture_rect(tex, Rect2(off, ts * zoom), false)
	var u: float = max(30.0 * zoom * (ts.x / 1700.0), 17.0)   # lato di un cubo
	_disegna_pw(u)
	if m.cellule():
		_disegna_prigione(u)
	for id in m.ordine:
		_disegna_spazio(id, u)
	# evidenziazioni
	for id in candidati:
		var c := pos_spazio(id)
		var a := 0.55 + 0.35 * sin(_t * 5.0)
		var r = max(float(m.SP[id].get("r", 0)) * ts.x * zoom, u * 2.0)
		draw_arc(c, r, 0, TAU, 48, Color(Tema.GOLD_HI, a), max(3.0, u * 0.18), true)
		draw_arc(c, r + u * 0.25, 0, TAU, 48, Color(0, 0, 0, a * 0.5), 2.0, true)
	for id in selezionati:
		draw_arc(pos_spazio(id), u * 1.6, 0, TAU, 40, Color("ffffff"), 3.0, true)
	if sopra != "":
		var p := pos_spazio(sopra)
		var f = Tema.ui_bold()
		var fs := int(clamp(u * 0.7, 13, 22))
		var nome: String = m.nome_sp(sopra)
		var w := f.get_string_size(nome, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var q := p + Vector2(-w * 0.5 - 6, -u * 2.6)
		draw_rect(Rect2(q, Vector2(w + 12, fs + 8)), Color(0.05, 0.08, 0.12, 0.85))
		draw_string(f, q + Vector2(6, fs + 1), nome, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Tema.GOLD_HI)


func _disegna_pw(u: float) -> void:
	var tr: Dictionary = m.D["pw_track"]
	var ts := tex.get_size()
	var v := int(m.s["pw"])
	var p = off + Vector2(float(tr["x0"]) + float(tr["dx"]) * v, float(tr["y0"]) + float(tr["dy"]) * v) * ts * zoom
	var t: Texture2D = _seg["volonta"]
	var lato := u * 2.0
	draw_texture_rect(t, Rect2(p - Vector2(lato, lato) * 0.5, Vector2(lato, lato)), false)
	draw_rect(Rect2(p - Vector2(lato, lato) * 0.5, Vector2(lato, lato)), Tema.GOLD_HI, false, 2.0)


func _disegna_prigione(u: float) -> void:
	var pr: Dictionary = m.D.get("prigione", {})
	if pr.is_empty():
		return
	var ts := tex.get_size()
	var p = off + Vector2(float(pr["x"]), float(pr["y"])) * ts * zoom
	var n := int(m.s["prigione"])
	if n > 0:
		_gruppo(p + Vector2(0, u * 1.2), "u", n, u)


func _disegna_spazio(id: String, u: float) -> void:
	var x: Dictionary = m.X(id)
	var c := pos_spazio(id)
	# riga britannica e riga insorta
	var righe: Array = []
	var r1: Array = []
	if int(x["t"]) > 0:
		r1.append(["t", int(x["t"])])
	if int(x["p"]) > 0:
		r1.append(["p", int(x["p"])])
	var r2: Array = []
	if int(x["u"]) > 0:
		r2.append(["u", int(x["u"])])
	if int(x["a"]) > 0:
		r2.append(["a", int(x["a"])])
	if int(x["b"]) > 0:
		r2.append(["b", int(x["b"])])
	var r3: Array = []
	for k in ["sab", "ter"]:
		if int(x[k]) > 0:
			r3.append([k, int(x[k])])
	if int(x["cf"]) > 0:
		r3.append(["cf", 1])
	if int(x["nv"]) > 0:
		r3.append(["nv", 1])
	righe = [r1, r2, r3]
	var y := c.y - u * 0.9
	for riga in righe:
		if riga.is_empty():
			continue
		var w := 0.0
		for g in riga:
			w += _larghezza(g[0], g[1], u) + u * 0.3
		var xx := c.x - w * 0.5
		for g in riga:
			var gw = _larghezza(g[0], g[1], u)
			_gruppo(Vector2(xx + gw * 0.5, y), g[0], g[1], u)
			xx += gw + u * 0.3
		y += u * 1.25
	# Controllo e Supporto (Malesia/Kenya)
	if not m.cellule():
		var lato := u * 1.3
		var q := c + Vector2(u * 1.9, -u * 2.2)
		if x["ctrl"] != "":
			var k := ""
			if m.gioco() == "malesia":
				k = "controllo_brit" if x["ctrl"] == "brit" else "controllo_mcp"
			else:
				k = "controllo_brit_k" if x["ctrl"] == "brit" else "controllo_maumau"
			draw_texture_rect(_seg[k], Rect2(q, Vector2(lato, lato)), false)
			q.x += lato + 3
		if int(x["sup"]) != 0:
			var k2 := ""
			if m.gioco() == "malesia":
				k2 = "supporto" if int(x["sup"]) > 0 else "opposizione"
			else:
				k2 = "lealta" if int(x["sup"]) > 0 else "resistenza"
			draw_texture_rect(_seg[k2], Rect2(q, Vector2(lato, lato)), false)
		if m.gioco() == "kenya" and m.SP[id]["tipo"] == "prov_r" and m.popolazione(id) < int(m.SP[id]["pop"]):
			var pk := "pop0" if m.popolazione(id) == 0 else "pop1"
			draw_texture_rect(_seg[pk], Rect2(c + Vector2(-u * 3.2, -u * 2.2), Vector2(lato, lato)), false)


func _larghezza(k: String, n: int, u: float) -> float:
	var vis: int = min(n, 3) if n <= 3 else 1
	if k in ["sab", "ter", "cf", "nv"]:
		return u * 1.3 * min(n, 2)
	return u * vis + (u * 0.15) * (vis - 1) + (u * 0.9 if n > 3 else 0.0)


func _gruppo(centro: Vector2, k: String, n: int, u: float) -> void:
	if k in ["sab", "ter", "cf", "nv"]:
		var t: Texture2D = _seg[{"sab": "sabotaggio", "ter": "terrore", "cf": "coprifuoco", "nv": "nuovo_villaggio"}[k]]
		var lato := u * 1.25
		var vis: int = min(n, 2)
		var x0 := centro.x - (lato * vis) * 0.5
		for i in vis:
			draw_texture_rect(t, Rect2(Vector2(x0 + i * lato, centro.y - lato * 0.5), Vector2(lato - 2, lato - 2)), false)
		if n > 2:
			_numero(Vector2(x0 + lato * vis, centro.y), n, u)
		return
	var vis2: int = n if n <= 3 else 1
	var tot := u * vis2 + u * 0.15 * (vis2 - 1)
	var x := centro.x - tot * 0.5 - (u * 0.45 if n > 3 else 0.0) + u * 0.5
	for i in vis2:
		_pezzo(Vector2(x, centro.y), k, u)
		x += u * 1.15
	if n > 3:
		_numero(Vector2(x - u * 0.45, centro.y), n, u)


func _numero(p: Vector2, n: int, u: float) -> void:
	var f = Tema.ui_heavy()
	var fs := int(clamp(u * 0.85, 12, 30))
	var s := "×%d" % n
	draw_string_outline(f, p + Vector2(0, fs * 0.35), s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0, 0, 0, 0.85))
	draw_string(f, p + Vector2(0, fs * 0.35), s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)


func _pezzo(c: Vector2, k: String, u: float) -> void:
	var h := u * 0.5
	match k:
		"t", "p":
			var col := COL_TRUPPA if k == "t" else COL_POLIZIA
			# cubo: faccia superiore chiara, frontale, laterale scura
			var d := u * 0.22
			var front := Rect2(c - Vector2(h, h) + Vector2(0, d * 0.5), Vector2(u - d, u - d))
			draw_rect(Rect2(front.position + Vector2(2, 3), front.size), Color(0, 0, 0, 0.35))
			draw_rect(front, col)
			draw_colored_polygon(PackedVector2Array([front.position, front.position + Vector2(d, -d), front.position + Vector2(front.size.x + d, -d), front.position + Vector2(front.size.x, 0)]), col.lightened(0.3))
			draw_colored_polygon(PackedVector2Array([front.position + Vector2(front.size.x, 0), front.position + Vector2(front.size.x + d, -d), front.position + Vector2(front.size.x + d, front.size.y - d), front.position + front.size]), col.darkened(0.3))
			draw_rect(front, col.darkened(0.45), false, 1.0)
		"u", "a":
			# cilindro ottagonale; attivo = simbolo in alto (stella chiara)
			var pts := PackedVector2Array()
			for i in 8:
				var ang := PI / 8.0 + i * TAU / 8.0
				pts.append(c + Vector2(cos(ang), sin(ang)) * h * 1.02)
			var ombra := PackedVector2Array()
			for p in pts:
				ombra.append(p + Vector2(2, 3))
			draw_colored_polygon(ombra, Color(0, 0, 0, 0.35))
			var col := COL_CELLULA if k == "a" else COL_CELLULA.darkened(0.35)
			draw_colored_polygon(pts, col)
			pts.append(pts[0])
			draw_polyline(pts, col.darkened(0.5), 1.2, true)
			if k == "a":
				_stella(c, h * 0.62, Color("ffe9c4"))
			else:
				draw_circle(c, h * 0.18, col.darkened(0.45))
		"b":
			var r := Rect2(c - Vector2(h * 1.15, h * 0.62), Vector2(h * 2.3, h * 1.24))
			_ellisse(r.get_center() + Vector2(2, 4), r.size * 0.5, Color(0, 0, 0, 0.35))
			_ellisse(r.get_center() + Vector2(0, h * 0.25), r.size * 0.5, COL_BASE.darkened(0.35))
			_ellisse(r.get_center(), r.size * 0.5, COL_BASE)


func _ellisse(c: Vector2, r: Vector2, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 28:
		var a := i * TAU / 28.0
		pts.append(c + Vector2(cos(a) * r.x, sin(a) * r.y))
	draw_colored_polygon(pts, col)


func _stella(c: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2 + i * PI / 5.0
		var rr := r if i % 2 == 0 else r * 0.42
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	draw_colored_polygon(pts, col)
