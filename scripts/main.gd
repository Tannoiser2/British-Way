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
var iniz_box: VBoxContainer
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
var fine_txt: RichTextLabel
var camp_scr: Control
var plancia: PlanciaCampagna
var camp_info: VBoxContainer
var camp_btn_gioca: Button
var camp_btn_menu: Button
var btn_salva_online: Button
var btn_campagna: Button
var _camp_dal_gioco := false
var _dlg_info := false
var _carta_mostrata := ""
var nome_edit: LineEdit
var codice_edit: LineEdit
var sel_gioco_btns: Dictionary = {}
var campagna: Dictionary = {}       # campagna End of Empire in corso (vuoto = partita singola)
var camp_prewar := true
var opz_menu := {"lungo": false, "avanzata": true}
var camp_avanzata := true
var camp_lbl: Label
var camp_codice_edit: LineEdit
var _camp_cloud_occupato := false
var _camp_cloud_di_nuovo := false


func _ready() -> void:
	theme = Tema.tema()
	rng.randomize()
	rete = Rete.new()
	add_child(rete)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_costruisci_menu()
	_costruisci_partita()
	_costruisci_schermata_campagna()
	partita.visible = false
	menu.visible = true
	_seleziona_gioco("palestina")
	_aggiorna_menu_campagna()


# ================================================================ MENU

func _costruisci_menu() -> void:
	menu = Control.new()
	menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(menu)
	var bg := ColorRect.new()
	bg.color = Tema.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.add_child(bg)
	var marg := MarginContainer.new()
	marg.set_anchors_preset(Control.PRESET_FULL_RECT)
	for k in ["left", "right"]:
		marg.add_theme_constant_override("margin_" + k, 28)
	marg.add_theme_constant_override("margin_top", 10)
	marg.add_theme_constant_override("margin_bottom", 10)
	menu.add_child(marg)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	marg.add_child(col)
	# --- titolo
	var tit := HBoxContainer.new()
	tit.alignment = BoxContainer.ALIGNMENT_CENTER
	tit.add_theme_constant_override("separation", 18)
	col.add_child(tit)
	var t := Label.new()
	t.text = "THE BRITISH WAY"
	t.add_theme_font_override("font", Tema.titolo())
	t.add_theme_font_size_override("font_size", 50)
	t.add_theme_color_override("font_color", Tema.PAPER)
	tit.add_child(t)
	var st := Label.new()
	st.text = "Controinsurrezione alla fine dell'Impero\nquattro giochi COIN per due giocatori"
	st.add_theme_font_override("font", Tema.serif_it())
	st.add_theme_font_size_override("font_size", 20)
	st.add_theme_color_override("font_color", Tema.GOLD)
	tit.add_child(st)
	# --- i quattro giochi
	var riga := HBoxContainer.new()
	riga.size_flags_vertical = Control.SIZE_EXPAND_FILL
	riga.add_theme_constant_override("separation", 12)
	col.add_child(riga)
	for g in ["palestina", "malesia", "kenya", "cipro"]:
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 250)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.toggle_mode = true
		b.add_theme_stylebox_override("normal", Tema.box(Color("16243a"), Color("33496d"), 1, 4))
		b.add_theme_stylebox_override("hover", Tema.box(Color("1d2f4b"), Tema.GOLD, 2, 4))
		b.add_theme_stylebox_override("pressed", Tema.box(Color("22385c"), Tema.GOLD_HI, 3, 4))
		var v := VBoxContainer.new()
		v.set_anchors_preset(Control.PRESET_FULL_RECT)
		v.offset_left = 8
		v.offset_right = -8
		v.offset_top = 8
		v.offset_bottom = -8
		v.add_theme_constant_override("separation", 2)
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(v)
		var img := TextureRect.new()
		img.texture = load("res://assets/mappe/%s.webp" % g)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		img.custom_minimum_size = Vector2(0, 120)
		img.size_flags_vertical = Control.SIZE_EXPAND_FILL
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		img.clip_contents = true
		v.add_child(img)
		var n := Label.new()
		n.text = GIOCHI[g]["nome"]
		n.add_theme_font_override("font", Tema.titolo())
		n.add_theme_font_size_override("font_size", 26)
		n.add_theme_color_override("font_color", Tema.PAPER)
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(n)
		var a2 := Label.new()
		a2.text = "%s · Britannici contro %s" % [GIOCHI[g]["anni"], GIOCHI[g]["ins"]]
		a2.add_theme_color_override("font_color", Tema.GOLD)
		a2.add_theme_font_size_override("font_size", 16)
		a2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(a2)
		var d := Label.new()
		d.text = GIOCHI[g]["desc"]
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.add_theme_color_override("font_color", Tema.TEXT_DIM)
		d.add_theme_font_size_override("font_size", 14)
		d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(d)
		b.pressed.connect(_seleziona_gioco.bind(g))
		riga.add_child(b)
		sel_gioco_btns[g] = b
	# --- due colonne: partita singola | campagna
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 12)
	col.add_child(cols)
	var pan := PanelContainer.new()
	pan.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pan.add_theme_stylebox_override("panel", Tema.carta(10))
	cols.add_child(pan)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 6)
	pan.add_child(pv)
	pv.add_child(_lbl_carta("Partita singola (gioco selezionato sopra)", 22, true))
	var g1 := GridContainer.new()
	g1.columns = 2
	g1.add_theme_constant_override("h_separation", 6)
	g1.add_theme_constant_override("v_separation", 6)
	pv.add_child(g1)
	for k in [["brit", "Io Britannici contro l'IA"], ["ins", "Io insorti contro l'IA"], ["hotseat", "Due giocatori, stesso schermo"], ["demo", "IA contro IA (dimostrazione)"]]:
		var b := Button.new()
		b.text = k[1]
		b.custom_minimum_size = Vector2(0, 38)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		Tema.tasto_carta(b, k[0] in ["brit", "ins"], Tema.NAVY if k[0] == "brit" else Tema.RED)
		b.pressed.connect(_nuova_locale.bind(k[0]))
		g1.add_child(b)
		if k[0] == "ins":
			b.set_meta("ins_btn", true)
	var bl := Button.new()
	bl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bl.custom_minimum_size = Vector2(0, 34)
	Tema.tasto_carta(bl)
	bl.pressed.connect(_riprendi_locale)
	bl.set_meta("riprendi", "locale")
	g1.add_child(bl)
	var bc := Button.new()
	bc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bc.custom_minimum_size = Vector2(0, 34)
	Tema.tasto_carta(bc)
	bc.pressed.connect(_riprendi_cloud)
	bc.set_meta("riprendi", "cloud")
	g1.add_child(bc)
	var rch := HBoxContainer.new()
	rch.add_theme_constant_override("separation", 14)
	pv.add_child(rch)
	var lunga := CheckBox.new()
	lunga.text = "Malesia: scenario esteso"
	lunga.tooltip_text = "Mazzo di 27 carte invece di 21"
	_stile_check(lunga)
	lunga.toggled.connect(func(v): opz_menu["lungo"] = v)
	rch.add_child(lunga)
	var avz := CheckBox.new()
	avz.text = "Cipro: variante avanzata"
	avz.tooltip_text = "Regola standard dalla 2ª edizione: Reclutamento sempre possibile nei Monti, niente Spostamento dai Coprifuochi, Opinione che sale con i prigionieri"
	avz.button_pressed = true
	_stile_check(avz)
	avz.toggled.connect(func(v): opz_menu["avanzata"] = v)
	rch.add_child(avz)
	pv.add_child(_lbl_carta("Online", 22, true))
	var r3 := HBoxContainer.new()
	r3.add_theme_constant_override("separation", 6)
	pv.add_child(r3)
	nome_edit = LineEdit.new()
	nome_edit.placeholder_text = "Il tuo nome"
	nome_edit.text = "Stefano"
	nome_edit.custom_minimum_size = Vector2(130, 36)
	nome_edit.add_theme_color_override("font_placeholder_color", Tema.INK_FAINT)
	r3.add_child(nome_edit)
	for k in [["brit", "Crea: io Britannici"], ["ins", "Crea: io insorti"]]:
		var b := Button.new()
		b.text = k[1]
		b.custom_minimum_size = Vector2(0, 36)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		Tema.tasto_carta(b)
		b.pressed.connect(_crea_stanza.bind(k[0]))
		r3.add_child(b)
	var r4 := HBoxContainer.new()
	r4.add_theme_constant_override("separation", 6)
	pv.add_child(r4)
	codice_edit = LineEdit.new()
	codice_edit.placeholder_text = "Codice stanza"
	codice_edit.max_length = 4
	codice_edit.custom_minimum_size = Vector2(130, 36)
	codice_edit.add_theme_color_override("font_placeholder_color", Tema.INK_FAINT)
	r4.add_child(codice_edit)
	var be := Button.new()
	be.text = "Entra nella stanza"
	be.custom_minimum_size = Vector2(0, 36)
	be.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Tema.tasto_carta(be, true)
	be.pressed.connect(_entra_stanza)
	r4.add_child(be)
	var br2 := Button.new()
	br2.text = "Rientra nell'ultima stanza"
	br2.custom_minimum_size = Vector2(0, 36)
	br2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Tema.tasto_carta(br2)
	br2.pressed.connect(_rientra_stanza)
	r4.add_child(br2)
	# --- campagna
	var pan2 := PanelContainer.new()
	pan2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pan2.add_theme_stylebox_override("panel", Tema.carta(10))
	cols.add_child(pan2)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 6)
	pan2.add_child(cv)
	cv.add_child(_lbl_carta("Campagna «End of Empire»", 22, true))
	var cd := _lbl_carta("Le quattro partite in fila (Palestina, Malesia, Kenya, Cipro) con Prestigio imperiale (da 13), Politica coloniale ed eventi di campagna. Alla fine: 11-15 Ritirata ordinata, 5-10 Vento del cambiamento, 0-4 Fuga dalle colonie.", 14)
	cd.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cd.add_theme_color_override("font_color", Tema.INK_DIM)
	cd.custom_minimum_size = Vector2(300, 0)
	cv.add_child(cd)
	var g2 := GridContainer.new()
	g2.columns = 2
	g2.add_theme_constant_override("h_separation", 6)
	g2.add_theme_constant_override("v_separation", 6)
	cv.add_child(g2)
	for k in [["brit", "Io Britannici contro l'IA"], ["ins", "Io insorti contro l'IA"], ["hotseat", "Due giocatori, stesso schermo"], ["demo", "IA contro IA (dimostrazione)"]]:
		var b := Button.new()
		b.text = k[1]
		b.custom_minimum_size = Vector2(0, 38)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		Tema.tasto_carta(b, k[0] in ["brit", "ins"], Tema.NAVY if k[0] == "brit" else Tema.RED)
		b.pressed.connect(_nuova_campagna.bind(k[0]))
		g2.add_child(b)
	var bcl := Button.new()
	bcl.text = "Riprendi la campagna"
	bcl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bcl.custom_minimum_size = Vector2(0, 34)
	Tema.tasto_carta(bcl)
	bcl.pressed.connect(_riprendi_campagna.bind(false))
	g2.add_child(bcl)
	var bcc := Button.new()
	bcc.text = "Riprendi da Firebase"
	bcc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bcc.custom_minimum_size = Vector2(0, 34)
	Tema.tasto_carta(bcc)
	bcc.pressed.connect(_riprendi_campagna.bind(true))
	g2.add_child(bcc)
	var pw := CheckBox.new()
	pw.text = "Tabelle pre-belliche (tiro casuale)"
	pw.button_pressed = true
	_stile_check(pw)
	pw.toggled.connect(func(v): camp_prewar = v)
	var rpw := HBoxContainer.new()
	rpw.add_theme_constant_override("separation", 14)
	cv.add_child(rpw)
	rpw.add_child(pw)
	var cavz := CheckBox.new()
	cavz.text = "Cipro: variante avanzata"
	cavz.tooltip_text = "Regola standard dalla 2ª edizione"
	cavz.button_pressed = true
	_stile_check(cavz)
	cavz.toggled.connect(func(v): camp_avanzata = v)
	rpw.add_child(cavz)
	var rc3 := HBoxContainer.new()
	rc3.add_theme_constant_override("separation", 6)
	cv.add_child(rc3)
	camp_codice_edit = LineEdit.new()
	camp_codice_edit.placeholder_text = "Codice campagna"
	camp_codice_edit.max_length = 6
	camp_codice_edit.custom_minimum_size = Vector2(170, 36)
	camp_codice_edit.add_theme_color_override("font_placeholder_color", Tema.INK_FAINT)
	rc3.add_child(camp_codice_edit)
	var bcod := Button.new()
	bcod.text = "Riprendi con codice (altro dispositivo)"
	bcod.custom_minimum_size = Vector2(0, 36)
	bcod.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Tema.tasto_carta(bcod, true)
	bcod.pressed.connect(_riprendi_campagna_codice)
	rc3.add_child(bcod)
	camp_lbl = _lbl_carta("", 14)
	camp_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	camp_lbl.custom_minimum_size = Vector2(300, 0)
	cv.add_child(camp_lbl)
	# --- messaggi e crediti
	menu_msg = Label.new()
	menu_msg.add_theme_color_override("font_color", Tema.GOLD_HI)
	menu_msg.add_theme_font_size_override("font_size", 17)
	menu_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(menu_msg)
	var cred := Label.new()
	cred.text = "Gioco originale di Stephen Rangazas, GMT Games (2023). Versione digitale per uso personale."
	cred.add_theme_color_override("font_color", Tema.TEXT_DIM)
	cred.add_theme_font_size_override("font_size", 13)
	cred.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(cred)


func _stile_check(c: CheckBox) -> void:
	c.add_theme_color_override("font_color", Tema.INK)
	c.add_theme_color_override("font_hover_color", Tema.NAVY)
	c.add_theme_color_override("font_pressed_color", Tema.INK)
	c.add_theme_color_override("font_hover_pressed_color", Tema.NAVY)
	c.add_theme_font_size_override("font_size", 16)
	for sty in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
		c.add_theme_stylebox_override(sty, StyleBoxEmpty.new())


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
				b.text = "Riprendi %s (questo dispositivo)%s" % [nome, "" if FileAccess.file_exists(_file_salva(gioco_id)) else " (nessuna)"]
				b.disabled = not FileAccess.file_exists(_file_salva(gioco_id))
			else:
				b.text = "Riprendi %s (Firebase)" % nome
		if b.has_meta("ins_btn"):
			b.text = "Io %s contro l'IA" % GIOCHI[gioco_id]["ins"]


func _controllo_da_modo(modo: String) -> Dictionary:
	match modo:
		"brit":
			return {"brit": "umano", "ins": "ia"}
		"ins":
			return {"brit": "ia", "ins": "umano"}
		"demo":
			return {"brit": "ia", "ins": "ia"}
	return {"brit": "umano", "ins": "umano"}


func _nuova_locale(modo: String) -> void:
	campagna = {}
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
	var o2 := _opz_partita(gioco_id)
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
	btn_salva_online = bs
	btn_campagna = Button.new()
	btn_campagna.text = "Campagna"
	btn_campagna.tooltip_text = "Situazione della campagna: Prestigio, esiti, eventi"
	btn_campagna.custom_minimum_size = Vector2(110, 44)
	btn_campagna.pressed.connect(func(): _mostra_campagna(true))
	btn_campagna.visible = false
	th.add_child(btn_campagna)
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
	pannello = VBoxContainer.new()
	pannello.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pannello.add_theme_constant_override("separation", 8)
	dx.add_child(pannello)
	# riquadro della domanda: occupa lo spazio che resta e scorre al suo interno
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pannello.add_child(sc)
	var dom := VBoxContainer.new()
	dom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dom.add_theme_constant_override("separation", 8)
	sc.add_child(dom)
	banner = PanelContainer.new()
	dom.add_child(banner)
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
	lbl_domanda.custom_minimum_size = Vector2(370, 0)
	bv.add_child(lbl_domanda)
	box_opz = GridContainer.new()
	box_opz.columns = 1
	box_opz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box_opz.add_theme_constant_override("h_separation", 6)
	box_opz.add_theme_constant_override("v_separation", 6)
	dom.add_child(box_opz)
	# blocco fisso in basso: carta a sinistra, Iniziativa e Capacità a destra
	var sep := HSeparator.new()
	pannello.add_child(sep)
	var fisso := HBoxContainer.new()
	fisso.custom_minimum_size = Vector2(0, 300)
	fisso.add_theme_constant_override("separation", 10)
	pannello.add_child(fisso)
	var cc := VBoxContainer.new()
	cc.add_theme_constant_override("separation", 2)
	fisso.add_child(cc)
	cc.add_child(_titoletto("Carta in gioco"))
	carta_tex = TextureRect.new()
	carta_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	carta_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	carta_tex.custom_minimum_size = Vector2(190, 266)
	carta_tex.mouse_filter = Control.MOUSE_FILTER_STOP
	carta_tex.tooltip_text = "Clicca per ingrandire"
	carta_tex.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: _mostra_carta(_carta_mostrata))
	cc.add_child(carta_tex)
	var dxv := VBoxContainer.new()
	dxv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dxv.add_theme_constant_override("separation", 3)
	fisso.add_child(dxv)
	dxv.add_child(_titoletto("Iniziativa"))
	iniz_box = VBoxContainer.new()
	iniz_box.add_theme_constant_override("separation", 3)
	dxv.add_child(iniz_box)
	lbl_carta = _lbl_carta("", 15)
	lbl_carta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dxv.add_child(lbl_carta)
	dxv.add_child(_titoletto("Capacità"))
	var csc := ScrollContainer.new()
	csc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	csc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dxv.add_child(csc)
	cap_box = VBoxContainer.new()
	cap_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	csc.add_child(cap_box)
	# finestre
	fine_dlg = AcceptDialog.new()
	fine_dlg.title = "Fine della partita"
	fine_dlg.ok_button_text = "Torna al menu"
	fine_dlg.confirmed.connect(_ok_fine)
	add_child(fine_dlg)
	fine_txt = RichTextLabel.new()
	fine_txt.bbcode_enabled = true
	fine_txt.fit_content = false
	fine_txt.scroll_active = true
	fine_txt.custom_minimum_size = Vector2(640, 440)
	fine_txt.add_theme_color_override("default_color", Tema.INK)
	fine_txt.add_theme_font_override("normal_font", Tema.serif())
	fine_txt.add_theme_font_override("bold_font", Tema.titolo())
	fine_txt.add_theme_font_size_override("normal_font_size", 18)
	fine_txt.add_theme_font_size_override("bold_font_size", 26)
	fine_dlg.add_child(fine_txt)
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
	camp_scr.visible = false
	var in_camp: bool = o2.has("campagna")
	btn_campagna.visible = in_camp
	btn_salva_online.visible = not in_camp
	(partita.find_child("Sotto", true, false) as Label).text = "%s %s · Britannici contro %s%s" % [GIOCHI[g]["nome"], GIOCHI[g]["anni"], GIOCHI[g]["ins"], " · variante avanzata" if o2.get("avanzata", false) else ""]
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
	var at := m.atto_corrente()
	if m.in_campagna() and at.get("t", "") == "camp" and at.get("passo", "") in ["evento", "inizio"] and s["camp"].has("ultimo"):
		cid = s["camp"]["ultimo"]
	carta_tex.texture = _tex_carta(cid)
	_carta_mostrata = cid
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
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size = Vector2(150, 30)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.tooltip_text = "Clicca per vedere la carta"
		Tema.tasto_carta(b)
		b.add_theme_font_size_override("font_size", 15)
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
	if cid.begins_with("E") and cid.length() <= 3:
		return load("res://assets/carte/campagna_%s.webp" % cid)
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
	if m.in_campagna():
		var c: Dictionary = s["camp"]
		var at: Array = []
		for k in c["attivi"]:
			at.append(Campagna.dati_campagna().get(k, {}).get("titolo", k))
		t.append("[color=#f0cf6e]Codice campagna: [b]%s[/b]%s[/color]" % [str(campagna.get("codice", "")), "" if campagna.is_empty() else (" · salvata su Firebase" if campagna.get("cloud_ok", false) else " · salvataggio online non ancora riuscito")])
		t.append("[color=#f0cf6e][b]Campagna End of Empire[/b] · partita %d di 4 · Prestigio imperiale [b]%d[/b]/15 · Politica: %s%s%s[/color]" % [Campagna.ORDINE.find(g) + 1, int(c["prestigio"]), Campagna.NOMI_POLITICA[c["politica"]], (" · in corso: " + ", ".join(at)) if not at.is_empty() else "", (" · %s sulla carta" % m.pz(int(c["truppe_carta"]), "t")) if int(c["truppe_carta"]) > 0 else ""])
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
	box_opz.columns = 1 if lunghe else (5 if num else 2)
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
		var passivo: bool = (v is String and v in ["fine", "passa", "no", "nessuna"]) or (v is int and v < 0)
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
	_dlg_info = false
	fine_dlg.title = "Fine della partita"
	var fine: Dictionary = m.s["fine"]
	var v: String = fine.get("v", "")
	var chi := "Vittoria britannica" if v == "brit" else ("Vittoria " + m.nome_faz("ins") if v == "ins" else "Pareggio")
	var col := Tema.NAVY if v == "brit" else (Tema.RED if v == "ins" else Tema.INK)
	var t := "[center][b][color=#%s]%s[/color][/b][/center]\n" % [col.to_html(false), chi]
	t += "[center][i]%s[/i][/center]\n\n" % str(fine.get("m", ""))
	t += "[b]Situazione finale[/b]\n"
	t += "Volontà Politica britannica: %d (scala 0-%d)\n" % [int(m.s["pw"]), int(m.s["pw_max"])]
	t += "Carte Propaganda risolte: %d di %d\n" % [int(m.s["prop_fatte"]), int(m.s["prop_tot"])]
	t += "Carte giocate: %d\n" % (m.s["giocate"] as Array).size()
	if m.cellule():
		t += "\nCondizioni: vince l'insorto se la Volontà Politica scende a 0; il Britannico se supera l'ultima Propaganda.\n"
	else:
		t += "\nCondizioni: il Britannico vince con Volontà Politica 18 o più, l'insorto con 2 o meno; a fine mazzo decide il confronto con 10.\n"
	# calcolo dell'ultima Propaganda, preso dal registro
	var reg: Array = []
	var rx := RegEx.create_from_string("\\[[^\\]]*\\]")
	for l in registro_fisso:
		reg.append(rx.sub(str(l), "", true))
	var da := -1
	for i in range(reg.size() - 1, -1, -1):
		if str(reg[i]).begins_with("— Carta Propaganda"):
			da = i
			break
	if da >= 0:
		t += "\n[b]Ultima Propaganda[/b]\n"
		for i in range(da + 1, reg.size()):
			var r := str(reg[i]).strip_edges()
			if r == "" or r.begins_with("FINE PARTITA"):
				continue
			t += "• " + r + "\n"
	fine_dlg.ok_button_text = "Torna al menu"
	if not campagna.is_empty() and m.in_campagna():
		t += "\n[b]Campagna[/b]\n" + _fine_campagna()
		fine_dlg.ok_button_text = "Situazione della campagna"
	else:
		_cancella_locale()
	fine_dlg.dialog_text = ""
	fine_txt.text = t
	fine_txt.scroll_to_line(0)
	fine_dlg.popup_centered(Vector2(680, 560))


func _torna_menu() -> void:
	if online and stanza != "":
		rete.remember_room("")
	online = false
	stanza = ""
	partita.visible = false
	menu.visible = true
	m = null
	_aggiorna_tasti_menu()
	_aggiorna_menu_campagna()


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
	if not campagna.is_empty():
		_salva_campagna()
		_salva_campagna_cloud()
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
	campagna = {}
	controllo = d.get("controllo", {"brit": "umano", "ins": "ia"})
	online = false
	avvia(str(d["gioco"]), int(d["seme"]), d.get("opz", {}), d.get("atti", []), [])


var _cloud_occupato := false


## Su Firebase c'è un salvataggio per giocatore: vi teniamo una partita per ciascuno dei quattro giochi.
func _salva_cloud(silenzioso: bool = false) -> void:
	if online or m == null or _cloud_occupato:
		return
	if not campagna.is_empty() and campagna.has("codice"):
		if not silenzioso:
			info_lbl.text = "Salvataggio della campagna %s su Firebase…" % campagna["codice"]
		await _salva_campagna_cloud()
		if not silenzioso:
			info_lbl.text = ("Campagna %s salvata su Firebase: riprendila da qualsiasi dispositivo con questo codice." % campagna["codice"]) if campagna.get("cloud_ok", false) else "Salvataggio online non riuscito: " + rete.last_error
	_cloud_occupato = true
	if not silenzioso:
		info_lbl.text = "Salvataggio online in corso…"
	var tutti = await rete.carica_partita()
	if not (tutti is Dictionary) or tutti.has("gioco"):
		tutti = {}
	if not campagna.is_empty():
		campagna["atti"] = atti
		tutti["campagna"] = campagna
	else:
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
	var cfg := {"gioco": gioco_id, "seme": sm, "host": fazione, "opz": _opz_partita(gioco_id)}
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
	campagna = {}
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


# ================================================================ CAMPAGNA END OF EMPIRE

const FILE_CAMPAGNA := "user://britishway_campagna.json"


func _nuova_campagna(modo: String) -> void:
	var early: Array = []
	var late: Array = []
	for i in range(1, 10):
		early.append("E%d" % i)
		late.append("E%d" % (i + 9))
	early.shuffle()
	late.shuffle()
	campagna = {"codice": _nuovo_codice_campagna(), "seme": rng.randi() % 100000000 + 1, "controllo": _controllo_da_modo(modo), "prewar": "caso" if camp_prewar else 0, "avanzata": camp_avanzata,
		"prestigio": 13, "esiti": {}, "early": early, "late": late, "indice": 0, "prev": "", "correnti": [], "atti": []}
	online = false
	_salva_campagna()
	_mostra_campagna(false)


func _avvia_gioco_campagna() -> void:
	if not campagna.has("codice"):
		campagna["codice"] = _nuovo_codice_campagna()
	var k := int(campagna["indice"])
	var g: String = Campagna.ORDINE[k]
	if (campagna["correnti"] as Array).is_empty():
		var mazzo: Array = campagna["early"] if k < 2 else campagna["late"]
		campagna["correnti"] = mazzo.slice(0, 3)
		mazzo.assign(mazzo.slice(3))
		if k == 1:
			campagna["early"] = []
	controllo = campagna["controllo"]
	var o2 := {"campagna": {"prestigio": int(campagna["prestigio"]), "eventi": campagna["correnti"], "prev": campagna["prev"], "prewar": campagna["prewar"]}}
	if g == "cipro" and campagna.get("avanzata", false):
		o2["avanzata"] = true
	_seleziona_gioco(g)
	avvia(g, int(campagna["seme"]) + k * 1009, o2, campagna.get("atti", []))


func _salva_campagna() -> void:
	if campagna.is_empty():
		return
	campagna["atti"] = atti
	var f := FileAccess.open(FILE_CAMPAGNA, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(campagna))


func _riprendi_campagna(cloud: bool) -> void:
	var d = null
	if cloud:
		var fl := FileAccess.open(FILE_CAMPAGNA, FileAccess.READ)
		var loc = JSON.parse_string(fl.get_as_text()) if fl else null
		var code: String = str(loc.get("codice", "")) if loc is Dictionary else ""
		if code == "":
			menu_msg.text = "Su questo dispositivo non c'è un codice di campagna: scrivilo nella casella e premi «Riprendi con codice»."
			return
		menu_msg.text = "Carico la campagna %s da Firebase…" % code
		d = await rete.carica_campagna(code)
		if d is Dictionary:
			d["codice"] = code
	else:
		var f := FileAccess.open(FILE_CAMPAGNA, FileAccess.READ)
		if f:
			d = JSON.parse_string(f.get_as_text())
	if not (d is Dictionary) or not d.has("indice"):
		menu_msg.text = "Nessuna campagna da riprendere."
		return
	campagna = d
	online = false
	if int(d["indice"]) >= 4 or (d.get("atti", []) as Array).is_empty():
		_mostra_campagna(false)
	else:
		_avvia_gioco_campagna()


func _aggiorna_menu_campagna() -> void:
	if camp_lbl == null:
		return
	var f := FileAccess.open(FILE_CAMPAGNA, FileAccess.READ)
	var d = JSON.parse_string(f.get_as_text()) if f else null
	if d is Dictionary and d.has("indice"):
		var k := int(d["indice"])
		if k >= 4:
			camp_lbl.text = "Ultima campagna conclusa con Prestigio imperiale %d: %s." % [int(d["prestigio"]), _esito_campagna(int(d["prestigio"]))]
		else:
			camp_lbl.text = "Campagna salvata (codice %s): Prestigio imperiale %d, prossima partita %s." % [str(d.get("codice", "-")), int(d["prestigio"]), GIOCHI[Campagna.ORDINE[k]]["nome"]]
	else:
		camp_lbl.text = ""


func _esito_campagna(p: int) -> String:
	if p >= 11:
		return "Ritirata ordinata, vittoria britannica"
	if p >= 5:
		return "Vento del cambiamento (esito storico)"
	return "Fuga dalle colonie, vittoria degli insorti"


## Fine di una partita di campagna: aggiorna Prestigio ed esiti e propone la partita successiva.
func _fine_campagna() -> String:
	var g: String = m.gioco()
	var es: String = m.s["camp"]["esito"]
	campagna["esiti"][g] = es
	if not campagna.has("storia"):
		campagna["storia"] = []
	var fine: Dictionary = m.s["fine"]
	campagna["storia"].append({"g": g, "esito": es, "politica": str(m.s["camp"]["politica"]), "p0": int(campagna["prestigio"]),
		"p1": int(m.s["camp"]["prestigio"]), "eventi": (m.s["camp"].get("pescati", []) as Array).duplicate(), "prewar": int(m.s["camp"]["prewar"]),
		"variazioni": (m.s["camp"].get("variazioni", []) as Array).duplicate(), "v": str(fine.get("v", "")), "motivo": str(fine.get("m", "")), "pw": int(m.s["pw"])})
	campagna["prestigio"] = int(m.s["camp"]["prestigio"])
	campagna["prev"] = es
	campagna["indice"] = int(campagna["indice"]) + 1
	campagna["correnti"] = []
	campagna["atti"] = []
	atti = []
	_salva_campagna()
	_salva_campagna_cloud()
	var t := "Campagna %s: %s si chiude con %s. Prestigio imperiale ora %d." % [str(campagna.get("codice", "")), GIOCHI[g]["nome"], Campagna.NOMI_ESITO[es], int(campagna["prestigio"])]
	if int(campagna["indice"]) >= 4:
		t += "\n\nFINE DELLA CAMPAGNA: %s." % _esito_campagna(int(campagna["prestigio"]))
	else:
		t += "\n\nProssima partita: %s." % GIOCHI[Campagna.ORDINE[int(campagna["indice"])]]["nome"]
	return t


func _ok_fine() -> void:
	if _dlg_info:
		_dlg_info = false
		fine_dlg.title = "Fine della partita"
		return
	if not campagna.is_empty() and m != null and m.in_campagna():
		_mostra_campagna(false)
	else:
		_torna_menu()


## Codice di campagna: 6 caratteri senza quelli che si confondono (0/O, 1/I/L).
func _nuovo_codice_campagna() -> String:
	var alfabeto := "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
	var c := ""
	for i in 6:
		c += alfabeto[rng.randi() % alfabeto.length()]
	return c


## Salva la campagna su Firebase sotto il suo codice (dopo ogni atto; se un salvataggio è in corso, ne fa un altro alla fine).
func _salva_campagna_cloud() -> void:
	if campagna.is_empty() or not campagna.has("codice"):
		return
	if _camp_cloud_occupato:
		_camp_cloud_di_nuovo = true
		return
	_camp_cloud_occupato = true
	while true:
		_camp_cloud_di_nuovo = false
		var copia := campagna.duplicate(true)
		copia["atti"] = atti.duplicate(true)
		copia["salvata"] = Time.get_datetime_string_from_system()
		var ok = await rete.salva_campagna(str(campagna["codice"]), copia)
		campagna["cloud_ok"] = ok
		if not _camp_cloud_di_nuovo:
			break
	_camp_cloud_occupato = false
	if m != null and partita.visible:
		stato_lbl.text = _testo_stato()


func _riprendi_campagna_codice() -> void:
	var code := camp_codice_edit.text.strip_edges().to_upper()
	if code.length() != 6:
		menu_msg.text = "Il codice della campagna ha 6 caratteri."
		return
	menu_msg.text = "Carico la campagna %s da Firebase…" % code
	var d = await rete.carica_campagna(code)
	if not (d is Dictionary) or not d.has("indice"):
		menu_msg.text = "Nessuna campagna con il codice %s.%s" % [code, ("" if rete.last_error == "" else " (" + rete.last_error + ")")]
		return
	if int(d["indice"]) >= 4:
		menu_msg.text = "La campagna %s è già conclusa (Prestigio imperiale %d)." % [code, int(d["prestigio"])]
		return
	campagna = d
	campagna["codice"] = code
	online = false
	_avvia_gioco_campagna()


# ================================================================ SCHERMATA DELLA CAMPAGNA

func _costruisci_schermata_campagna() -> void:
	camp_scr = Control.new()
	camp_scr.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_scr.visible = false
	add_child(camp_scr)
	var bg := ColorRect.new()
	bg.color = Tema.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_scr.add_child(bg)
	var h := HBoxContainer.new()
	h.set_anchors_preset(Control.PRESET_FULL_RECT)
	h.offset_left = 10
	h.offset_top = 10
	h.offset_right = -10
	h.offset_bottom = -10
	h.add_theme_constant_override("separation", 10)
	camp_scr.add_child(h)
	plancia = PlanciaCampagna.new()
	plancia.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	plancia.size_flags_vertical = Control.SIZE_EXPAND_FILL
	plancia.gioco_cliccato.connect(_scheda_partita_campagna)
	h.add_child(plancia)
	var dx := PanelContainer.new()
	dx.custom_minimum_size = Vector2(430, 0)
	dx.add_theme_stylebox_override("panel", Tema.carta(12))
	h.add_child(dx)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	dx.add_child(v)
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(sc)
	camp_info = VBoxContainer.new()
	camp_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	camp_info.add_theme_constant_override("separation", 4)
	sc.add_child(camp_info)
	camp_btn_gioca = Button.new()
	camp_btn_gioca.custom_minimum_size = Vector2(0, 48)
	Tema.tasto_carta(camp_btn_gioca, true)
	camp_btn_gioca.pressed.connect(_camp_avanti)
	v.add_child(camp_btn_gioca)
	camp_btn_menu = Button.new()
	camp_btn_menu.text = "Torna al menu"
	camp_btn_menu.custom_minimum_size = Vector2(0, 38)
	Tema.tasto_carta(camp_btn_menu)
	camp_btn_menu.pressed.connect(func():
		camp_scr.visible = false
		_torna_menu())
	v.add_child(camp_btn_menu)


## Mostra la plancia della campagna. dal_gioco: aperta durante una partita (il tasto principale torna alla partita).
func _mostra_campagna(dal_gioco: bool) -> void:
	if campagna.is_empty():
		return
	_camp_dal_gioco = dal_gioco
	var k := int(campagna.get("indice", 0))
	var st: Array = campagna.get("storia", [])
	var pross: String = Campagna.ORDINE[k] if k < 4 else ""
	var prest := int(campagna["prestigio"])
	if dal_gioco and m != null and m.in_campagna():
		prest = int(m.s["camp"]["prestigio"])
	plancia.imposta(st, prest, pross)
	for c in camp_info.get_children():
		c.queue_free()
	camp_info.add_child(_lbl_carta("Situazione della campagna", 26, true))
	var cod := _lbl_carta("Codice %s · %s" % [str(campagna.get("codice", "-")), _descr_controllo(campagna.get("controllo", {}))], 15)
	cod.add_theme_color_override("font_color", Tema.INK_DIM)
	camp_info.add_child(cod)
	var p := _lbl_carta("Prestigio imperiale: %d" % prest, 22)
	camp_info.add_child(p)
	var es := _lbl_carta(("Esito finale: " if k >= 4 else "Se finisse ora: ") + _esito_campagna(prest), 17)
	es.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	es.add_theme_color_override("font_color", Tema.NAVY if prest >= 11 else (Tema.RED if prest <= 4 else Tema.INK))
	camp_info.add_child(es)
	if dal_gioco and m != null and m.in_campagna():
		var ora := _lbl_carta("In corso: %s, Politica «%s», Volontà Politica %d." % [GIOCHI[m.gioco()]["nome"], Campagna.NOMI_POLITICA[m.s["camp"]["politica"]], int(m.s["pw"])], 16)
		ora.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		camp_info.add_child(ora)
	camp_info.add_child(HSeparator.new())
	for i in 4:
		var g: String = Campagna.ORDINE[i]
		var e := {}
		for x in st:
			if x["g"] == g:
				e = x
		_riga_partita_campagna(g, e, i == k)
	# tasti
	if dal_gioco:
		camp_btn_gioca.text = "Torna alla partita"
	elif k >= 4:
		camp_btn_gioca.text = "Campagna conclusa: torna al menu"
	else:
		camp_btn_gioca.text = ("Inizia la campagna: " if k == 0 and (campagna.get("atti", []) as Array).is_empty() else "Gioca la prossima partita: ") + GIOCHI[pross]["nome"]
	camp_btn_menu.visible = not dal_gioco and k < 4
	menu.visible = false
	partita.visible = false
	camp_scr.visible = true


func _descr_controllo(c: Dictionary) -> String:
	var b: String = c.get("brit", "umano")
	var i: String = c.get("ins", "umano")
	if b == "ia" and i == "ia":
		return "IA contro IA"
	if b == "umano" and i == "umano":
		return "due giocatori"
	return "tu Britannici contro l'IA" if b == "umano" else "tu insorti contro l'IA"


func _riga_partita_campagna(g: String, e: Dictionary, prossima: bool) -> void:
	var t := _lbl_carta(GIOCHI[g]["nome"] + "  " + GIOCHI[g]["anni"], 21, true)
	camp_info.add_child(t)
	var righe: Array = []
	if e.is_empty():
		righe.append("Prossima partita." if prossima else "Da giocare.")
	else:
		righe.append("Esito: %s · Politica «%s»" % [Campagna.NOMI_ESITO[e["esito"]], Campagna.NOMI_POLITICA.get(e["politica"], e["politica"])])
		righe.append("Prestigio imperiale: da %d a %d" % [int(e["p0"]), int(e["p1"])])
		if str(e.get("motivo", "")) != "":
			righe.append(str(e["motivo"]))
		if int(e.get("prewar", 0)) > 0:
			righe.append("Tabella pre-bellica (%d): %s" % [int(e["prewar"]), Campagna.PREBELLICHE[g][int(e["prewar"]) - 1]])
		for vv in e.get("variazioni", []):
			righe.append("Prestigio %+d: %s" % [int(vv["d"]), str(vv["m"])])
	var l := _lbl_carta("\n".join(righe), 15)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(380, 0)
	l.add_theme_color_override("font_color", Tema.INK_DIM if e.is_empty() else Tema.INK)
	camp_info.add_child(l)
	var ev: Array = e.get("eventi", []) if not e.is_empty() else []
	if ev.is_empty() and prossima and _camp_dal_gioco and m != null and m.in_campagna() and m.gioco() == g:
		ev = m.s["camp"].get("pescati", [])
	if not ev.is_empty():
		var gr := HFlowContainer.new()
		gr.add_theme_constant_override("h_separation", 4)
		gr.add_theme_constant_override("v_separation", 4)
		camp_info.add_child(gr)
		var dc := Campagna.dati_campagna()
		for id in ev:
			var b := Button.new()
			b.text = "%s %s" % [id, dc.get(id, {}).get("titolo", "")]
			b.tooltip_text = "Evento di campagna: clicca per vedere la carta"
			b.custom_minimum_size = Vector2(0, 30)
			Tema.tasto_carta(b)
			b.add_theme_font_size_override("font_size", 15)
			b.pressed.connect(_mostra_carta.bind(id))
			gr.add_child(b)
	camp_info.add_child(HSeparator.new())


func _scheda_partita_campagna(g: String) -> void:
	for x in campagna.get("storia", []):
		if x["g"] == g:
			menu_msg.text = ""
			_mostra_carta_gioco_info(g, x)
			return


func _mostra_carta_gioco_info(g: String, e: Dictionary) -> void:
	fine_dlg.title = "Campagna: " + GIOCHI[g]["nome"]
	var t := "[center][b]%s[/b][/center]\n[center][i]%s[/i][/center]\n\n" % [GIOCHI[g]["nome"], str(e.get("motivo", ""))]
	t += "Esito: %s con Politica «%s»\nVolontà Politica finale: %d\nPrestigio imperiale: da %d a %d\n" % [Campagna.NOMI_ESITO[e["esito"]], Campagna.NOMI_POLITICA.get(e["politica"], ""), int(e.get("pw", 0)), int(e["p0"]), int(e["p1"])]
	var dc := Campagna.dati_campagna()
	if not (e.get("eventi", []) as Array).is_empty():
		t += "\n[b]Eventi di campagna[/b]\n"
		for id in e["eventi"]:
			t += "• %s %s\n" % [id, dc.get(id, {}).get("titolo", "")]
	fine_txt.text = t
	fine_dlg.ok_button_text = "Chiudi"
	_dlg_info = true
	fine_dlg.popup_centered(Vector2(680, 480))


func _camp_avanti() -> void:
	if _camp_dal_gioco:
		camp_scr.visible = false
		partita.visible = true
		return
	if int(campagna.get("indice", 4)) >= 4:
		camp_scr.visible = false
		_torna_menu()
		return
	camp_scr.visible = false
	_avvia_gioco_campagna()


## Opzioni di regola scelte nel menu per una nuova partita.
func _opz_partita(g: String) -> Dictionary:
	var o2 := {}
	if g == "malesia" and opz_menu.get("lungo", false):
		o2["lungo"] = true
	if g == "cipro" and opz_menu.get("avanzata", false):
		o2["avanzata"] = true
	return o2
