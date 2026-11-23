# Die Nadel

## Åpne spillet

1. Hent siste versjon med **Fetch origin → Pull origin** i GitHub Desktop.
2. I Godot 4.7.2: velg **Import**, og åpne **`de-nadel/project.godot`** fra dette repositoriet.
3. Trykk **F5**. Hovedscenen er `de-nadel/scenes/main_menu.tscn`.

Startmenyen har **Start spill**, **Innstillinger**, **Om spillet** og **Avslutt**. Bruk mus eller piltastene og Enter. Esc går tilbake. Lydnivå, fullskjerm og redusert bevegelse lagres lokalt. **Start spill** åpner nivåvelgeren. **Nivå 1 — Bakgatene** er den eksisterende `de-nadel/Level.tscn`. **Nivå 2 — Lagerplassen** og **Nivå 3 — Kontrollposten** kan også velges. Hovedmenyen er fortsatt prosjektets hovedscene; bruk **Run Current Scene** for å teste et nivå direkte.

Alle spillressurser ligger inne i `de-nadel/`. Bakgrunn, lyd og fonter følger med, og fontlisensene ligger i `de-nadel/assets/fonts/`. Bakgrunnens kildebeskrivelse er i `de-nadel/docs/art-direction.md`.

## Liv og styring

- Spilleren starter med 100 liv. En fiende gjør 20 skade når den er nær nok, høyst én gang i sekundet. Bokser og vegger blokkerer nærangrepet.
- Etter et treff har spilleren et halvt sekund uten ny skade. Det hindrer flere fiender i å tømme alt livet med én gang.
- Fiender har 3 liv. Hver kule gjør 1 skade. Vanlige fiender har ingen synlig livsmåler. Spillerens liv vises kompakt øverst til venstre. Bossmåleren vises bare på tredje nivå.
- Ved 0 liv stopper spillet. Velg **Prøv igjen**, **Velg nivå** eller **Hovedmeny**.
- Bevegelse: **WASD** eller piltaster. Sikt med musen. Skyt med **venstre museknapp** eller **mellomrom**. Spillet bruker egne Input Map-handlinger: `move_left`, `move_right`, `move_up`, `move_down`, `shoot`.
- **Esc** åpner pausemenyen med fortsett, innstillinger, omstart, nivåvalg, hovedmeny og avslutt. Avslutning krever bekreftelse. Nivået står stille mens pausemenyen er åpen.

Endre `Max Health`, `Speed` og `Acceleration` på spilleren i Inspector. Fiendens `Max Health`, `Attack Damage` og `Attack Interval` kan også endres der. `Level.tscn` er beholdt på samme sted, og den eksisterende banen er beholdt. Spillerens grafikk er erstattet med gruppens retningsbestemte Piskel-figur.

Spillet har fortsatt **tre nivåer**, med én opprinnelig bane per nivå. Det er ikke lagt til ekstra arenaer. En portal øst på nivå 1 og 2 er låst mens kampen eller oppdraget pågår. Når alle vakter og eventuelle bølger er slått og oppdraget er gjort, åpnes portalen. Gå inn for å komme direkte til neste nivå; spillet stopper ikke på en mellomliggende seiersmeny.

- **Nivå 1:** slå vaktene og ta haglen før portalen åpnes.
- **Nivå 2:** slå vaktene og hent lagerlisten på den opprinnelige plassen.
- **Nivå 3:** den opprinnelige bossbanen og sprøyteburet er beholdt. Etter kampen åpnes buret, sprøytene faller ut og opptaket spilles. Sluttmenyen har **Spill igjen** og **Hovedmeny**.

Liv fylles ved nivåskifte. Mynter, ammunisjon og våpen beholdes. Omstart nullstiller kampen og lukker portalen. `Portal` er en vanlig instans av `scenes/level_portal.tscn` som kan flyttes i Godot, innenfor banens yttergrense. Koden i `scripts/level_flow.gd` styrer opplåsing og overgang; portalens `Area2D` registrerer når spilleren går inn.

Spillbildet bruker en liten livsmåler og kompakte mynt-/våpentall. Store svarte paneler, livstall over figurene og faste tastaturinstruksjoner er fjernet. Oppdragets bakgrunn står i pausemenyen. Styringen finnes under **Esc → Innstillinger**.

### Stigende vanskelighetsgrad

| Nivå | Motstandere | Samlet liv hos motstanderne | Kamp |
| --- | --- | --- | --- |
| 1 | 2 vakter + 5 i én bølge | 21 | Vanlige vakter, 95 i fart |
| 2 | 8 vakter | 31 | 3 raske, 3 vanlige og 2 tunge |
| 3 | 9 vakter + boss | 57 | Sterkere vakter og boss med kortere hvile |

Raske vakter har mindre liv og gjør mindre skade per slag. Tunge vakter tåler mer og slår hardere, men beveger seg saktere og varsler lenger før slaget. På nivå 2 og 3 oppdager vaktene spilleren fra start. Alle vanlige vakter er fortsatt langsommere enn spilleren. Begge nivåene har en ekstra ammunisjonskasse med åtte patroner. Endre verdiene på fiendeinstansene i Inspector for å justere balansen videre.

### Svart skjerm ved lokal kjøring på Mac

`node_2d.tscn` var en tom scene og er nå en instans av hovedmenyen, slik at også direkte kjøring av denne scenen viser menyen. Prosjektets hovedscene er fortsatt `scenes/main_menu.tscn`.

På maskinen vi testet ga Godots innebygde spillvindu også svart skjerm / heng. Prosjektets lokale **Embed Game** ble derfor slått av, og spillet starter i et eget vindu. Dette er en lokal editorinnstilling i `.godot/editor/project_metadata.cfg` (`game_view/embed_on_play=false`); `.godot` skal fortsatt ikke pushes. Hvis en annen Mac har samme problem, velg separat spillvindu uten verktøylinje i **Game**-arbeidsområdet. Eksporterte spill endres ikke av denne innstillingen.

## Kilder og hjelpemidler

Helse, nivåvelger, pausemeny, portalene, det kompakte HUD-et og oppsettet av nivå 2 og 3 er skrevet og tilpasset dette prosjektet med hjelp fra Codex/AI. Koden er ikke hentet fra et annet spill. Dokumentasjonen under er brukt som referanse for Godot-funksjonene:

- [Godot: Using signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) — koblingen mellom skade, liv og grensesnitt.
- [Godot: Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html) — portalen registrerer spilleren med overlapp.
- [Godot: ProgressBar](https://docs.godotengine.org/en/stable/classes/class_progressbar.html) — livsmålere med `value` og `max_value`.
- [Godot: Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html) — pause av spillverdenen mens menyen fortsatt virker.

Andre ressurser som allerede var i prosjektet:

- Den tidligere bakgrunnen til startmenyen ble laget med imagegen fra gruppens referansebilder. Den er bevart som eldre materiale; menyen bruker nå gruppens pikselby. Prompten og beskrivelsen ligger i `de-nadel/docs/art-direction.md`.
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

Publisert prototype: [Spill Die Nadel](https://de-nadel-spill.fairlemon23.chatgpt.site). Del denne adressen; `localhost` og `127.0.0.1` virker bare på utviklerens maskin.

Nettsiden ligger i `web/`. Den åpner den ekte Godot-eksporten i en iframe etter et klikk på **Spill nå**. Krever tastatur, mus, WebAssembly og WebGL 2. Nettutgaven har samme tre testbaner som prosjektet. En push til GitHub publiserer ikke nettsiden automatisk ennå.

For å bygge på nytt, installer eksportmalene for samme Godot-versjon som editoren og kjør fra repoets rot:

```sh
python3 tools/build_web.py --godot /sti/til/Godot
python3 -m http.server 8765 --directory web/dist
```


Nettsidens HTML/CSS/JavaScript og byggeskript er tilpasset med Codex/AI. Bakgrunn og fonter gjenbruker prosjektets ressurser og kilder over. Referanse: [Godot: Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html). En senere Steam-utgave bygges som en egen skrivebordseksport fra samme Godot-prosjekt; nettutgaven publiserer ingenting til Steam.

Nivåslutt styres av `scripts/level_flow.gd`. Neste scene settes i **Next Level** på roten av hver nivåscene. Tom verdi betyr siste nivå. `wave_manager.gd` må være ferdig med bølgen før nivået kan vinnes; også fiendene som lå i scenen fra starten teller. Pause, død og nivåslutt bruker samme HUD og tema. Denne tilpasningen er gjort med Codex/AI.

## Fiendegrafikk og boss

Spilleren bruker nå gruppens `Protagonist (1).png`, med forside og bakside. De eldre Piskel-arkene er bevart som midlertidig bossgrafikk. Arket med sprøyten brukes som vanlig fiende. Nivå 3 har tre vanlige fiender og Hitler som boss, med midlertidig grafikk, livsmåler, skudd og rykkeangrep. Kilder, balansering og hvordan designerne bytter bossgrafikk er dokumentert i [fiende- og bossguiden](de-nadel/docs/enemies-and-boss.md).

Retningsanimasjoner: `scripts/directional_sprite.gd` velger forside, bakside og profil etter faktisk bevegelse. Tomme Piskel-ruter er utelatt for å unngå flimring. Kjør `godot --headless --path de-nadel --script res://tests/direction_smoke.gd` for å kontrollere retninger, stillstand, hindringer og at alle rammer inneholder grafikk.

## Mynter, ammunisjon og sluttsekvens

Nivåene har nå mynter, patronkasser og en hagle. Bruk **1** og **2** for våpenvalg. Etter siste kamp åpnes et bur med sprøyter før seiersmenyen vises. Alle objektene er egne, flyttbare `.tscn`-scener, med grafikk fra `de-nadel/assets/items/loot_atlas.png`. [Veiledning for laget, kilder og kontroll](de-nadel/docs/items-and-ending.md).

## Kartgrafikk og NARKO-logo

Gruppens `verden.png` brukes nå til mørke bymiljøer på alle tre nivåer, med veier, hus og flyttbare miljøscener. Kasser har ny grafikk og beholder kollisjonen. NARKO-logoen ligger i hovedmenyen, og er fjernet fra kartene. Husene klippes langs silhuetten, og kassene er tilpasset kollisjonen på 54 × 54. Originalbilder, kilder og hvordan dere flytter/kopierer objektene i Godot er forklart i [kartguiden](de-nadel/docs/world-art.md).

## Sluttmusikk fra gruppen

`ZOOM0039_TrLR.WAV` er levert av gruppen og kopiert uendret til `de-nadel/assets/audio/victory_recording.wav` (31,09 sekunder, stereo, 44,1 kHz). Opptaket starter én gang når siste kamp er vunnet og buret åpnes. Det fortsetter gjennom sprøyteanimasjonen og seiersskjermen, selv om spillingen er pauset. **Lydnivå** regulerer volumet. Ved omstart eller retur til menyen fjernes avspilleren. Hovedmenyen bruker igjen `city_drone.wav`. Ekstern kilde/rettighetshaver er ikke oppgitt utover gruppens levering.

## Oppdrag og pikselgrafikk, 20. november

Tre nivåer har nå egne oppdrag: finn haglen, hent lagerlisten og slå bossen. Menyen bruker samme pikselgrafikk som spillet. Spilleren har et enkelt profilark, kasser har topp og side, og vakter varsler slag og går rundt dekning. Fire korte lydeffekter er lagt til. [Hvordan det er laget, hva laget kan redigere, kilder og tester](de-nadel/docs/gameplay-polish.md).

## Logo og regimemerking

Spillets riktige navn er **Die Nadel**. Menyen bruker hele logoen fra gruppens bilde `Screenshot 2026-11-20 at 11.11.04 (2).png`, bevart som `de-nadel/assets/art/die_nadel_source.png`. Det er ikke laget en ny logo med AI. To AtlasTexture-ressurser velger hele logoen og det separate sprøytesymbolet fra samme original. `die_nadel_ink.gdshader` skjuler det hvite bakgrunnspapiret og tilpasser blekkfargen til mørk bakgrunn; originalfilen endres ikke.

Regimets symbol brukes på ett flagg i nivå 1 og 2, og to ved bossens område i nivå 3. Bare utvalgte kasser har merking. `scenes/world/regime_flag.tscn` og `regime_crate.tscn` er vanlige scener som kan flyttes og kopieres i Godot. Den merkede kassen arver den eksisterende kassens kollisjon. Symbolet tilhører spillets fiendtlige regime. Det gamle Narko-merket og den gamle tittelen vises ikke samtidig med det nye menylogoet.

GitHub-adressen, prosjektmappen og eksisterende ressursstier er beholdt. Visningsnavnet og menytekstene er oppdatert til Die Nadel.

### Tekstur- og kollisjonsrettelser

Den mørke rammen rundt banen er fjernet. Den usynlige nordgrensen er flyttet ned, slik at spillerens hode ikke går inn i husrekken. Fiender og bølger starter under denne grensen. Ekstra ammunisjon i nivå 3 ligger nå fritt, uten å overlappe tønnen. En liten regimplakett er lagt på ett bygg per gate. Flagg tegnes foran grenseområdet, slik at symbolet ikke blir skåret av en stripe.

`gameplay_soak.gd` kjører bevegelse, ekte skudd, fiendeangrep, pauser og omstarter over tid. Den kontrollerer også nordgrensen og kollisjonen rundt alle kassene i nivå 2. Slike kontroller er i tillegg til de vanlige testene, ikke en garanti for at all grafikk og spillbalanse er perfekt.

Spilleren, fiender og kasser sorteres nå etter Y-posisjon. Spilleren vises foran en kasse når han står nedenfor den, og bak kassen når han står ovenfor. Det fjerner feil overlapping som tidligere kunne se ut som en ødelagt tekstur.
