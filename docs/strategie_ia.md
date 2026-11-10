# Strategie dei giocatori esperti e IA

Fonti consultate (novembre 2026):
- le «Strategy Guide» ufficiali in fondo ai quattro regolamenti (Joe Dewhurst, sviluppatore);
- gli articoli di Stephen Rangazas su InsideGMT (Palestina, Malesia, Kenya, Cipro, variante avanzata di Cipro);
- le recensioni di Space-Biff, Meeple Mountain e The Board Games Chronicle;
- le discussioni su BoardGameGeek (Cipro: Interrogatorio troppo forte, l'EOKA finisce in Prigione).

## Consigli comuni ai quattro giochi
- **Avere un piano**: una campagna dura in media 6 carte, cioè circa 3 turni con Operazione e Attività speciale.
- **Guardare la Propaganda**: gli effetti della Propaganda contano più dei guadagni immediati.
- **Uno-due**: dopo un'Operazione limitata si è sicuri di poter fare Operazione e Attività speciale sulla carta dopo.

## Palestina
- Irgun: sfruttare l'alleanza con l'Haganah all'inizio; sotto 3 il Terrore costa poco. Un Sabotaggio su una Ferrovia sposta 4 punti di Volontà Politica: farlo ogni campagna, poi le altre Ferrovie, poi le Città; i Distretti servono come rifugio per i Depositi. Se i Britannici mettono Coprifuoco nelle Città, colpire le Ferrovie e usare Propagandize.
- Britannici: togliere i Depositi con l'Assalto (Ricerca limitata, poi Assalto); il Coprifuoco costa meno di un Sabotaggio; lo scopo è «non perdere».

## Malesia
- MCP: espandersi presto e ovunque; sabotare i Centri economici a ogni occasione; una Base in Thailandia presto vale 4 Risorse; colpire solo quando conviene.
- Britannici: ripulire (Rastrellamento poi Assalto con Rappresaglia o Attacco aereo), mettere in sicurezza (Nuovi Villaggi e Polizia, presto), pacificare, poi passare alla Provincia successiva; Guarnigione per i Centri economici.

## Kenya
- Mau Mau: partire forte (Raduno e Giuramento, oppure Terrore e Incursione); Giuramento e Incursione non costano Risorse; restare a Nairobi e con una Base fuori dalle Giungle di montagna.
- Britannici: proteggere Nairobi e le Province non di Riserva; Rastrellare presto e spesso; Trasferire la popolazione delle Riserve; spingere i Mau Mau nelle Giungle.

## Cipro
- EOKA: prepararsi (Contrabbando di Depositi, Reclutamento, Infiltrazione della Polizia isolata) e poi colpire; tenere alta l'Opinione internazionale con Propagandize; non perdere Cellule in Prigione.
- Britannici: ciclo Intel, Pattuglia che porta in Prigione, Interrogatorio; mai Polizia isolata; Coprifuoco per mettere al sicuro le Città; ripulire le Montagne dai Depositi.

## Cosa è entrato nell'IA
I consigli sono diventati criteri di valutazione delle posizioni (`Motore.strategia_brit` in `scripts/motore.gd`).
Ogni criterio è stato provato con `tests/confronto.gd`: partite IA contro IA, 40 per configurazione,
con i criteri accesi da un solo lato. Sono rimasti solo quelli che hanno fatto vincere di più.

| Gioco | IA britannica vecchia | IA britannica nuova |
|---|---|---|
| Malesia | 10/40 | 16/40 |
| Kenya | 19/40 | 25/40 |
| Cipro | 26/40 | 28/40 |

Scartati perché peggioravano il gioco: il valore dell'iniziativa («uno-due»), i criteri per la Palestina
(Ferrovie, Depositi nei Distretti, Coprifuoco) e i criteri visti dal lato MCP e Mau Mau.
Per l'EOKA a Cipro i criteri restano accesi.

Uso: `godot --headless -s res://tests/confronto.gd -- <gioco> <partite> <simulazioni> <vv|nv|vn|nn> [seme] [criteri spenti]`
