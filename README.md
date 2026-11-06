# The British Way — versione digitale

Versione digitale (uso personale) di **The British Way: Counterinsurgency at the End of Empire** di Stephen Rangazas (GMT Games, 2023):
quattro giochi COIN per due giocatori, Britannici contro insorti.

| Gioco | Anni | Insorti | Meccaniche proprie |
|---|---|---|---|
| Palestina | 1945–1947 | Irgun | Cellule e Depositi d'armi, Intel, Prigione, Coprifuochi, Ferrovie, tracciato dell'Haganah, Detenzione di massa |
| Malesia | 1948–1960 | MCP | Risorse, Controllo, Supporto/Opposizione, Nuovi Villaggi, Centri economici, Comandanti (Gurney, Briggs, Templer) |
| Kenya | 1952–1956 | Mau Mau | Riserve kikuyu, Giungle di montagna, Popolazione trasferita, Polizia fuori gioco, tracciato della Pipeline e Indignazione |
| Cipro | 1955–1959 | EOKA | Cellule e Depositi d'armi, Intel, Prigione, Coprifuochi, Basi britanniche, Opinione internazionale |

## Come si gioca

- **Contro l'IA** con l'una o l'altra fazione, **in due sullo stesso schermo**, **IA contro IA** (dimostrazione) oppure **online**:
  chi crea la stanza sceglie la fazione e comunica il codice di 4 lettere all'avversario.
- Ogni decisione è una domanda nel pannello a destra: si risponde coi tasti o cliccando sugli spazi evidenziati sulla mappa.
  *Annulla* torna indietro di una decisione (solo nelle partite locali).
- La partita si salva da sola sul dispositivo dopo ogni turno (una per ciascun gioco) e ogni quattro turni anche su Firebase;
  *Salva online* la salva subito. Dal menu si riprende da questo dispositivo o dal salvataggio online.
- Online: se si ricarica la pagina, *Rientra nell'ultima stanza online* ricostruisce la partita dal registro della stanza.
- *Regole* apre il riassunto in italiano del gioco in corso (sequenza, Operazioni, Attività Speciali, Propaganda, vittoria).
- Le carte sono ricomposte in italiano (foto originale, testi tradotti); clicca la carta per ingrandirla.

## Struttura

- `scripts/nucleo.gd` — stato, sequenza di gioco (tracciato dell'Iniziativa a tre caselle) e domande/risposte deterministiche:
  la partita si ricostruisce sempre da seme + risposte (salvataggi, gioco online, IA).
- `scripts/regole.gd` — Operazioni e Attività Speciali dei quattro giochi; `propaganda.gd` — Round di Propaganda; `eventi.gd` — i 128 eventi.
- `scripts/motore.gd` — valutazione delle posizioni; `ia.gd` — IA a simulazioni (prova molte giocate su copie dello stato, con dadi diversi).
- `scripts/main.gd`, `mappa.gd`, `tema.gd` — interfaccia (stessa impostazione della GUI COIN di Cuba Libre); `rete.gd` — Firebase.
- `dati/` — mappe (spazi, adiacenze, preparazione) e carte in italiano; `assets/` — tabelloni, carte, segnalini, caratteri (OFL).
- `tests/sim.gd` — partite automatiche IA contro IA: `godot --headless -s res://tests/sim.gd -- tutti 3 60`;
  `tests/test_regole.gd` — prove mirate delle regole; `tests/ui_casuale.gd` — interfaccia cliccata a caso;
  `tests/online.gd` — due client contro un finto Firebase locale.

## Campagna «End of Empire»

Le quattro partite in ordine storico (Palestina, Malesia, Kenya, Cipro), contro l'IA o in due: Prestigio imperiale
(da 13, tra 0 e 15), Politica coloniale scelta dai Britannici dopo la prima Propaganda, 18 eventi di campagna
(mazzi Early e Late, carte ricomposte in italiano: tre per partita, all'inizio e dopo il primo e il secondo Reset)
e, a scelta, le tabelle pre-belliche. La campagna si salva da sola sul dispositivo e su Firebase.
Codice in `scripts/campagna.gd`; prova completa IA contro IA: `godot --headless -s res://tests/campagna.gd -- 21 40`.
La campagna è solo locale (non online).
- `tools/controlla_glifi.py` — verifica che ogni carattere usato esista nei font.

## Pubblicazione

Il workflow `Pubblica` parte a mano (Actions → Pubblica → Run workflow) o con un commit che contiene `[pubblica]`:
esporta la versione web con Godot 4.7, la pubblica su GitHub Pages e, se ci sono i segreti `CLOUDFLARE_API_TOKEN` e
`CLOUDFLARE_ACCOUNT_ID`, sulla ludoteca privata (`https://british-way.ludoteca-digitale.com/`).

Online usa il progetto Firebase della ludoteca con radice `britishway` (stanze con registro e salvataggi personali,
coperte dalla regola comune).
