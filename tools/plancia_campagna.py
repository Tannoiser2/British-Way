"""Ricompone in italiano la plancia «End of Empire» del modulo TTS.
Uso: python3 tools/plancia_campagna.py <immagine originale> assets/mappe/campagna.webp
Le coordinate si riferiscono all'immagine originale (1534x1190)."""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

src, dst = sys.argv[1], sys.argv[2]
im = Image.open(src).convert("RGB")
assert im.size == (1534, 1190), im.size
d = ImageDraw.Draw(im)
F = "assets/fonts/"
def f(nome, px):
    return ImageFont.truetype(F + nome, px)
CARTA = (251, 248, 229)
INK = (40, 30, 22)

def testo_righe(x, y, righe, interl=4):
    """righe: lista di (testo, font, colore)"""
    for t, fo, col in righe:
        if t:
            d.text((x, y), t, font=fo, fill=col)
        y += (fo.size if t else fo.size * 0.5) + interl
    return y

# --- riquadro «Procedura della campagna»
d.rectangle((1162, 170, 1488, 622), fill=CARTA)
tit = f("CormorantSC-Bold.ttf", 25)
gr = f("EBGaramond.ttf", 19)
it = f("EBGaramond-Italic.ttf", 20)
testo_righe(1178, 178, [
    ("Procedura della campagna", tit, INK), ("", gr, INK),
    ("Ordine di gioco:", it, INK),
    ("Palestina, Malesia, Kenya, Cipro.", gr, INK), ("", gr, INK),
    ("Tabelle pre-belliche (5.0):", it, INK),
    ("All'inizio di ogni partita si tira sulla", gr, INK),
    ("tabella pre-bellica e se ne applica", gr, INK),
    ("l'esito (facoltativo).", gr, INK), ("", gr, INK),
    ("Politica coloniale (3.1):", it, INK),
    ("Alla fine della prima Fase di Reset", gr, INK),
    ("il Britannico sceglie la Politica", gr, INK),
    ("coloniale, prima di pescare un", gr, INK),
    ("Evento di campagna.", gr, INK), ("", gr, INK),
    ("Eventi di campagna (4.0):", it, INK),
    ("Se ne pesca uno all'inizio di ogni", gr, INK),
    ("partita e alla fine di ogni Reset.", gr, INK),
], 3)

# --- riquadro «Esito della campagna»
d.rectangle((1162, 636, 1488, 876), fill=CARTA)
testo_righe(1178, 646, [
    ("Esito della campagna (3.3)", tit, INK), ("", gr, INK),
    ("Prestigio imperiale 11-15:", it, INK),
    ("Ritirata ordinata", gr, INK), ("", gr, INK),
    ("Prestigio imperiale 5-10:", it, INK),
    ("Vento del cambiamento (storico)", gr, INK), ("", gr, INK),
    ("Prestigio imperiale 0-4:", it, INK),
    ("Fuga dalle colonie", gr, INK),
], 2)

# --- tre politiche coloniali
POL = [
    ((50, 897, 158, 1005), (168, 896, 512, 1010), "Tenere\nduro", "Politica «Tenere duro» (3.1):", [2, 1, -3, -5]),
    ((537, 897, 645, 1005), (655, 896, 1000, 1010), "Mantenere\nla rotta", "Politica «Mantenere la rotta» (3.1):", [1, 0, -2, -4]),
    ((1024, 897, 1132, 1005), (1142, 896, 1487, 1010), "Conces-\nsioni", "Politica «Concessioni» (3.1):", [0, -1, -1, -3]),
]
tb = f("EBGaramond.ttf", 20)
ti = f("EBGaramond-Italic.ttf", 18)
tile = f("BarlowCondensed-SemiBold.ttf", 21)
for box, area, nome, titolo, v in POL:
    d.rectangle(area, fill=CARTA)
    d.text((area[0] + 4, area[1] + 6), titolo, font=f("EBGaramond.ttf", 21), fill=INK, stroke_width=0)
    y = area[1] + 34
    for lab, n in zip(["Influenza", "Uscita", "Abbandono", "Resa"], v):
        d.text((area[0] + 14, y), lab + ":", font=ti, fill=INK)
        d.text((area[0] + 120, y), "%+d Prestigio imperiale" % n if n else "+0 Prestigio imperiale", font=f("EBGaramond.ttf", 18), fill=INK)
        y += 18.5
    # etichetta sulla tessera: ripulisco l'interno e riscrivo
    x0, y0, x1, y1 = box
    d.rounded_rectangle((x0 + 8, y0 + 8, x1 - 8, y1 - 8), 4, fill=(200, 189, 150))
    d.multiline_text(((x0 + x1) / 2, (y0 + y1) / 2), nome, font=tile, fill=(255, 255, 255), anchor="mm", align="center",
                     stroke_width=1, stroke_fill=(70, 60, 45), spacing=0)

# --- etichetta del tracciato
d.rectangle((640, 1018, 890, 1046), fill=(254, 251, 232))
d.text((765, 1032), "Prestigio imperiale", font=f("EBGaramond.ttf", 22), fill=INK, anchor="mm")

# --- legenda (cartiglio)
d.rounded_rectangle((714, 680, 1010, 846), 6, fill=CARTA, outline=(150, 130, 95), width=2)
leg = [((210, 130, 121), "Protettorato britannico nel 1945"), ((194, 97, 91), "Colonia britannica nel 1945"), ((203, 141, 92), "Dominion del Commonwealth nel 1945")]
y = 690
for col, t in leg:
    d.rectangle((724, y + 4, 754, y + 34), fill=col, outline=(120, 100, 80))
    d.text((764, y + 2), t, font=f("EBGaramond.ttf", 16), fill=INK)
    d.text((764, y + 22), "(con l'anno dell'indipendenza)", font=f("EBGaramond-Italic.ttf", 15), fill=INK)
    y += 52

# --- titolo (cartiglio)
d.rounded_rectangle((520, 38, 1018, 122), 8, fill=CARTA, outline=(150, 130, 95), width=2)
d.text((769, 58), "THE BRITISH WAY · La controinsurrezione alla fine dell'Impero", font=f("EBGaramond.ttf", 17), fill=INK, anchor="mm")
d.text((769, 94), "Campagna «End of Empire»", font=f("CormorantSC-Bold.ttf", 36), fill=INK, anchor="mm")

# --- intestazioni dei riquadri coloniali
HDR = [((342, 444, 190), "Cipro"), ((453, 553, 250), "Palestina"), ((342, 444, 300), "Zona del Canale"), ((722, 824, 310), "India"),
       ((870, 972, 360), "Birmania"), ((115, 217, 475), "Costa d'Oro"), ((433, 537, 536), "Kenya"), ((920, 1022, 508), "Malesia"),
       ((405, 507, 667), "Nyasaland")]
px = im.load()
for (x0, x1, yc), nome in HDR:
    a, b = x0 + 7, x1 - 7
    for yy in range(yc - 16, yc + 16):
        cs = [px[xx, yy] for xx in range(a, b)]
        ok = [c for c in cs if c[0] > 140 and 60 < c[1] < 175 and c[2] < 150 and c[0] - c[2] > 60]
        if not ok:
            ok = cs
        m = tuple(sorted(c[i] for c in ok)[len(ok) // 2] for i in range(3))
        d.line((a, yy, b, yy), fill=m)
    w = b - a
    sz = 26
    fo = f("BarlowCondensed-SemiBold.ttf", sz)
    while d.textlength(nome, font=fo) > w - 4 and sz > 14:
        sz -= 1
        fo = f("BarlowCondensed-SemiBold.ttf", sz)
    d.text(((a + b) / 2, yc), nome, font=fo, fill=(255, 255, 255), anchor="mm", stroke_width=2, stroke_fill=(90, 45, 30))

im.save(dst, quality=90)
print("scritto", dst)
