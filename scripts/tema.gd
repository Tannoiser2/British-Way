## Aspetto dell'interfaccia: "dispaccio coloniale" — blu della Corona, rosso degli insorti, carta d'archivio.
## Stessa struttura della GUI COIN di Cuba Libre (barra in alto, mappa, pannello azione a destra, registro in basso).
class_name Tema
extends RefCounted

const BG := Color("0e1b26")
const BAR := Color("101c2c")
const BAR_LINE := Color("2c3b52")
const PAPER := Color("efe4cb")
const PAPER_DARK := Color("e2d3ae")
const PAPER_EDGE := Color("b9a67c")
const INK := Color("2a2118")
const INK_DIM := Color("5e5140")
const INK_FAINT := Color("8f8064")
const NAVY := Color("1f3566")
const NAVY_HI := Color("2f4f8f")
const RED := Color("b23a26")
const RED_DARK := Color("5a170e")
const GOLD := Color("c9a24a")
const GOLD_HI := Color("f0cf6e")
const TEXT := Color("efe4cb")
const TEXT_DIM := Color("aab3c0")
const LOG_BG := Color("16232f")
const OK_INK := Color("1f6b3a")

const FAZ := {"brit": Color("2b4f9a"), "ins": Color("b23a26")}

const FONT_DIR := "res://assets/fonts/"
static var _f: Dictionary = {}


static func _font(file: String, peso: int = 0) -> Font:
	var k := file + str(peso)
	if not _f.has(k):
		var base: Font = load(FONT_DIR + file) if ResourceLoader.exists(FONT_DIR + file) else ThemeDB.fallback_font
		if peso > 0 and base is FontFile:
			var v := FontVariation.new()
			v.base_font = base
			v.variation_opentype = {"wght": peso}
			_f[k] = v
		else:
			_f[k] = base
	return _f[k]


## EB Garamond: titoli, come sul tabellone.
static func titolo() -> Font: return _font("EBGaramond.ttf", 600)
static func serif() -> Font: return _font("EBGaramond.ttf", 0)
static func serif_it() -> Font: return _font("EBGaramond-Italic.ttf", 0)
static func maiuscoletto() -> Font: return _font("CormorantSC-Bold.ttf")
## Barlow Condensed: interfaccia (come i testi delle carte).
static func ui() -> Font: return _font("BarlowCondensed-Regular.ttf")
static func ui_med() -> Font: return _font("BarlowCondensed-Medium.ttf")
static func ui_bold() -> Font: return _font("BarlowCondensed-SemiBold.ttf")
static func ui_heavy() -> Font: return _font("BarlowCondensed-Bold.ttf")
static func ui_it() -> Font: return _font("BarlowCondensed-Italic.ttf")


static func box(bg: Color, border: Color, bw: int = 1, radius: int = 3, m: float = 8.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.set_border_width_all(bw)
	s.border_color = border
	s.content_margin_left = m + 2
	s.content_margin_right = m + 2
	s.content_margin_top = m * 0.5
	s.content_margin_bottom = m * 0.5
	return s


static func carta(m: float = 12.0) -> StyleBoxFlat:
	var s := box(PAPER, Color("cbb98e"), 1, 3, m)
	s.content_margin_top = m
	s.content_margin_bottom = m
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 6
	s.shadow_offset = Vector2(0, 3)
	return s


static func tema() -> Theme:
	var t := Theme.new()
	t.default_font = ui()
	t.default_font_size = 17
	t.set_color("font_color", "Label", TEXT)
	t.set_stylebox("normal", "Button", box(Color("1a283b"), Color("3e5274")))
	t.set_stylebox("hover", "Button", box(Color("24375a"), GOLD))
	t.set_stylebox("pressed", "Button", box(Color("0d1624"), GOLD))
	t.set_stylebox("disabled", "Button", box(Color("141e2b"), Color("26324a")))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", GOLD_HI)
	t.set_color("font_pressed_color", "Button", GOLD_HI)
	t.set_color("font_disabled_color", "Button", Color("5d6a7d"))
	t.set_font("font", "Button", ui_bold())
	t.set_font_size("font_size", "Button", 18)
	t.set_stylebox("panel", "PanelContainer", carta())
	t.set_stylebox("normal", "LineEdit", box(Color("f6eedb"), PAPER_EDGE, 1, 3, 8))
	t.set_stylebox("focus", "LineEdit", box(Color("fbf5e6"), GOLD, 2, 3, 8))
	t.set_color("font_color", "LineEdit", INK)
	t.set_font_size("font_size", "LineEdit", 20)
	t.set_stylebox("panel", "PopupPanel", carta(16))
	t.set_stylebox("panel", "AcceptDialog", carta(16))
	t.set_color("font_color", "RichTextLabel", TEXT)
	t.set_font("normal_font", "RichTextLabel", ui())
	t.set_font("bold_font", "RichTextLabel", ui_bold())
	t.set_font("italics_font", "RichTextLabel", ui_it())
	t.set_font_size("normal_font_size", "RichTextLabel", 16)
	t.set_font_size("bold_font_size", "RichTextLabel", 16)
	t.set_font_size("italics_font_size", "RichTextLabel", 16)
	t.set_stylebox("grabber", "VScrollBar", box(Color("3e5274"), Color("3e5274"), 0, 3, 2))
	t.set_stylebox("scroll", "VScrollBar", box(Color(0, 0, 0, 0.15), Color(0, 0, 0, 0), 0, 3, 2))
	return t


## Tasto su carta (pannello azione).
static func tasto_carta(b: Button, primario: bool = false, colore: Color = NAVY) -> void:
	if primario:
		b.add_theme_stylebox_override("normal", box(colore, colore.darkened(0.4), 1, 3))
		b.add_theme_stylebox_override("hover", box(colore.lightened(0.12), GOLD, 2, 3))
		b.add_theme_stylebox_override("pressed", box(colore.darkened(0.2), GOLD, 2, 3))
		b.add_theme_color_override("font_color", Color.WHITE)
		b.add_theme_color_override("font_hover_color", Color.WHITE)
	else:
		b.add_theme_stylebox_override("normal", box(Color("f7efdb"), Color("8d7a55"), 1, 3))
		b.add_theme_stylebox_override("hover", box(Color("fff7e4"), colore, 2, 3))
		b.add_theme_stylebox_override("pressed", box(PAPER_DARK, colore, 2, 3))
		b.add_theme_stylebox_override("disabled", box(Color("e6dcc4"), Color("c5b590"), 1, 3))
		b.add_theme_color_override("font_color", INK)
		b.add_theme_color_override("font_hover_color", colore.darkened(0.2))
		b.add_theme_color_override("font_pressed_color", INK)
		b.add_theme_color_override("font_disabled_color", INK_FAINT)
