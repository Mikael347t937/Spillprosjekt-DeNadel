# Spillprosjekt-DeNadel

## Åpne spillet

1. Hent siste versjon med **Fetch origin → Pull origin** i GitHub Desktop.
2. I Godot 4.7.2: velg **Import**, og åpne **`de-nadel/project.godot`** fra dette repositoriet.
3. Trykk **F5**. Hovedscenen er `de-nadel/scenes/main_menu.tscn`.

Startmenyen har **Start spill**, **Innstillinger**, **Om spillet** og **Avslutt**. Bruk mus eller piltastene og Enter. Esc går tilbake. Lydnivå, fullskjerm og redusert bevegelse lagres lokalt. **Start spill** åpner nivåvelgeren. **Nivå 1** er den eksisterende `de-nadel/Level.tscn`. **Nivå 2 — Lagerplassen** og **Nivå 3 — Kontrollposten** kan også velges. Hovedmenyen er fortsatt prosjektets hovedscene; bruk **Run Current Scene** for å teste et nivå direkte.

Alle spillressurser ligger inne i `de-nadel/`. Bakgrunn, lyd og fonter følger med, og fontlisensene ligger i `de-nadel/assets/fonts/`. Bakgrunnens kildebeskrivelse er i `de-nadel/docs/art-direction.md`.

## Liv og styring

- Spilleren starter med 100 liv. En fiende gjør 20 skade når den er nær nok, høyst én gang i sekundet. Bokser og vegger blokkerer nærangrepet.
- Etter et treff har spilleren et halvt sekund uten ny skade. Det hindrer flere fiender i å tømme alt livet med én gang.
- Fiender har 3 liv. Hver kule gjør 1 skade. Liv vises over figurene; spillerens liv vises også øverst til venstre.
- Ved 0 liv stopper spillet. Velg **Prøv igjen**, **Velg nivå** eller **Hovedmeny**.
- Bevegelse: **WASD** eller piltaster. Sikt med musen. Skyt med **venstre museknapp** eller **mellomrom**. Spillet bruker egne Input Map-handlinger: `move_left`, `move_right`, `move_up`, `move_down`, `shoot`.
- **Esc** åpner pausemenyen med fortsett, innstillinger, omstart, nivåvalg, hovedmeny og avslutt. Avslutning krever bekreftelse. Nivået står stille mens pausemenyen er åpen.

Endre `Max Health`, `Speed` og `Acceleration` på spilleren i Inspector. Fiendens `Max Health`, `Attack Damage` og `Attack Interval` kan også endres der. `Level.tscn` er beholdt på samme sted, og den eksisterende banen og tankgrafikken er beholdt.

Nivå 2 (`Level-2.tscn`) bygger videre på lagets eksisterende nivåutkast: to rekker med kasser og tre fiender. Nivå 3 (`Level-3.tscn`) har flere grupper med kasser, tre vanlige fiender, en boss og en annen startposisjon. De bruker samme bakke, spiller, fiender, liv og pausemeny som nivå 1. Nivå 1 bruker lagets bølgesystem med én bølge, i tillegg til fiendene som står på banen fra starten. Nivå 2 og 3 har et fast antall fiender. Når alle fiendene på et nivå er slått, stopper spillet og viser **Neste nivå** og **Hovedmeny**. Etter nivå 3 vises **Alle nivåer fullført!**, med **Spill igjen** (til nivå 1) og **Hovedmeny**. Flytt instansene direkte i Godot for å justere banene.

## Kilder og hjelpemidler

Helse, nivåvelger, pausemeny og oppsettet av nivå 2 og 3 er skrevet og tilpasset dette prosjektet med hjelp fra Codex/AI. Koden er ikke hentet fra et annet spill. Dokumentasjonen under er brukt som referanse for Godot-funksjonene:

- [Godot: Using signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) — koblingen mellom skade, liv og grensesnitt.
- [Godot: ProgressBar](https://docs.godotengine.org/en/stable/classes/class_progressbar.html) — livsmålere med `value` og `max_value`.
- [Godot: Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html) — pause av spillverdenen mens menyen fortsatt virker.

Andre ressurser som allerede var i prosjektet:

- Bakgrunnen til startmenyen er laget med imagegen fra gruppens referansebilder. Prompten og beskrivelsen ligger i `de-nadel/docs/art-direction.md`.
- Fontene **Anton** og **Barlow Condensed** er hentet fra [Google Fonts sitt åpne fontarkiv](https://github.com/google/fonts). SIL Open Font License-filene følger med i `de-nadel/assets/fonts/`.
- `city_drone.wav` og `menu_click.wav` er syntetisert for prosjektet, ikke lastet ned fra et lydbibliotek.
- `tanks-simple.png`, `tanks-terrain.png`, `specialBarrel6.png` og `bulletRed1.png` lå allerede i lagets prosjekt. Den opprinnelige nedlastingskilden er ikke dokumentert i repoet og er **ikke bekreftet**. Den som la dem inn må supplere med original lenke og lisens; vi oppgir ikke en antatt kilde som sikker.
- De eldre lenkene i prosjektloggen nedenfor er gruppens referanser. Det betyr ikke at koden over er kopiert derfra.

### Kontrollere en ren kopi

Bruk samme Godot-versjon i laget (testet med **4.7.2**) og importer `de-nadel/project.godot`. Før push av endrede nivåer: kontroller at alle refererte scener og ressurser er med i Git. Hvis en scene slettes, fjern også instansene av den fra nivåene som bruker den.

Fra repositoriets rot, med Godot tilgjengelig som `godot`:

```sh
godot --headless --editor --path de-nadel --import --quit
godot --headless --path de-nadel --script res://tests/resource_smoke.gd
godot --headless --path de-nadel --script res://tests/menu_smoke.gd
godot --headless --path de-nadel --script res://tests/enemy_smoke.gd
godot --headless --path de-nadel --script res://tests/health_smoke.gd
godot --headless --path de-nadel --script res://tests/levels_smoke.gd
godot --headless --path de-nadel --script res://tests/completion_smoke.gd
```

`resource_smoke.gd` forsøker å laste alle scener og ressursfiler. Det avdekker blant annet en nivåinstans som peker til en slettet scene. `.godot/` er en lokal hurtigbuffer og skal ikke deles gjennom Git. Bruk nøyaktig navnet `scenes` (små bokstaver) i både mapper og ressursstier, også på Mac.

### Flytte et Godot-prosjekt til et nytt repositorium

Kopier prosjektets filer og ressursmapper til mappen som inneholder den nye `project.godot`. Ta med `.uid`-filer, `.import`-innstillinger og `.gitignore`, men **ikke kopier `.git/` eller `.godot/`**. Importer deretter den nye `project.godot` i Godot. Lagre en commit og velg **Push origin** i GitHub Desktop.



Et Godot-prosjekt for MP og IT med en ferdig startmeny, inspirert av gruppens dystopiske referansebilder.


Menyelementene er vanlige, redigerbare Godot-noder. 



Samarbeid: Hver deltaker bruker sin egen GitHub-konto og en lokal klone av repositoriet.

1. Hent endringer med FETCH ORIGIN og PULL ORIGIN før du begynner.

2. Lagre endringene i Godot.

3. Kontroller filene i GitHub Desktop, skriv en kort beskrivelse og velg **Commit**.

4. Velg **push origin** for å dele endringene med laget.

Bidragsytere med skrivetilgang kan pushe til `main`, så lenge ingen grenregler hindrer dette. Egne grener og pull requests gjør det enklere å jobbe med ulike oppgaver samtidig. Avtal hvem som redigerer hvilke scener for å unngå konflikter.

Del `project.godot`, scener (`.tscn`), skript (`.gd`), `.uid`-filer og originale grafikk-/lydfiler. Innstillinger for import (`.import`) deles også, mens Godots genererte `.godot`-mappe holdes utenfor Git. Godot oppretter hurtigbufferen lokalt.

Mikael inviterer lagmedlemmer på GitHub under Settings - Collaborators - Add people. Hver deltaker må GODTA invitasjonen før vedkommende får tilgang til dette repositoriet.

§§§§ LOGG §§§§

Thu 5 Nov: Start menu, GitHub Team (Collaborations)

Har lagt IMG for Main Menu. Mikael og Kasper har også sendt mootboard med flere bilder.

**Fant reference for main menu: **
	
https://github.com/cictapps/bayanihan-res-q/blob/main/scenes/prologue.tscn 

https://ensva002.github.io/Godotkurs%202025/pages/5_-_Instanser.html

https://github.com/jpt/barlow

tribby.com/fonts/barlow


## Spille i nettleseren

Publisert prototype: [Spill De Nadel](https://de-nadel-spill.fairlemon23.chatgpt.site). Del denne adressen; `localhost` og `127.0.0.1` virker bare på utviklerens maskin.

Nettsiden ligger i `web/`. Den åpner den ekte Godot-eksporten i en iframe etter et klikk på **Spill nå**. Krever tastatur, mus, WebAssembly og WebGL 2. Nettutgaven har samme tre testbaner som prosjektet. En push til GitHub publiserer ikke nettsiden automatisk ennå.

For å bygge på nytt, installer eksportmalene for samme Godot-versjon som editoren og kjør fra repoets rot:

```sh
python3 tools/build_web.py --godot /sti/til/Godot
python3 -m http.server 8765 --directory web/dist
```

Åpne `http://localhost:8765`. På denne Macen er Godot-filen `/Users/daraa042/Downloads/Godot.app/Contents/MacOS/Godot`. `web/dist/` er generert og skal ikke committes. Last opp hele denne mappen ved publisering; ikke åpne HTML-filen direkte fra Finder. Eksporten bruker én tråd, slik at nettstedet ikke trenger spesielle isolasjonsheadere.

Nettsidens HTML/CSS/JavaScript og byggeskript er tilpasset med Codex/AI. Bakgrunn og fonter gjenbruker prosjektets ressurser og kilder over. Referanse: [Godot: Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html). En senere Steam-utgave bygges som en egen skrivebordseksport fra samme Godot-prosjekt; nettutgaven publiserer ingenting til Steam.

Nivåslutt styres av `scripts/level_flow.gd`. Neste scene settes i **Next Level** på roten av hver nivåscene. Tom verdi betyr siste nivå. `wave_manager.gd` må være ferdig med bølgen før nivået kan vinnes; også fiendene som lå i scenen fra starten teller. Pause, død og nivåslutt bruker samme HUD og tema. Denne tilpasningen er gjort med Codex/AI.

## Fiendegrafikk og boss

De tre Piskel-arkene levert av gruppen brukes som vanlige fiender. Nivå 3 har tre vakter og en boss med midlertidig grafikk, livsmåler, skudd og rykkeangrep. Kilder, balansering og hvordan designerne bytter bossgrafikk er dokumentert i [fiende- og bossguiden](de-nadel/docs/enemies-and-boss.md).
