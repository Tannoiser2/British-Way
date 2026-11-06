## Schermata principale: menu iniziale e partita (mappa, pannello azione, registro).
## Gestisce chi risponde alle domande del motore: giocatore locale, IA o avversario online.
extends Control

const GIOCHI := {
	"palestina": {"nome": "Palestina", "anni": "1945–1947", "ins": "Irgun", "desc": "Irgun e Lehi contro il Mandato britannico: sabotaggi alle ferrovie, l'Haganah ago della bilancia."},
	"malesia": {"nome": "Malesia", "anni": "1948–1960", "ins": "MCP", "desc": "La guerriglia comunista nella giungla, i Nuovi Villaggi e i tre Alti Commissari."},
	"kenya": {"nome": "Kenya", "anni": "1952–1956", "ins": "Mau Mau", "desc": "La rivolta nelle Riserve kikuyu, le giungle dei monti e la \"Pipeline\" della repressione."},
	"cipro": {"nome": "Cipro", "anni": "1955–1959", "ins": "EOKA", "desc": "L'EOKA di Grivas tra città e monti, l'ONU e l'opinione internazionale."},
}
const NOMI_SA_INIZ := {"limitata": "Op. Limitata", "evento": "Evento", "opsa": "Op. + Att. Speciale"}

var m: Motore
var gioco_id := "palestina"
var seme := 0
var opz := {}
var atti: Array = []          # risposte degli atti conclusi
var base: Dictionary = {}
var ans: Array = []
var controllo := {"brit": "umano", "ins": "ia"}
var piano: Array = []
var rng := RandomNumberGenerator.new()
var registro_fisso: Array = []
var storia: Array = []        # istantanee per "Annulla": [n_atti, ans]
var occupato := false
var ia_in_corso := false
var ia_forza := 200
var rete: Rete
var online := false
var stanza := ""
var posto := -1
var net_k := 0
var net_inviati := {}
var _poll_t := 0.0

# nodi
var menu: Control
var partita: Control
var mappa: MappaView
var top_brit: PanelContainer
var top_ins: PanelContainer
var lbl_brit: Label
var lbl_ins: Label
var lbl_mazzo: Label
var btn_annulla: Button
var pannello: VBoxContainer
var banner: PanelContainer
var lbl_chi: Label
var lbl_domanda: Label
var box_opz: GridContainer
var carta_tex: TextureRect
var lbl_carta: Label
var iniz_box: HBoxContainer
var cap_box: VBoxContainer
var stato_lbl: RichTextLabel
var log_lbl: RichTextLabel
var info_lbl: Label
var fine_dlg: AcceptDialog
var carta_pop: PopupPanel
var regole_pop: AcceptDialog
var regole_txt: RichTextLabel
var carta_pop_tex: TextureRect
var menu_msg: Label
var nome_edit: LineEdit
var codice_edit: LineEdit
var sel_gioco_btns: Dictionary = {}


func _ready() -> void:
	theme = Tema.tema()
	rng.randomize()
	rete = Rete.new()
	add_child(rete)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_costruisci_menu()
	_costruisci_partita()
	partita.visible = false
	menu.visible = true
	_seleziona_gioco("palestina")


# ================================================================ MENU

func _costruisci_menu() -> void:
	menu = Control.new()
	menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(menu)
	var bg := ColorRect.new()
	bg.color = Tema.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.add_child(bg)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	menu.add_child(scroll)
	var centro := CenterContainer.new()
	centro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(centro)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	col.custom_minimum_size = Vector2(1180, 0)
	centro.add_child(col)
	var stemma := TextureRect.new()
	col.add_child(_spazio(10))
	var t := Label.new()
	t.text = "THE BRITISH WAY"
	t.add_theme_font_override("font", Tema.titolo())
	t.add_theme_font_size_override("font_size", 64)
	t.add_theme_color_override("font_color", Tema.PAPER)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)
	var st := Label.new()
	st.text = "Controinsurrezione alla fine dell'Impero · quattro giochi COIN per due giocatori"
	st.add_theme_font_override("font", Tema.serif_it())
	st.add_theme_font_size_override("font_size", 24)
	st.add_theme_color_override("font_color", Tema.GOLD)
	st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(st)
	col.add_child(_spazio(6))
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 14)
	riga.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(riga)
	for g in ["palestina", "malesia", "kenya", "cipro"]:
		var b := Button.new()
		b.custom_minimum_size = Vector2(280, 350)
		b.toggle_mode = true
		b.add_theme_stylebox_override("normal", Tema.box(Color("16243a"), Color("33496d"), 1, 4))
		b.add_theme_stylebox_override("hover", Tema.box(Color("1d2f4b"), Tema.GOLD, 2, 4))
		b.add_theme_stylebox_override("pressed", Tema.box(Color("22385c"), Tema.GOLD_HI, 3, 4))
		var v := VBoxContainer.new()
		v.set_anchors_preset(Control.PRESET_FULL_RECT)
		v.offset_left = 10
		v.offset_right = -10
		v.offset_top = 10
		v.offset_bottom = -10
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(v)
		var img := TextureRect.new()
		img.texture = load("res://assets/mappe/%s.webp" % g)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		img.custom_minimum_size = Vector2(0, 200)
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		img.clip_contents = true
		v.add_child(img)
		var n := Label.new()
		n.text = GIOCHI[g]["nome"]
		n.add_theme_font_override("font", Tema.titolo())
		n.add_theme_font_size_override("font_size", 30)
		n.add_theme_color_override("font_color", Tema.PAPER)
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(n)
		var a := Label.new()
		a.text = "%s · Britannici contro %s" % [GIOCHI[g]["anni"], GIOCHI[g]["ins"]]
		a.add_theme_color_override("font_color", Tema.GOLD)
		a.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(a)
		var d := Label.new()
		d.text = GIOCHI[g]["desc"]
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.add_theme_color_override("font_color", Tema.TEXT_DIM)
		d.add_theme_font_size_override("font_size", 15)
		d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(d)
		b.pressed.connect(_seleziona_gioco.bind(g))
		riga.add_child(b)
		sel_gioco_btns[g] = b
	col.add_child(_spazio(4))
	var pan := PanelContainer.new()
	col.add_child(pan)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 10)
	pan.add_child(pv)
	var h1 := _lbl_carta("Partita locale", 26, true)
	pv.add_child(h1)
	var r1 := HBoxContainer.new()
	r1.add_theme_constant_override("separation", 10)
	pv.add_child(r1)
	for k in [["brit", "Gioca con i Britannici contro l'IA"], ["ins", "Gioca con gli insorti contro l'IA"], ["hotseat", "Due giocatori sullo stesso schermo"], ["demo", "IA contro IA (dimostrazione)"]]:
		var b := Button.new()
		b.text = k[1]
		b.custom_minimum_size = Vector2(0, 46)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		Tema.tasto_carta(b, k[0] in ["brit", "ins"], Tema.NAVY if k[0] == "brit" else Tema.RED)
		b.pressed.connect(_nuova_locale.bind(k[0]))
		r1.add_child(b)
		if k[0] == "ins":
			b.set_meta("ins_btn", true)
	var r2 := HBoxContainer.new()
	r2.add_theme_constant_override("separation", 10)
	pv.add_child(r2)
	var bl := Button.new()
	bl.text = "Riprendi la partita salvata su questo dispositivo"
	bl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bl.custom_minimum_size = Vector2(0, 40)
	Tema.tasto_carta(bl)
	bl.pressed.connect(_riprendi_locale)
	bl.set_meta("riprendi", "locale")
	r2.add_child(bl)
	var bc := Button.new()
	bc.text = "Riprendi dal salvataggio online (Firebase)"
	bc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bc.custom_minimum_size = Vector2(0, 40)
	Tema.tasto_carta(bc)
	bc.pressed.connect(_riprendi_cloud)
	bc.set_meta("riprendi", "cloud")
	r2.add_child(bc)
	var lunga := CheckBox.new()
	lunga.text = "Malesia: scenario esteso (mazzo di 27 carte)"
	lunga.add_theme_color_override("font_color", Tema.INK)
	lunga.toggled.connect(func(v): opz["lungo"] = v)
	for sty in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
		lunga.add_theme_stylebox_override(sty, StyleBoxEmpty.new())
	lunga.add_theme_color_override("font_hover_color", Tema.NAVY)
	lunga.add_theme_color_override("font_pressed_color", Tema.INK)
	pv.add_child(lunga)
	pv.add_child(_lbl_carta("Partita online", 26, true))
	var r3 := HBoxContainer.new()
	r3.add_theme_constant_override("separation", 10)
	pv.add_child(r3)
	nome_edit = LineEdit.new()
	nome_edit.placeholder_text = "Il tuo nome"
	nome_edit.text = "Stefano"
	nome_edit.custom_minimum_size = Vector2(220, 42)
	nome_edit.add_theme_color_override("font_placeholder_color", Tema.INK_FAINT)
	r3.add_child(nome_edit)
	for k in [["brit", "Crea stanza: io Britannici"], ["ins", "Crea stanza: io insorti"]]:
		var b := Button.new()
		b.text = k[1]
		b.custom_minimum_size = Vector2(0, 42)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		Tema.tasto_carta(b)
		b.pressed.connect(_crea_stanza.bind(k[0]))
		r3.add_child(b)
	codice_edit = LineEdit.new()
	codice_edit.placeholder_text = "Codice"
	codice_edit.max_length = 4
	codice_edit.custom_minimum_size = Vector2(110, 42)
	codice_edit.add_theme_color_override("font_placeholder_color", Tema.INK_FAINT)
	r3.add_child(codice_edit)
	var be := Button.new()
	be.text = "Entra"
	be.custom_minimum_size = Vector2(110, 42)
	Tema.tasto_carta(be, true)
	be.pressed.connect(_entra_stanza)
	r3.add_child(be)
	var br2 := Button.new()
	br2.text = "Rientra nell'ultima stanza online"
	br2.custom_minimum_size = Vector2(0, 40)
	Tema.tasto_carta(br2)
	br2.pressed.connect(_rientra_stanza)
	pv.add_child(br2)
	menu_msg = _lbl_carta("", 18)
	menu_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pv.add_child(menu_msg)
	var cred := Label.new()
	cred.text = "Gioco originale di Stephen Rangazas, GMT Games (2023). Versione digitale per uso personale."
	cred.add_theme_color_override("font_color", Tema.TEXT_DIM)
	cred.add_theme_font_size_override("font_size", 14)
	cred.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(cred)


func _spazio(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


func _lbl_carta(t: String, fs: int = 18, titolo: bool = false) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_color_override("font_color", Tema.INK)
	l.add_theme_font_size_override("font_size", fs)
	if titolo:
		l.add_theme_font_override("font", Tema.titolo())
	return l


func _seleziona_gioco(g: String) -> void:
	gioco_id = g
	for k in sel_gioco_btns:
		sel_gioco_btns[k].set_pressed_no_signal(k == g)
	_aggiorna_tasti_menu()


func _aggiorna_tasti_menu() -> void:
	for b in menu.find_children("*", "Button", true, false):
		if b.has_meta("riprendi"):
			var nome: String = GIOCHI[gioco_id]["nome"]
			if b.get_meta("riprendi") == "locale":
				b.text = "Riprendi %s salvata su questo dispositivo%s" % [nome, "" if FileAccess.file_exists(_file_salva(gioco_id)) else " (nessuna)"]
				b.disabled = not FileAccess.file_exists(_file_salva(gioco_id))
			else:
				b.text = "Riprendi %s dal salvataggio online (Firebase)" % nome
		if b.has_meta("ins_btn"):
			b.text = "Gioca con %s contro l'IA" % ("l'" + GIOCHI[gioco_id]["ins"] if GIOCHI[gioco_id]["ins"] in ["Irgun", "EOKA", "MCP"] else "i " + GIOCHI[gioco_id]["ins"])


func _nuova_locale(modo: String) -> void:
	match modo:
		"brit":
			controllo = {"brit": "umano", "ins": "ia"}
		"ins":
			controllo = {"brit": "ia", "ins": "umano"}
		"hotseat":
			controllo = {"brit": "umano", "ins": "umano"}
		"demo":
			controllo = {"brit": "ia", "ins": "ia"}
	online = false
	var o2 := {}
	if gioco_id == "malesia" and opz.get("lungo", false):
		o2["lungo"] = true
	avvia(gioco_id, rng.randi() % 1000000000 + 1, o2, [])


# ================================================================ PARTITA: costruzione

func _costruisci_partita() -> void:
	partita = Control.new()
	partita.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(partita)
	var bg := ColorRect.new()
	bg.color = Tema.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	partita.add_child(bg)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 0)
	partita.add_child(v)
	# --- barra superiore
	var top := PanelContainer.new()
	top.add_theme_stylebox_override("panel", Tema.box(Tema.BAR, Tema.BAR_LINE, 0, 0, 6))
	top.custom_minimum_size = Vector2(0, 66)
	v.add_child(top)
	var th := HBoxContainer.new()
	th.add_theme_constant_override("separation", 10)
	top.add_child(th)
	var tit := VBoxContainer.new()
	tit.add_theme_constant_override("separation", -4)
	th.add_child(tit)
	var t1 := Label.new()
	t1.name = "Titolo"
	t1.text = "THE BRITISH WAY"
	t1.add_theme_font_override("font", Tema.titolo())
	t1.add_theme_font_size_override("font_size", 28)
	t1.add_theme_color_override("font_color", Tema.PAPER)
	tit.add_child(t1)
	var t2 := Label.new()
	t2.name = "Sotto"
	t2.add_theme_font_override("font", Tema.serif_it())
	t2.add_theme_font_size_override("font_size", 17)
	t2.add_theme_color_override("font_color", Tema.GOLD)
	tit.add_child(t2)
	th.add_child(_spazio_h(10))
	top_brit = _chip("brit")
	lbl_brit = top_brit.get_child(0).get_child(1)
	th.add_child(top_brit)
	top_ins = _chip("ins")
	lbl_ins = top_ins.get_child(0).get_child(1)
	th.add_child(top_ins)
	lbl_mazzo = Label.new()
	lbl_mazzo.add_theme_font_override("font", Tema.ui_bold())
	lbl_mazzo.add_theme_font_size_override("font_size", 18)
	lbl_mazzo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_mazzo.clip_text = true
	lbl_mazzo.custom_minimum_size = Vector2(150, 0)
	lbl_mazzo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	th.add_child(lbl_mazzo)
	for k in [["−", "zoom_meno"], ["+", "zoom_piu"], ["Adatta", "zoom_adatta"]]:
		var b := Button.new()
		b.text = k[0]
		b.custom_minimum_size = Vector2(40 if k[0].length() == 1 else 72, 44)
		b.pressed.connect(_zoom.bind(k[1]))
		th.add_child(b)
	btn_annulla = Button.new()
	btn_annulla.text = "Annulla"
	btn_annulla.custom_minimum_size = Vector2(96, 44)
	btn_annulla.pressed.connect(_annulla)
	th.add_child(btn_annulla)
	var br := Button.new()
	br.text = "Regole"
	br.custom_minimum_size = Vector2(84, 44)
	br.pressed.connect(_mostra_regole)
	th.add_child(br)
	var bs := Button.new()
	bs.text = "Salva online"
	bs.custom_minimum_size = Vector2(110, 44)
	bs.pressed.connect(_salva_cloud)
	th.add_child(bs)
	var bm := Button.new()
	bm.text = "Menu"
	bm.custom_minimum_size = Vector2(80, 44)
	bm.pressed.connect(_torna_menu)
	th.add_child(bm)
	# --- corpo
	var corpo := HBoxContainer.new()
	corpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	corpo.add_theme_constant_override("separation", 8)
	v.add_child(corpo)
	var sx := VBoxContainer.new()
	sx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sx.add_theme_constant_override("separation", 6)
	corpo.add_child(sx)
	var cornice := PanelContainer.new()
	cornice.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cornice.add_theme_stylebox_override("panel", Tema.box(Color("0b141d"), Tema.GOLD.darkened(0.3), 2, 2, 0))
	sx.add_child(cornice)
	mappa = MappaView.new()
	mappa.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mappa.spazio_cliccato.connect(_click_spazio)
	mappa.spazio_sopra.connect(_sopra_spazio)
	cornice.add_child(mappa)
	var basso := HBoxContainer.new()
	basso.name = "Basso"
	basso.custom_minimum_size = Vector2(0, 168)
	basso.add_theme_constant_override("separation", 6)
	sx.add_child(basso)
	var lato := VBoxContainer.new()
	lato.name = "Lato"
	lato.custom_minimum_size = Vector2(360, 0)
	lato.add_theme_constant_override("separation", 6)
	corpo.add_child(lato)
	var logp := PanelContainer.new()
	logp.name = "LogP"
	logp.add_theme_stylebox_override("panel", Tema.box(Tema.LOG_BG, Color("2c3b4d"), 1, 3, 8))
	logp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	basso.add_child(logp)
	var lv := VBoxContainer.new()
	logp.add_child(lv)
	info_lbl = Label.new()
	info_lbl.add_theme_color_override("font_color", Tema.GOLD_HI)
	info_lbl.add_theme_font_size_override("font_size", 15)
	info_lbl.clip_text = true
	lv.add_child(info_lbl)
	log_lbl = RichTextLabel.new()
	log_lbl.bbcode_enabled = true
	log_lbl.scroll_following = true
	log_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lv.add_child(log_lbl)
	var statop := PanelContainer.new()
	statop.name = "StatoP"
	statop.add_theme_stylebox_override("panel", Tema.box(Tema.LOG_BG, Color("2c3b4d"), 1, 3, 8))
	statop.custom_minimum_size = Vector2(430, 0)
	basso.add_child(statop)
	stato_lbl = RichTextLabel.new()
	stato_lbl.bbcode_enabled = true
	stato_lbl.fit_content = false
	statop.add_child(stato_lbl)
	# --- pannello azione
	var dx := PanelContainer.new()
	dx.custom_minimum_size = Vector2(430, 0)
	corpo.add_child(dx)
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	dx.add_child(sc)
	pannello = VBoxContainer.new()
	pannello.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pannello.add_theme_constant_override("separation", 8)
	sc.add_child(pannello)
	banner = PanelContainer.new()
	pannello.add_child(banner)
	var bv := VBoxContainer.new()
	banner.add_child(bv)
	lbl_chi = Label.new()
	lbl_chi.add_theme_font_override("font", Tema.ui_heavy())
	lbl_chi.add_theme_font_size_override("font_size", 24)
	lbl_chi.add_theme_color_override("font_color", Color.WHITE)
	bv.add_child(lbl_chi)
	lbl_domanda = Label.new()
	lbl_domanda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_domanda.add_theme_font_override("font", Tema.ui_med())
	lbl_domanda.add_theme_font_size_override("font_size", 19)
	lbl_domanda.add_theme_color_override("font_color", Color.WHITE)
	lbl_domanda.custom_minimum_size = Vector2(380, 0)
	bv.add_child(lbl_domanda)
	box_opz = GridContainer.new()
	box_opz.columns = 1
	box_opz.add_theme_constant_override("h_separation", 6)
	box_opz.add_theme_constant_override("v_separation", 6)
	pannello.add_child(box_opz)
	pannello.add_child(_titoletto("Iniziativa"))
	iniz_box = HBoxContainer.new()
	iniz_box.add_theme_constant_override("separation", 4)
	pannello.add_child(iniz_box)
	pannello.add_child(_titoletto("Carta in gioco"))
	carta_tex = TextureRect.new()
	carta_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	carta_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	carta_tex.custom_minimum_size = Vector2(380, 330)
	carta_tex.mouse_filter = Control.MOUSE_FILTER_STOP
	carta_tex.tooltip_text = "Clicca per ingrandire"
	carta_tex.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: _mostra_carta(m.s["carta"] if m else ""))
	pannello.add_child(carta_tex)
	lbl_carta = _lbl_carta("", 15)
	lbl_carta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_carta.custom_minimum_size = Vector2(380, 0)
	pannello.add_child(lbl_carta)
	pannello.add_child(_titoletto("Capacità in gioco"))
	cap_box = VBoxContainer.new()
	pannello.add_child(cap_box)
	# finestre
	fine_dlg = AcceptDialog.new()
	fine_dlg.title = "Fine della partita"
	fine_dlg.ok_button_text = "Torna al menu"
	fine_dlg.confirmed.connect(_torna_menu)
	add_child(fine_dlg)
	regole_pop = AcceptDialog.new()
	regole_pop.title = "Regole in breve"
	regole_pop.ok_button_text = "Chiudi"
	add_child(regole_pop)
	regole_txt = RichTextLabel.new()
	regole_txt.bbcode_enabled = true
	regole_txt.custom_minimum_size = Vector2(900, 620)
	regole_txt.add_theme_color_override("default_color", Tema.INK)
	regole_pop.add_child(regole_txt)
	carta_pop = PopupPanel.new()
	add_child(carta_pop)
	carta_pop_tex = TextureRect.new()
	carta_pop_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	carta_pop_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	carta_pop_tex.custom_minimum_size = Vector2(540, 756)
	carta_pop.add_child(carta_pop_tex)


func _spazio_h(w: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, 0)
	return c


func _titoletto(t: String) -> Label:
	var l := Label.new()
	l.text = t.to_upper()
	l.add_theme_font_override("font", Tema.maiuscoletto())
	l.add_theme_font_size_override("font_size", 19)
	l.add_theme_color_override("font_color", Tema.INK_DIM)
	return l


func _chip(f: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(230, 52)
	p.add_theme_stylebox_override("panel", Tema.box(Tema.FAZ[f].darkened(0.35), Tema.FAZ[f], 2, 3, 6))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", -2)
	p.add_child(v)
	var n := Label.new()
	n.add_theme_font_override("font", Tema.ui_heavy())
	n.add_theme_font_size_override("font_size", 20)
	n.add_theme_color_override("font_color", Color.WHITE)
	v.add_child(n)
	var d := Label.new()
	d.add_theme_font_size_override("font_size", 15)
	d.add_theme_color_override("font_color", Color("e8e2d4"))
	v.add_child(d)
	return p


# ================================================================ PARTITA: controllo

func avvia(g: String, sm: int, o2: Dictionary, atti_prec: Array, ans_prec: Array = []) -> void:
	gioco_id = g
	seme = sm
	opz = o2
	m = Motore.new()
	m.nuova(g, sm, o2)
	registro_fisso = ["[color=#c9a24a][b]The British Way: %s %s[/b][/color]" % [GIOCHI[g]["nome"], GIOCHI[g]["anni"]]]
	atti = []
	for r in atti_prec:
		var b: Dictionary = m.s.duplicate(true)
		m.prova(b, r)
		for l in m.registro:
			registro_fisso.append(_colora(l))
		atti.append(r)
	base = m.s.duplicate(true)
	ans = ans_prec.duplicate()
	piano = []
	storia = []
	menu.visible = false
	partita.visible = true
	(partita.find_child("Sotto", true, false) as Label).text = "%s %s · Britannici contro %s" % [GIOCHI[g]["nome"], GIOCHI[g]["anni"], GIOCHI[g]["ins"]]
	_disposizione(g == "cipro")
	mappa.imposta(m)
	call_deferred("_passo")


## Mappa orizzontale (Cipro): registro e stato sotto la mappa; mappe verticali: in una colonna accanto.
func _disposizione(orizzontale: bool) -> void:
	var basso: Control = partita.find_child("Basso", true, false)
	var lato: Control = partita.find_child("Lato", true, false)
	var logp: Control = partita.find_child("LogP", true, false)
	var statop: Control = partita.find_child("StatoP", true, false)
	var dest: Control = basso if orizzontale else lato
	for p in [statop, logp]:
		if p.get_parent() != dest:
			p.get_parent().remove_child(p)
			dest.add_child(p)
	basso.visible = orizzontale
	lato.visible = not orizzontale
	if orizzontale:
		basso.move_child(logp, 0)
		statop.custom_minimum_size = Vector2(430, 0)
		statop.size_flags_vertical = Control.SIZE_FILL
		logp.size_flags_vertical = Control.SIZE_FILL
	else:
		statop.custom_minimum_size = Vector2(0, 230)
		statop.size_flags_vertical = Control.SIZE_FILL
		logp.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _colora(l: String) -> String:
	if l.begins_with("—"):
		return "[color=#c9a24a][b]%s[/b][/color]" % l
	if l.begins_with("FINE"):
		return "[color=#f0cf6e][b]%s[/b][/color]" % l
	if l.begins_with("Volontà Politica"):
		return "[color=#9fc0ff]%s[/color]" % l
	return l


func _passo() -> void:
	if m == null or not partita.visible:
		return
	var fatto := m.prova(base, ans)
	if fatto:
		for l in m.registro:
			registro_fisso.append(_colora(l))
		var prima: Dictionary = base.get("sp", {})
		for id in m.ordine:
			if prima.has(id) and str(prima[id]) != str(m.s["sp"][id]):
				mappa.ultimo_cambiato[id] = mappa._t
		var concluso := ans.duplicate()
		atti.append(concluso)
		_invia_rete(atti.size() - 1, concluso, true)
		base = m.s.duplicate(true)
		ans = []
		piano = []
		_salva_locale()
		_aggiorna_ui()
		if m.finita():
			_fine()
			return
		call_deferred("_passo")
		return
	_aggiorna_ui()
	var f: String = m.need["f"]
	var chi: String = controllo.get(f, "umano")
	if chi == "ia":
		_turno_ia()
	elif chi == "remoto":
		_invia_rete(atti.size(), ans, false)
	_mostra_domanda(chi)


func _turno_ia() -> void:
	if ia_in_corso:
		return
	ia_in_corso = true
	var demo: bool = controllo["brit"] == "ia" and controllo["ins"] == "ia"
	await get_tree().create_timer((0.6 if demo else 0.45) if ans.is_empty() else (0.2 if demo else 0.12)).timeout
	if m == null or m.need == null or not partita.visible:
		ia_in_corso = false
		return
	var v = IA.rispondi(base, ans, m.need, piano, rng, ia_forza)
	ans.append(v)
	ia_in_corso = false
	_passo()


func rispondi(v) -> void:
	if m == null or m.need == null:
		return
	if controllo.get(m.need["f"], "") != "umano":
		return
	storia.append([atti.size(), ans.duplicate()])
	ans.append(v)
	piano = []
	_passo()


func _annulla() -> void:
	if online or storia.is_empty() or ia_in_corso:
		return
	var st: Array = storia.pop_back()
	var n: int = st[0]
	if n != atti.size():
		# torna indietro di uno o più atti: ricostruisce la partita
		var vecchi := atti.slice(0, n)
		avvia(gioco_id, seme, opz, vecchi, st[1])
		return
	ans = st[1]
	piano = []
	_passo()


# ================================================================ PARTITA: interfaccia

func _aggiorna_ui() -> void:
	if m == null:
		return
	var s: Dictionary = m.s
	var g := m.gioco()
	# barra superiore
	(top_brit.get_child(0).get_child(0) as Label).text = "Britannici" + _tag_ctrl("brit")
	(top_ins.get_child(0).get_child(0) as Label).text = m.nome_faz("ins") + _tag_ctrl("ins")
	var bt = "Volontà Politica %d/%d" % [int(s["pw"]), int(s["pw_max"])]
	if m.cellule():
		bt += " · Intel %s" % (_intel_txt() if not (s["intel"] as Array).is_empty() else "nessuno")
	elif g == "malesia":
		bt += " · Risorse %d" % int(s["ris"]["brit"])
	else:
		bt += " · Pipeline %d" % int(s["pipeline"])
	lbl_brit.text = bt
	if m.cellule():
		lbl_ins.text = "Disponibili: %s, %s · Prigione %d" % [m.pz(m.disp("g"), "g"), m.pz(m.disp("b"), "b"), int(s["prigione"])]
	else:
		lbl_ins.text = "Risorse %d · Disponibili: %s, %s" % [int(s["ris"]["ins"]), m.pz(m.disp("g"), "g"), m.pz(m.disp("b"), "b")]
	var di_turno: String = m.need["f"] if m.need != null else ""
	for f in ["brit", "ins"]:
		var p: PanelContainer = top_brit if f == "brit" else top_ins
		p.add_theme_stylebox_override("panel", Tema.box(Tema.FAZ[f].darkened(0.35 if f != di_turno else 0.05), Tema.GOLD_HI if f == di_turno else Tema.FAZ[f], 3 if f == di_turno else 1, 3, 6))
	var mazzo: Array = s["mazzo"]
	var a_prop := 0
	for c in mazzo:
		if m.carta_dati(c).get("propaganda", false):
			break
		a_prop += 1
	lbl_mazzo.text = "Mazzo %d · Prop. %d/%d" % [mazzo.size(), int(s["prop_fatte"]), int(s["prop_tot"])] if not m.finita() else "Partita conclusa"
	lbl_mazzo.tooltip_text = "Carte rimaste nel mazzo: %d. Propaganda giocate: %d di %d." % [mazzo.size(), int(s["prop_fatte"]), int(s["prop_tot"])]
	lbl_mazzo.add_theme_color_override("font_color", Tema.TEXT_DIM)
	btn_annulla.disabled = online or storia.is_empty()
	# iniziativa
	for c in iniz_box.get_children():
		c.queue_free()
	for b in m.CASELLE:
		var p := PanelContainer.new()
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var chi = s["scelte"].get(b, "")
		p.add_theme_stylebox_override("panel", Tema.box(Tema.FAZ[chi] if chi != "" else Tema.PAPER_DARK, Tema.INK_FAINT, 1, 3, 4))
		var l := Label.new()
		l.text = NOMI_SA_INIZ[b] + ("\n" + m.nome_faz(chi) if chi != "" else "\nlibera")
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.add_theme_font_size_override("font_size", 14)
		l.add_theme_color_override("font_color", Color.WHITE if chi != "" else Tema.INK_DIM)
		p.add_child(l)
		iniz_box.add_child(p)
	var pl := Label.new()
	# carta
	var cid: String = s["carta"]
	carta_tex.texture = _tex_carta(cid)
	var cd := m.carta_dati(cid)
	lbl_carta.text = "1° idoneo: %s" % m.nome_faz(s["primo"])
	# capacità
	for c in cap_box.get_children():
		c.queue_free()
	if (s["cap"] as Dictionary).is_empty():
		cap_box.add_child(_lbl_carta("Nessuna", 15))
	for k in s["cap"]:
		var cc := m.carta_dati(k)
		var b := Button.new()
		var lato: String = s["cap"][k]
		b.text = "%s %s · %s" % [k, cc.get("titolo", ""), "doppia" if lato == "d" else ("chiaro: " + str(cc.get("sott_u", ""))) if lato == "u" else ("ombreggiato: " + str(cc.get("sott_s", "")))]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.clip_text = true
		b.custom_minimum_size = Vector2(380, 32)
		Tema.tasto_carta(b)
		b.pressed.connect(_mostra_carta.bind(k))
		cap_box.add_child(b)
	# stato
	stato_lbl.text = _testo_stato()
	# registro
	var righe = registro_fisso.slice(max(0, registro_fisso.size() - 300))
	var corr: Array = []
	if m.need != null:
		for l in m.registro:
			corr.append("[color=#8fa3b8]" + l + "[/color]")
	log_lbl.text = "\n".join(righe + corr)
	mappa.queue_redraw()


func _tag_ctrl(f: String) -> String:
	match controllo.get(f, ""):
		"ia":
			return " · IA"
		"remoto":
			return " · online"
	return ""


func _intel_txt() -> String:
	var a: Array = (m.s["intel"] as Array).duplicate()
	a.sort()
	var t: Array = []
	for v in a:
		t.append(str(v))
	return "%s (tot. %d)" % [" ".join(t), m.intel_tot()]


func _tex_carta(cid: String) -> Texture2D:
	if cid == "":
		return null
	var p = "res://assets/carte/%s_%s.webp" % [m.gioco(), cid]
	return load(p) if ResourceLoader.exists(p) else null


const REGOLE_GIOCO := {
	"palestina": "Volontà Politica 0–20 (si parte da 18). [b]L'Irgun vince subito[/b] se a una Propaganda la Volontà Politica è 0; altrimenti dopo la terza Propaganda vincono i Britannici.\nPropaganda: −1 per Sabotaggio nei Distretti, −2 per Ferrovia sabotata, −2 per Sabotaggio e −3 per Terrore nelle Città; +2 se nessuna Ferrovia è sabotata, +1 per Città pulita. Poi Espropri (Rapina), Intel (pesca se non ne hai, altrimenti scarti metà), Haganah (0: Intel ai Britannici, 4: Deposito all'Irgun), Ridispiegamento, Reset (metà della Prigione esce, Cellule clandestine, Irgun primo).\nHaganah: a 4 l'Irgun ha uno spazio in più per Operazione; scendendo sotto 4 e 3 ritira pezzi all'Irgun.",
	"cipro": "Volontà Politica 0–15 (si parte da 14). [b]L'EOKA vince subito[/b] se a una Propaganda la Volontà Politica è 0; altrimenti dopo la terza Propaganda vincono i Britannici.\nPropaganda: −valore dell'Opinione internazionale, −valore dello spazio per ogni Sabotaggio in Città e Basi; +2 se nessun Deposito nei Monti, +1 ogni 2 Città senza Sabotaggio. Poi Armi EOKA, Intel, Ridispiegamento (Truppe dai Monti alle Basi, Cellule fuori dalle Basi), Reset (Opinione −1 se al massimo 3 Città con Sabotaggio o Coprifuoco, metà della Prigione esce, EOKA primo).",
	"malesia": "Volontà Politica 0–20 (si parte da 12). Vittoria immediata a una Propaganda: MCP con 0–2, Britannici con 18–20; alla fine del mazzo vince l'MCP sotto 10, i Britannici sopra 10.\nIl Controllo conta subito: l'MCP che prende il Controllo di uno spazio toglie VP pari alla Popolazione (e le restituisce perdendolo).\nPropaganda: + Popolazione a Supporto − Popolazione in Opposizione senza Nuovo Villaggio; −1 per Centro economico sabotato e per Terrore a Kuala Lumpur. Poi Risorse, Pacificazione e Agitazione, Ridispiegamento, Reset (cambia il Comandante).",
	"kenya": "Volontà Politica 0–20 (si parte da 12). Vittoria immediata a una Propaganda: Mau Mau con 0–2, Britannici con 18–20; alla fine del mazzo vincono i Mau Mau sotto 10, i Britannici sopra 10.\nIl Controllo conta subito: i Mau Mau che prendono il Controllo di uno spazio tolgono VP pari alla Popolazione.\nPropaganda: −(Resistenza − Lealtà) se negativa, −1 per Terrore negli spazi popolati non di Riserva; +2 se nessun Mau Mau a Nairobi, +2 se nessuna Base fuori dalle giungle. Poi Risorse, Ricompensa e Giuramento, Ridispiegamento, Campi nella foresta, Reset (la Pipeline può spostarsi).",
}


func _mostra_regole() -> void:
	if m == null:
		return
	var t: Array = []
	t.append("[font_size=22][b]%s %s[/b][/font_size]" % [GIOCHI[gioco_id]["nome"], GIOCHI[gioco_id]["anni"]])
	t.append("[b]Sequenza di gioco.[/b] Si scopre una carta alla volta. Il primo idoneo sceglie una casella del tracciato dell'Iniziativa (Operazione Limitata, Evento, Operazione + Attività Speciale) e la esegue o passa; il secondo sceglie una delle caselle libere. Alla carta successiva è primo chi sta nella casella più a sinistra. Chi passa riceve il bonus indicato.")
	t.append(REGOLE_GIOCO[gioco_id])
	for f in ["brit", "ins"]:
		t.append("\n[font_size=19][b]%s: Operazioni[/b][/font_size]" % m.nome_faz(f))
		for op in m.OPS[gioco_id][f]:
			t.append("• [b]%s[/b]: %s" % [m.nome_op(op), m.descrizione(op)])
		t.append("[b]Attività Speciali[/b]")
		for sa in m.SAS[gioco_id][f]:
			var acc: Array = m.SAS[gioco_id][f][sa]
			var con := "" if acc.is_empty() else " (con " + ", ".join(acc.map(func(x): return m.nome_op(x))) + ")"
			t.append("• [b]%s[/b]%s: %s" % [m.nome_op(sa), con, m.descrizione(sa)])
	regole_txt.text = "\n".join(t)
	regole_pop.popup_centered(Vector2(940, 700))


func _mostra_carta(cid: String) -> void:
	if cid == "" or m == null:
		return
	carta_pop_tex.texture = _tex_carta(cid)
	carta_pop.popup_centered(Vector2(560, 780))


func _testo_stato() -> String:
	var s: Dictionary = m.s
	var g := m.gioco()
	var t: Array = []
	t.append("[b]Volontà Politica britannica: %d[/b] (0–%d)" % [int(s["pw"]), int(s["pw_max"])])
	match g:
		"palestina":
			t.append("Haganah: [b]%s[/b]%s" % [["Condanna (0)", "Critica (1)", "Neutrale (2)", "Supporto (3)", "Coordinamento (4)"][int(s["haganah"])], " · +1 spazio alle Operazioni Irgun" if m.haganah_extra() else ""])
			t.append("Coprifuochi disponibili: %d di %d" % [int(s["coprifuoco_tot"]) - m.coprifuochi_mappa(), int(s["coprifuoco_tot"])])
		"cipro":
			t.append("Opinione internazionale: [b]%s (%d)[/b]" % [m.nome_opinione(int(s["opinione"])), int(s["opinione"])])
			t.append("Coprifuochi disponibili: %d di %d" % [int(s["coprifuoco_tot"]) - m.coprifuochi_mappa(), int(s["coprifuoco_tot"])])
		"malesia":
			var nomi = ["Gurney (Rappresaglia in 2 spazi)", "Briggs (Reinsediamento in 2 spazi)", "Templer (Pacificazione in 2 spazi)"]
			t.append("Comandante: [b]%s[/b]%s" % [nomi[int(s["comandante"])], " · annullato fino al Reset" if s["tmp"].get("gurney", false) else ""])
			t.append("Nuovi Villaggi disponibili: %d" % m.disponibili_nv())
		"kenya":
			t.append("Pipeline: [b]%s (%d)[/b] · Rappresaglia %d, Trasferimento %d spazi" % [["Stato di diritto", "Poteri d'emergenza", "Villaggizzazione", "Sistema carcerario", "Gulag"][int(s["pipeline"])], int(s["pipeline"]), m.limite_pipeline("reprisal"), m.limite_pipeline("relocate")])
			t.append("Polizia fuori gioco: %d" % int(s["fuori"]))
	t.append("Britannici disponibili: %s, %s" % [m.pz(m.disp("t"), "t"), m.pz(m.disp("p"), "p")])
	t.append("%s disponibili: %s, %s" % [m.nome_faz("ins"), m.pz(m.disp("g"), "g"), m.pz(m.disp("b"), "b")])
	if m.cellule():
		t.append("Prigione: %s · Intel nel sacchetto: %d" % [m.pz(int(s["prigione"]), "g"), (s["borsa"] as Array).size()])
	var stima := m.stima_propaganda()
	t.append("[color=#c9a24a]Se ci fosse ora la Propaganda: Volontà Politica %s%d[/color]" % ["+" if stima >= 0 else "", stima])
	return "\n".join(t)


func _mostra_domanda(chi: String) -> void:
	for c in box_opz.get_children():
		c.queue_free()
	mappa.candidati = []
	mappa.selezionati = []
	if m.finita():
		lbl_chi.text = "Partita conclusa"
		lbl_domanda.text = m.s["fine"].get("m", "")
		banner.add_theme_stylebox_override("panel", Tema.box(Tema.GOLD.darkened(0.5), Tema.GOLD, 2, 3, 10))
		return
	var q: Dictionary = m.need
	var f: String = q["f"]
	banner.add_theme_stylebox_override("panel", Tema.box(Tema.FAZ[f].darkened(0.1), Tema.GOLD if chi == "umano" else Tema.FAZ[f].darkened(0.4), 2, 3, 10))
	lbl_chi.text = m.nome_faz(f) + {"umano": " · tocca a te", "ia": " · l'IA sta pensando…", "remoto": " · in attesa dell'avversario online"}.get(chi, "")
	lbl_domanda.text = q["testo"]
	if chi != "umano":
		return
	var opzioni: Array = q["opz"]
	var qx: Dictionary = q.get("x", {})
	for k in ["da", "a"]:
		if qx.has(k):
			mappa.selezionati.append(qx[k])
	var spazi: bool = q.get("x", {}).get("spazi", false)
	var num: bool = q.get("x", {}).get("num", false)
	var lunghe := false
	for o in opzioni:
		if str(o["t"]).length() > 22:
			lunghe = true
	box_opz.columns = 1 if lunghe else (6 if num else 2)
	if str(q.get("x", {}).get("tag", "")) in ["op", "sa"] or q.get("x", {}).get("spazi", false):
		box_opz.columns = 1
	for o in opzioni:
		var v = o["v"]
		if spazi and v is String and m.SP.has(v):
			mappa.candidati.append(v)
			continue
		var b := Button.new()
		b.text = str(o["t"])
		b.custom_minimum_size = Vector2(0, 44 if not num else 40)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if lunghe else TextServer.AUTOWRAP_OFF
		var passivo: bool = v is String and v in ["fine", "passa", "no", "nessuna"]
		Tema.tasto_carta(b, not passivo and not num and not spazi, Tema.FAZ[f])
		b.pressed.connect(rispondi.bind(v))
		box_opz.add_child(b)
		var tag: String = str(q.get("x", {}).get("tag", ""))
		if tag in ["op", "sa"] and v is String:
			var dsc: String = m.descrizione(v)
			if dsc != "":
				b.tooltip_text = dsc
				var dl := _lbl_carta(dsc, 14)
				dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				dl.add_theme_color_override("font_color", Tema.INK_DIM)
				box_opz.add_child(dl)
	if spazi:
		var h := _lbl_carta("Clicca uno spazio evidenziato sulla mappa, oppure il suo nome qui sotto.", 16)
		h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box_opz.add_child(h)
		box_opz.move_child(h, 0)
		var fl := HFlowContainer.new()
		fl.add_theme_constant_override("h_separation", 4)
		fl.add_theme_constant_override("v_separation", 4)
		fl.custom_minimum_size = Vector2(390, 0)
		for id in mappa.candidati:
			var sb := Button.new()
			sb.text = m.nome_sp(id)
			sb.add_theme_font_size_override("font_size", 15)
			sb.custom_minimum_size = Vector2(0, 32)
			Tema.tasto_carta(sb, false, Tema.FAZ[f])
			sb.pressed.connect(rispondi.bind(id))
			sb.mouse_entered.connect(func(): mappa.sopra = id; mappa.queue_redraw())
			fl.add_child(sb)
		box_opz.add_child(fl)
		box_opz.move_child(fl, 1)
	mappa.queue_redraw()


func _click_spazio(id: String) -> void:
	if id in mappa.candidati:
		rispondi(id)


func _sopra_spazio(id: String) -> void:
	if id == "" or m == null:
		info_lbl.text = ""
		return
	var x := m.X(id)
	var parti: Array = [m.nome_sp(id)]
	var tipi := {"distretto": "Distretto", "citta": "Città", "ferrovia": "Ferrovia", "montagna": "Monti", "base": "Base britannica",
		"prov_m": "Provincia di Montagna", "prov_g": "Provincia di Giungla", "thai": "Thailandia", "kl": "Capitale", "ec": "Centro economico",
		"prov_r": "Provincia di Riserva", "prov_n": "Provincia", "giungla": "Giungla di montagna", "nairobi": "Capitale"}
	parti.append(tipi.get(m.tipo(id), ""))
	if m.SP[id].has("pop"):
		parti.append("Pop. %d" % m.popolazione(id))
	var pz: Array = []
	for k in ["t", "p"]:
		if int(x[k]) > 0:
			pz.append(m.pz(int(x[k]), k))
	if int(x["u"]) > 0:
		pz.append("%s clandestin%s" % [m.pz(int(x["u"]), "g"), "a" if int(x["u"]) == 1 else "e"])
	if int(x["a"]) > 0:
		pz.append("%s attiv%s" % [m.pz(int(x["a"]), "g"), "a" if int(x["a"]) == 1 else "e"])
	if int(x["b"]) > 0:
		pz.append(m.pz(int(x["b"]), "b"))
	if int(x["sab"]) > 0:
		pz.append("Sabotaggio ×%d" % int(x["sab"]))
	if int(x["ter"]) > 0:
		pz.append("Terrore ×%d" % int(x["ter"]))
	if int(x["cf"]) > 0:
		pz.append("Coprifuoco")
	if int(x["nv"]) > 0:
		pz.append("Nuovo Villaggio")
	if not m.cellule():
		if x["ctrl"] != "":
			pz.append("Controllo " + m.nome_faz(x["ctrl"]))
		if m.puo_sup(id):
			pz.append(m.nome_sup(int(x["sup"])))
	info_lbl.text = " · ".join(parti) + (": " + ", ".join(pz) if not pz.is_empty() else ": vuoto")


func _zoom(k: String) -> void:
	match k:
		"zoom_piu":
			mappa.zoom_a(mappa.zoom * 1.25, mappa.size * 0.5)
		"zoom_meno":
			mappa.zoom_a(mappa.zoom / 1.25, mappa.size * 0.5)
		_:
			mappa.adatta()


func _fine() -> void:
	_mostra_domanda("")
	var fine: Dictionary = m.s["fine"]
	var v: String = fine.get("v", "")
	var chi := "Vittoria britannica" if v == "brit" else ("Vittoria " + m.nome_faz("ins") if v == "ins" else "Pareggio")
	fine_dlg.dialog_text = "%s\n\n%s\n\nVolontà Politica finale: %d" % [chi, fine.get("m", ""), int(m.s["pw"])]
	fine_dlg.popup_centered(Vector2(520, 260))
	_cancella_locale()


func _torna_menu() -> void:
	if online and stanza != "":
		rete.remember_room("")
	online = false
	stanza = ""
	partita.visible = false
	menu.visible = true
	m = null
	_aggiorna_tasti_menu()


func _process(delta: float) -> void:
	if online and stanza != "" and partita.visible:
		_poll_t += delta
		if _poll_t > 1.6:
			_poll_t = 0.0
			_poll_rete()


# ================================================================ SALVATAGGI

func _dati_salvataggio() -> Dictionary:
	return {"gioco": gioco_id, "seme": seme, "opz": opz, "atti": atti, "ans": ans, "controllo": controllo, "v": 1}


func _file_salva(g: String) -> String:
	return "user://britishway_%s.json" % g


func _salva_locale() -> void:
	if online or m == null:
		return
	var f := FileAccess.open(_file_salva(gioco_id), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_dati_salvataggio()))
	# ogni 4 atti anche su Firebase (in silenzio)
	if atti.size() % 4 == 0:
		_salva_cloud(true)


func _cancella_locale() -> void:
	if FileAccess.file_exists(_file_salva(gioco_id)):
		DirAccess.remove_absolute(_file_salva(gioco_id))


func _riprendi_locale() -> void:
	var f := FileAccess.open(_file_salva(gioco_id), FileAccess.READ)
	if f == null:
		menu_msg.text = "Nessuna partita di %s salvata su questo dispositivo." % GIOCHI[gioco_id]["nome"]
		return
	var d = JSON.parse_string(f.get_as_text())
	if not (d is Dictionary):
		menu_msg.text = "Salvataggio illeggibile."
		return
	_carica(d)


func _carica(d: Dictionary) -> void:
	controllo = d.get("controllo", {"brit": "umano", "ins": "ia"})
	online = false
	avvia(str(d["gioco"]), int(d["seme"]), d.get("opz", {}), d.get("atti", []), [])


var _cloud_occupato := false


## Su Firebase c'è un salvataggio per giocatore: vi teniamo una partita per ciascuno dei quattro giochi.
func _salva_cloud(silenzioso: bool = false) -> void:
	if online or m == null or _cloud_occupato:
		return
	_cloud_occupato = true
	if not silenzioso:
		info_lbl.text = "Salvataggio online in corso…"
	var tutti = await rete.carica_partita()
	if not (tutti is Dictionary) or tutti.has("gioco"):
		tutti = {}
	tutti[gioco_id] = _dati_salvataggio()
	tutti[gioco_id]["quando"] = Time.get_datetime_string_from_system()
	var ok = await rete.salva_partita(tutti)
	_cloud_occupato = false
	if not silenzioso:
		info_lbl.text = "Partita salvata online." if ok else "Salvataggio online non riuscito: " + rete.last_error


func _riprendi_cloud() -> void:
	menu_msg.text = "Carico il salvataggio online…"
	var d = await rete.carica_partita()
	if d is Dictionary and d.has("gioco"):
		_carica(d)
		return
	if not (d is Dictionary) or not d.has(gioco_id):
		menu_msg.text = "Nessuna partita di %s salvata online." % GIOCHI[gioco_id]["nome"] + ("" if rete.last_error == "" else " (" + rete.last_error + ")")
		return
	_carica(d[gioco_id])


# ================================================================ ONLINE

func _crea_stanza(fazione: String) -> void:
	menu_msg.text = "Creo la stanza…"
	var nome := nome_edit.text.strip_edges()
	if nome == "":
		nome = "Giocatore"
	var sm := rng.randi() % 1000000000 + 1
	var cfg := {"gioco": gioco_id, "seme": sm, "host": fazione, "opz": {}}
	var code = await rete.create_room(nome, cfg)
	if code == "":
		menu_msg.text = "Impossibile creare la stanza: " + rete.last_error
		return
	stanza = code
	posto = 0
	rete.remember_room(code, 0)
	menu_msg.text = "Stanza [%s] creata per %s. Comunica il codice all'avversario: la partita inizia appena entra." % [code, GIOCHI[gioco_id]["nome"]]
	# attende l'ospite
	for i in 300:
		await get_tree().create_timer(2.0).timeout
		if stanza != code:
			return
		var r = await rete.room(code)
		var seats: Dictionary = Rete._as_dict(r.get("seats", {}))
		if seats.has("1"):
			await rete.start_room(code, cfg)
			_avvia_online(cfg, fazione)
			return
	menu_msg.text = "Nessuno è entrato nella stanza %s." % code


func _entra_stanza() -> void:
	var code := codice_edit.text.strip_edges().to_upper()
	if code.length() != 4:
		menu_msg.text = "Il codice della stanza ha 4 lettere."
		return
	menu_msg.text = "Entro nella stanza %s…" % code
	var nome := nome_edit.text.strip_edges()
	if nome == "":
		nome = "Ospite"
	var p = await rete.join_room(code, nome, 2)
	if p < 0:
		menu_msg.text = "Impossibile entrare nella stanza %s. %s" % [code, rete.last_error]
		return
	stanza = code
	posto = p
	rete.remember_room(code, p)
	for i in 120:
		var r = await rete.room(code)
		if r.get("status", "") == "playing" and r.has("game"):
			var cfg = JSON.parse_string(str(r["game"]))
			if cfg is Dictionary:
				var mia = "ins" if cfg["host"] == "brit" else "brit"
				_avvia_online(cfg, mia)
				return
		menu_msg.text = "Nella stanza %s: in attesa che l'host avvii la partita…" % code
		await get_tree().create_timer(2.0).timeout


func _avvia_online(cfg: Dictionary, mia: String) -> void:
	online = true
	net_k = 0
	net_inviati = {}
	controllo = {"brit": "umano" if mia == "brit" else "remoto", "ins": "umano" if mia == "ins" else "remoto"}
	_seleziona_gioco(str(cfg["gioco"]))
	avvia(str(cfg["gioco"]), int(cfg["seme"]), cfg.get("opz", {}), [])
	info_lbl.text = "Online nella stanza %s: tu giochi con %s." % [stanza, "i Britannici" if mia == "brit" else m.nome_faz("ins")]


## Rientra nella stanza ricordata (dopo aver ricaricato la pagina): ricostruisce la partita dal registro online.
func _rientra_stanza() -> void:
	var ss := rete.load_session()
	var code := str(ss.get("room", ""))
	if code == "":
		menu_msg.text = "Nessuna stanza online da riprendere su questo dispositivo."
		return
	menu_msg.text = "Rientro nella stanza %s…" % code
	if not await rete.sign_in():
		menu_msg.text = "Accesso a Firebase non riuscito: " + rete.last_error
		return
	var r = await rete.room(code)
	if r.is_empty() or not r.has("game"):
		menu_msg.text = "La stanza %s non esiste più o la partita non è iniziata." % code
		return
	var cfg = JSON.parse_string(str(r["game"]))
	if not (cfg is Dictionary):
		return
	var seats: Dictionary = Rete._as_dict(r.get("seats", {}))
	var mio := -1
	for k in seats:
		if seats[k] is Dictionary and seats[k].get("uid", "") == rete.uid:
			mio = int(k)
	if mio < 0:
		menu_msg.text = "Non risulti seduto nella stanza %s." % code
		return
	stanza = code
	posto = mio
	var mia: String = cfg["host"] if mio == 0 else ("ins" if cfg["host"] == "brit" else "brit")
	var dd = await rete.get_decisions(code, 0)
	var chiavi: Array = dd.keys()
	chiavi.sort()
	var per_atto := {}
	var ultimo := 0
	for k in chiavi:
		var d: Dictionary = dd[k]
		var n := int(d.get("n", -1))
		var rr: Array = d.get("r", [])
		if not per_atto.has(n) or rr.size() >= (per_atto[n]["r"] as Array).size():
			per_atto[n] = d
		ultimo = int(k) + 1
	var atti_rete: Array = []
	var parziale: Array = []
	var n2 := 0
	while per_atto.has(n2):
		var d2: Dictionary = per_atto[n2]
		if d2.get("c", false):
			atti_rete.append(d2["r"])
		else:
			parziale = d2["r"]
			break
		n2 += 1
	online = true
	net_k = ultimo
	net_inviati = {}
	controllo = {"brit": "umano" if mia == "brit" else "remoto", "ins": "umano" if mia == "ins" else "remoto"}
	_seleziona_gioco(str(cfg["gioco"]))
	avvia(str(cfg["gioco"]), int(cfg["seme"]), cfg.get("opz", {}), atti_rete, parziale)
	info_lbl.text = "Di nuovo nella stanza %s." % code


## Pubblica le risposte date localmente (atto n): vanno in coda e le spedisce un'unica routine di sincronizzazione,
## che prima legge il registro (per non scavalcare le mosse dell'avversario) e poi scrive al primo numero libero.
var _da_inviare: Array = []
var _sync_attivo := false


func _invia_rete(n: int, r: Array, concluso: bool) -> void:
	if not online or stanza == "":
		return
	if r.is_empty() and not concluso:
		return
	var key := "%d:%d" % [n, r.size()]
	if net_inviati.has(key):
		return
	net_inviati[key] = true
	_da_inviare.append({"n": n, "r": r.duplicate(), "c": concluso})
	_sync()


func _sync() -> void:
	if _sync_attivo or not online or stanza == "":
		return
	_sync_attivo = true
	var giri := 0
	while giri < 20:
		giri += 1
		await _leggi_rete()
		if _da_inviare.is_empty():
			break
		var d: Dictionary = _da_inviare[0]
		var ok = await rete.post_decision(stanza, net_k, d)
		if ok:
			net_k += 1
			_da_inviare.pop_front()
	_sync_attivo = false


func _poll_rete() -> void:
	_sync()


func _leggi_rete() -> void:
	var dd = await rete.get_decisions(stanza, net_k)
	var chiavi: Array = dd.keys()
	chiavi.sort()
	for k in chiavi:
		if int(k) < net_k:
			continue
		var d: Dictionary = dd[k]
		net_k = int(k) + 1
		var n := int(d.get("n", -1))
		var r: Array = d.get("r", [])
		net_inviati["%d:%d" % [n, r.size()]] = true
		if n == atti.size() and r.size() > ans.size():
			ans = r
			_passo()
