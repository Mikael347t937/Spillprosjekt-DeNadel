# Die Nadel

Die Nadel er skoleprosjektet vårt i MP og IT. Det er et 2D-spill laget i Godot med GDScript. Vi spiller som en motstandsperson i en mørk by under et diktatur. Målet er å komme gjennom tre nivåer, slå vaktene og bossen og åpne lagerburet i slutten av spillet.

Vi ville ha enkel pikselgrafikk og en stil som henger sammen mellom menyen og selve spillet. Prosjektet startet med tankgrafikk, og derfor heter spillerfilene fortsatt `tanks.gd` og `tanks.tscn`. Figuren i spillet er nå et menneske. Dette er fortsatt en prototype, og vi jobber videre med grafikk, balanse og feil.

[Spill nettversjonen her](https://de-nadel-spill.fairlemon23.chatgpt.site/). Den trenger tastatur og mus. En push til GitHub oppdaterer ikke nettsiden automatisk.

## Slik starter vi prosjektet

1. Velg **Fetch origin**, og deretter **Pull origin** i GitHub Desktop hvis det finnes nye endringer.
2. Importer `de-nadel/project.godot` i Godot. Versjonen vi har testet med er **4.7.2**.
3. Velg **Run Project** for å starte fra hovedmenyen. Hovedscenen er `scenes/main_menu.tscn`.

**Run Current Scene** er til testing av scenen som er åpen i editoren. En løs gjenstand, som `shotgun.tscn`, er ikke et helt spill og kan gi et tomt spillvindu når den kjøres alene.

På Mac er standarden **⌘B** for hele prosjektet og **⌘R** for den åpne scenen. På Mac-en der vi feilsøkte 24. november, er **⌘R** endret til å kjøre hele prosjektet. **⌘⌥R** eller **F6** kjører en enkelt scene der. Dette er lokale innstillinger i Godot, og følger ikke med når andre henter prosjektet fra GitHub. De kan endres under **Godot → Editor Settings → Shortcuts**. På Windows/Linux er standarden **F5** for prosjektet og **F6** for den åpne scenen.

Hvis det innebygde spillvinduet blir svart eller henger på Mac, prøv et separat spillvindu ved å slå av **Embed Game**. Det er en annen innstilling enn valget mellom å kjøre prosjektet og én scene.

## Hva vi har i spillet

| Nivå | Oppdrag | Motstand |
| --- | --- | --- |
| 1 – Bakgatene | Finn haglen og slå alle vaktene før portalen åpnes. | 2 vakter fra start og 5 i en bølge. |
| 2 – Lagerplassen | Finn lagerlisten og rydd plassen. | 8 vakter med ulike egenskaper. |
| 3 – Kontrollposten | Slå vaktene og bossen, og åpne lagerburet. | 9 vakter og bossen. |

Det er tre nivåer, med én bane i hvert nivå. Portalen på nivå 1 og 2 er låst til kampen og oppdraget er ferdige. Da kan spilleren gå videre. Mynter, våpen og ammunisjon følger med, mens livet fylles opp igjen.

Spilleren starter med 100 liv. Fiender kan gå rundt kasser og varsler før de slår. De raske vaktene tåler mindre, mens de tunge er langsommere og tåler mer. Vi har fjernet livsmålere over vanlige fiender for å gjøre skjermen mindre rotete. Bossen på nivå 3 har egen livsmåler og både skudd og rykkeangrep. Den endelige bossgrafikken er ikke klar, så vi bruker en plassholder.

Vi kan samle mynter og haglepatroner. Mynter er foreløpig poeng; vi har ikke laget en butikk. Når siste kamp er ferdig, åpnes buret, sprøytene faller ut og lydopptaket spiller. Deretter kommer sluttskjermen.

### Styring

| Tast / knapp | Hva den gjør |
| --- | --- |
| WASD / piltaster | Bevegelse |
| Mus | Sikting |
| Venstre museknapp / mellomrom | Skyting |
| 1 / 2 | Pistol / hagle, hvis haglen er funnet |
| Esc | Pausemeny, innstillinger, omstart og avslutning |

Pistolen har ubegrenset ammunisjon. Haglen bruker patroner. Lydnivå, fullskjerm og redusert bevegelse kan endres i innstillingene og lagres lokalt.

## Hvordan prosjektet er satt opp

Alt Godot trenger ligger i `de-nadel/`. Vi bruker egne scener for fiender, kasser, våpen, mynter og portaler. Da kan vi dra dem inn i et nivå, flytte dem og kopiere dem med **⌘D / Ctrl+D**, uten å lage alt på nytt.

| Fil / mappe | Hva den brukes til |
| --- | --- |
| `de-nadel/Level.tscn` | Første nivå. Navnet er beholdt fra starten av prosjektet. |
| `de-nadel/scenes/` | Menyer, andre nivåer og gjenbrukbare objekter. |
| `de-nadel/tanks.gd` | Spilleren: bevegelse, liv og skyting. |
| `de-nadel/scripts/enemy.gd` | Vanlige fiender, bevegelse og nærangrep. |
| `de-nadel/scripts/level_flow.gd` | Sjekker oppdrag, bølger og fiender før nivået kan avsluttes. |
| `de-nadel/scripts/level_portal.gd` | Oppdager at spilleren går inn i en åpen portal. |
| `de-nadel/scripts/directional_sprite.gd` | Velger riktig animasjon og retning på figuren. |
| `de-nadel/scripts/game_audio.gd` | Spiller av korte lydeffekter. |
| `de-nadel/assets/` | Grafikk, lyd, fonter og tilhørende ressurser. |
| `de-nadel/tests/` | Automatiske sjekker av blant annet skade, menyer og nivåslutt. |
| `web/` og `tools/build_web.py` | Nettsiden og bygging av Godot-eksporten for nettleseren. |

### Level flow forklart

`level_flow.gd` er festet til roten av et nivå. `Next Level`, `Objective`, `Chapter` og `Briefing` kan endres i Inspector.

Skriptet sjekker om bølgene er ferdige, om alle fiendene er døde og om oppdraget er gjort. Alle tre vilkårene må være oppfylt. På de to første nivåene åpner det portalen. Når spilleren går inn, lagres inventaret, og HUD-et får beskjed om å bytte scene. På siste nivå venter skriptet på at buret åpnes før seiersskjermen vises. Variabelen `completed` hindrer at avslutningen starter flere ganger.

Det ligger ukrainske kommentarer over hver kodelinje i denne filen som støtte til gjennomgangen av koden. Kommentarene endrer ikke hvordan skriptet kjører.

## Samarbeid og testing

Vi bruker GitHub og GitHub Desktop til å dele prosjektet. Før vi begynner, henter vi de siste endringene. Før vi pusher, lagrer vi i Godot, ser gjennom filene i GitHub Desktop og tester det vi har endret. Vi bør avtale hvem som jobber i samme nivåscene, siden to endringer i samme `.tscn`-fil lett kan gi konflikter.

Vi deler `.gd`, `.tscn`, `.tres`, `.uid`, originale bilder og lydfiler samt `.import`-innstillinger. `.godot/` er en lokal hurtigbuffer og skal ikke pushes. Stier må ha riktig bruk av store og små bokstaver, også når det virker på en Mac.

Vi tester også manuelt: start fra menyen, spill nivåene, ta skade, dø og prøv igjen, åpne pausemenyen og gå gjennom portalene. Automatiske tester hjelper oss å oppdage feil, men sier ikke om spillet er morsomt eller om all grafikken ser riktig ut.

Disse kommandoene kjøres fra roten av repoet hvis Godot er tilgjengelig som `godot`:

```sh
godot --headless --editor --path de-nadel --import --quit
godot --headless --path de-nadel --script res://tests/resource_smoke.gd
godot --headless --path de-nadel --script res://tests/completion_smoke.gd
```

## Kilder

Vi skiller mellom filer som faktisk er lagt inn i spillet, og dokumentasjon vi bruker for å forstå Godot. En lenke til en Godot-klasse er en faglig referanse, ikke bevis for at hele skriptet er kopiert derfra. Listen er ryddet og supplert 24. november 2026 ut fra filene og notatene i prosjektet.

### Grafikk og fonter

| Ressurs i prosjektet | Hvor den kom fra / hvordan den ble laget |
| --- | --- |
| `assets/characters/protagonist.png` | Levert av gruppen som `Protagonist (1).png`. Originalarket er beholdt. |
| `assets/characters/syringe_enemy.png` | Levert av gruppen som `Vanlig dag på oslo s 3 (2).png`. Brukes til vanlig fiende. |
| `assets/characters/player_front.png`, `player_back.png`, `player_side.png` | Gruppens tidligere Piskel-ark. De er bevart og brukes som midlertidig bossgrafikk. |
| `assets/world/verden.png` | Levert av gruppen: bakke, hus og rekvisitter. Utsnitt brukes i egne Godot-scener. |
| `assets/art/die_nadel_source.png` | Oppdatert logo levert av gruppen som `Die nadel 1.png` (24. november). Originalbildet er kopiert uten endring. Hele logoen brukes i menyen, og symbolet på utvalgte flagg, kasser og bygg. To flyttbare veggbannere er lagt til på hvert nivå som `scenes/world/regime_banner.tscn`. |
| `assets/world/narko_logo.png` | Tidligere logo levert som skjermbilde. Beholdt i prosjektet, men vises ikke i den nåværende hovedmenyen. |
| `assets/characters/protagonist_side.svg`, `assets/world/crate_depth.svg` | Profilbilder og kasse med litt dybde, laget som SVG med hjelp fra Codex. Dette er 2D-grafikk. |
| `assets/items/loot_atlas.png` | Generert med imagegen til prosjektet: mynter, ammunisjon, hagle, sprøyter og bur. Prompten ligger i [loot-art-prompt.txt](de-nadel/docs/loot-art-prompt.txt). Lærerens bilde var en referanse for ideen. |
| `assets/art/title_background.png` | Tidligere menybakgrunn generert med imagegen fra gruppens referanser. Den nåværende menyen bruker pikselbyen. Prompt og bakgrunn: [art-direction.md](de-nadel/docs/art-direction.md). |
| Anton | [Google Fonts – Anton](https://github.com/google/fonts/tree/main/ofl/anton). Lisensen følger med i `assets/fonts/OFL-anton.txt`. |
| Barlow Condensed | [Google Fonts – Barlow Condensed](https://github.com/google/fonts/tree/main/ofl/barlowcondensed). Lisensen følger med i `assets/fonts/OFL-barlowcondensed.txt`. [Barlow-prosjektet](https://github.com/jpt/barlow) var også lenket i den første prosjektloggen. |

«Levert av gruppen» beskriver hvor filen ble mottatt, ikke en bekreftelse på hvem som opprinnelig tegnet den. Vi mangler fortsatt navn på tegner og eventuell ekstern kilde/lisens for deler av materialet. Det må fylles inn av den som leverte filene.

De eldre filene `tanks-simple.png`, `tanks-terrain.png`, `specialBarrel6.png` og `bulletRed1.png` har ikke dokumentert nedlastingskilde i repoet. Det samme gjelder den eldre mappen `scripts/Stick Figure Character Sprites 2D 3/`. Vi har ikke bekreftet opphav eller lisens, og oppgir derfor ikke en gjettet nettside som kilde. Filer som ligger i repoet er heller ikke nødvendigvis brukt i det nåværende spillbildet.

### Lyd

Oppdatert 26. november 2026: Vi har erstattet de seks tidligere kodegenererte lydfilene med lyder laget av **Kenney**. De er hentet fra Kenneys originale lydpakker og har lisensen **CC0 1.0**. Dette er eksterne lydressurser, ikke nye lyder laget av Codex. Vi har konvertert OGG til WAV og justert volumet. Filnavnene i spillet er beholdt, slik at scenene fortsatt finner lydene.

| Fil under `de-nadel/assets/audio/` | Originalfil i lydpakken | Kilde / bruk |
| --- | --- | --- |
| `menu_click.wav` | `Audio/click_001.ogg` | [Kenney – Interface Sounds](https://kenney.nl/assets/interface-sounds). Klikk i menyen. |
| `pickup.wav` | `Audio/confirmation_001.ogg` | [Kenney – Interface Sounds](https://kenney.nl/assets/interface-sounds). Når vi plukker opp noe. |
| `impact.wav` | `Audio/impactPunch_medium_000.ogg` | [Kenney – Impact Sounds](https://kenney.nl/assets/impact-sounds). Treff og slag. |
| `pistol.wav` | `Audio/laserSmall_000.ogg` | [Kenney – Sci-fi Sounds](https://kenney.nl/assets/sci-fi-sounds). Kort skuddlyd; dette er en spill-/laserlyd, ikke et opptak av en ekte pistol. |
| `shotgun.wav` | `Audio/laserLarge_000.ogg` | [Kenney – Sci-fi Sounds](https://kenney.nl/assets/sci-fi-sounds). Kraftigere lyd for haglen. |
| `city_drone.wav` | `Audio/spaceEngineLow_000.ogg` | [Kenney – Sci-fi Sounds](https://kenney.nl/assets/sci-fi-sounds). Lav motorlyd som bakgrunn i menyen. Navnet i spillet er fra den gamle versjonen. |
| `victory_recording.wav` | `ZOOM0039_TrLR.WAV` | Fil levert av gruppen. Spilles etter bosskampen når buret åpnes. Opptaket er omtrent 31 sekunder og er ikke endret. Navn på opptaker, eventuell sang og rettighetshaver er ikke oppgitt ennå. |

De seks originale OGG-filene ligger i [assets/audio/sources/kenney](de-nadel/assets/audio/sources/kenney). Lisensfilene fra de tre arkivene følger med i [assets/audio/licenses](de-nadel/assets/audio/licenses). [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) er lisensen som står på Kenneys sider og i arkivene. Vi fører opp Kenney selv om kreditering ikke er påkrevd i disse lisensfilene.

[sources.json](de-nadel/assets/audio/sources.json) viser kilde, originalt filnavn, kontrollsummer og volumendring for hver fil. Vi har ikke endret tonehøyden, klippet lydene eller laget nye lydsignaler. De gamle syntetiserte lydene er erstattet; de var brukt i tidligere versjoner av spillet. For opptaket fra gruppen mangler vi fortsatt den opprinnelige lydkilden.

### Kode og Godot-dokumentasjon

Disse sidene forklarer funksjonene vi bruker. De er også nyttige når vi skal vise koden og svare på spørsmål i presentasjonen.

| Referanse | Eksempel fra spillet |
| --- | --- |
| [GDScript basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) | Variabler, funksjoner, `if`, `for` og `await`. |
| [Exported properties](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html) | Velge oppdrag og neste nivå med `@export` i Inspector. |
| [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) | `_ready()`, `_process()`, `$GameHUD`, `get_node_or_null()` og `queue_free()`. |
| [Using signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) | Koble portalens `entered`-signal til `enter_portal()`. |
| [Groups](https://docs.godotengine.org/en/stable/tutorials/scripting/groups.html) | Finne spilleren, levende fiender og lagerbur. |
| [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html) | Søke i grupper, bytte scene og sette spillet på pause. |
| [Instancing](https://docs.godotengine.org/en/stable/getting_started/step_by_step/instancing.html) | Gjenbruke samme fiende, kasse og portal i flere nivåer. |
| [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) | `velocity` og `move_and_slide()` hos spilleren og fiendene. |
| [Input](https://docs.godotengine.org/en/stable/classes/class_input.html) | Bevegelse og egne handlinger for skyting og våpenvalg. |
| [AStarGrid2D](https://docs.godotengine.org/en/stable/classes/class_astargrid2d.html) | Finne en rute rundt hindringer. |
| [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html) | Registrere spilleren i portaler og ved gjenstander. |
| [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html) og [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html) | Retninger og animasjonsbilder fra figurarkene. |
| [AtlasTexture](https://docs.godotengine.org/en/stable/classes/class_atlastexture.html) | Velge utsnitt fra spriteark, kartarket og logoen. |
| [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html) | Bevegelsene til sprøytene i sluttsekvensen. |
| [AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html) | Avspilling av effekter og opptaket i slutten. |
| [ProgressBar](https://docs.godotengine.org/en/stable/classes/class_progressbar.html) | Livsmåleren til spilleren og bossen. |
| [Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html) | Stoppe spillingen mens pausemenyen fortsatt virker. |
| [Singletons / Autoload](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) | Beholde inventar mellom nivåer og dele lydfunksjoner. |
| [Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) | Bygge spillet for nettleseren. |

I den første prosjektloggen lå også [Godotkurs – Instanser](https://ensva002.github.io/Godotkurs%202025/pages/5_-_Instanser.html) og [bayanihan-res-q – prologue.tscn](https://github.com/cictapps/bayanihan-res-q/blob/main/scenes/prologue.tscn). De ble notert som referanser for instanser og menyarbeid. Loggen dokumenterer ikke hvilke konkrete linjer som eventuelt er hentet derfra, så vi fører dem som tidligere referanser, ikke som opphav til hele menyen.

### Hjelpemidler

Vi har brukt Godot, GDScript, GitHub og GitHub Desktop. Figurark er levert som Piskel-bilder. Codex/AI er brukt til kodeforslag, tilpasning, feilsøking, tester, kommentarer og deler av dokumentasjonen. Noe grafikk er også laget med AI-hjelp, som beskrevet over. De tidligere kodegenererte lydene er nå erstattet med Kenney-ressursene i lydtabellen. De nye spillfunksjonene er tilpasset dette prosjektet; en dokumentasjonslenke er ikke en påstand om at vi skrev alt uten hjelp.

## Mer om ressursene

Detaljer om filene, sceneoppsettet og hvordan vi kan bytte grafikk ligger her. README-en beskriver den nåværende prototypen; noen av disse notatene er fra tidligere versjoner.

- [Fiender, figurark og bytte av bossgrafikk](de-nadel/docs/enemies-and-boss.md)
- [Mynter, ammunisjon og sluttsekvens](de-nadel/docs/items-and-ending.md)
- [Kartgrafikk og flyttbare objekter](de-nadel/docs/world-art.md)
- [Oppdrag, profilgrafikk, kasser og lydeffekter](de-nadel/docs/gameplay-polish.md)

For å bygge nettutgaven på nytt må eksportmalene passe Godot-versjonen. Fra repoets rot:

```sh
python3 tools/build_web.py --godot /sti/til/Godot
python3 -m http.server 8765 --directory web/dist
```

`localhost` og `127.0.0.1` fungerer bare på maskinen som kjører serveren. Vi deler den publiserte nettadressen med andre.
