## Banco di prova dell'IA: godot --headless -s res://tests/confronto.gd -- <gioco> <partite> <sim> <config>
## config: "vv" entrambi vecchi, "nv" Britannici con strategia nuova, "vn" insorti con strategia nuova, "nn" entrambi nuovi.
extends SceneTree

func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var g: String = a[0]
	var n := int(a[1])
	var nsim := int(a[2])
	var cfg: String = a[3]
	Motore.strategia = {"brit": cfg[0] == "n", "ins": cfg[1] == "n"}
	if a.size() > 5:
		Motore.spenti = a[5].split(",")
	var rng := RandomNumberGenerator.new()
	rng.seed = 777 + int(a[4]) if a.size() > 4 else 777
	var vb := 0
	var tot_pw := 0
	for k in n:
		var m := Motore.new()
		m.nuova(g, 5000 + k * 31 + (int(a[4]) * 1000 if a.size() > 4 else 0))
		var piano: Array = []
		var atti := 0
		while not m.finita() and atti < 400:
			var base: Dictionary = m.s.duplicate(true)
			var ans: Array = []
			var giri := 0
			while not m.prova(base, ans):
				giri += 1
				if giri > 300:
					m.fine_partita("pareggio", "bloccato")
					break
				ans.append(IA.rispondi(base, ans, m.need, piano, rng, nsim))
			atti += 1
		print("  partita %d: %s (%s) atti %d" % [k, m.s["fine"].get("v", ""), m.s["fine"].get("m", ""), atti])
		if m.s["fine"].get("v", "") == "brit":
			vb += 1
		tot_pw += int(m.s["pw"])
	print("RISULTATO %s %s brit %d/%d pw_medio %.1f" % [g, cfg, vb, n, float(tot_pw) / n])
	quit()
