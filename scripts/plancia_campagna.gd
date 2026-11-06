## Plancia «End of Empire»: disegna la mappa della campagna con i segnalini di Prestigio, Politica ed esiti.
## Le coordinate sono quelle dell'immagine originale (1534x1190), scalate nel riquadro disponibile.
class_name PlanciaCampagna
extends Control

signal gioco_cliccato(g: String)

const DIM := Vector2(1534, 1190)
const RIQUADRI := {
	"palestina": Rect2(453, 233, 100, 100),
	"malesia": Rect2(920, 488, 102, 102),
	"kenya": Rect2(433, 512, 104, 101),
	"cipro": Rect2(342, 172, 102, 101),
}
const POLITICHE := {"firm": Rect2(50, 897, 108, 108), "stay": Rect2(537, 897, 108, 108), "concessions": Rect2(1024, 897, 108, 108)}

var tex: Texture2D = preload("res://assets/mappe/campagna.webp")
## storia: Array di {g, esito, politica, p0, p1}; prestigio: int; prossimo: String ("" a campagna finita)
var storia: Array = []
var prestigio := 13
var prossimo := ""
var _t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)


func imposta(st: Array, p: int, pross: String) -> void:
	storia = st
	prestigio = p
	prossimo = pross
	queue_redraw()


func _process(delta: float) -> void:
	if visible and prossimo != "":
		_t += delta
		queue_redraw()


func _area() -> Rect2:
	var s: float = min(size.x / DIM.x, size.y / DIM.y)
	var w := DIM * s
	return Rect2((size - w) * 0.5, w)


func _r(r: Rect2) -> Rect2:
	var a := _area()
	var k := a.size.x / DIM.x
	return Rect2(a.position + r.position * k, r.size * k)


func _p(v: Vector2) -> Vector2:
	var a := _area()
	return a.position + v * (a.size.x / DIM.x)


func _k() -> float:
	return _area().size.x / DIM.x


func _draw() -> void:
	draw_texture_rect(tex, _area(), false)
	var k := _k()
	var f := Tema.ui_heavy()
	var fm := Tema.ui_med()
	# esiti delle partite giocate
	for e in storia:
		var r := _r(RIQUADRI[e["g"]])
		var buono: bool = e["esito"] in ["influenza", "uscita"]
		var col := Tema.NAVY if buono else Tema.RED
		var timbro := Rect2(r.position + Vector2(4, r.size.y * 0.36), Vector2(r.size.x - 8, r.size.y * 0.56))
		draw_rect(timbro, Color(Tema.PAPER, 0.94))
		draw_rect(timbro, col, false, max(2.0, 3 * k))
		var d := int(e["p1"]) - int(e["p0"])
		_testo(Campagna.NOMI_ESITO[e["esito"]].to_upper(), f, 22 * k, col, timbro.position + Vector2(timbro.size.x / 2, timbro.size.y * 0.36))
		_testo("Prestigio %+d" % d if d != 0 else "Prestigio ±0", fm, 17 * k, Tema.INK, timbro.position + Vector2(timbro.size.x / 2, timbro.size.y * 0.75))
	# prossima partita
	if prossimo != "":
		var r := _r(RIQUADRI[prossimo]).grow(5 * k)
		var a := 0.55 + 0.45 * sin(_t * 3.0)
		draw_rect(r, Color(Tema.GOLD_HI, a), false, max(3.0, 6 * k))
		var lab := Rect2(r.position + Vector2(0, r.size.y + 2 * k), Vector2(r.size.x, 26 * k))
		draw_rect(lab, Tema.GOLD_HI)
		_testo("PROSSIMA", f, 18 * k, Tema.INK, lab.get_center())
	# politica dell'ultima partita
	if not storia.is_empty():
		var pol: String = storia[-1]["politica"]
		var r := _r(POLITICHE[pol]).grow(3 * k)
		draw_rect(r, Tema.GOLD_HI, false, max(3.0, 6 * k))
	# segnalino del Prestigio imperiale
	var c := _p(Vector2(95 + clamp(prestigio, 0, 15) * 88.36, 1093))
	var rad := 30 * k
	draw_circle(c + Vector2(3, 4) * k, rad, Color(0, 0, 0, 0.45))
	draw_circle(c, rad, Color("e9dcb4"))
	draw_arc(c, rad, 0, TAU, 40, Tema.GOLD, max(2.0, 4 * k), true)
	_testo(str(prestigio), Tema.titolo(), 34 * k, Tema.INK, c + Vector2(0, -2 * k))
	_testo("PRESTIGIO", f, 11 * k, Tema.INK, c + Vector2(0, 18 * k))


func _testo(t: String, fo: Font, px: float, col: Color, centro: Vector2) -> void:
	var sz := int(max(8.0, px))
	var w := fo.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, sz)
	draw_string(fo, centro + Vector2(-w.x / 2, fo.get_ascent(sz) / 2 - fo.get_descent(sz) / 2), t, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, col)


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		for g in RIQUADRI:
			if _r(RIQUADRI[g]).has_point(e.position):
				gioco_cliccato.emit(g)
				return
