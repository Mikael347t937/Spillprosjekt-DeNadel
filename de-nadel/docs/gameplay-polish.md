# Oppdrag, pikselgrafikk og lyd

Oppdatert 20. november 2026.

## Tre små oppdrag

1. **Bakgatene:** finn haglen og slå vaktene, også den siste bølgen. Det holder ikke å slå vaktene uten å finne våpenet.
2. **Lagerplassen:** hent **LAGERLISTE** øst på plassen og slå vaktene. Gå bort til kassen for å ta listen. Den forteller hvor det beslaglagte lageret er.
3. **Kontrollposten:** slå vaktene og bossen. Buret åpnes, sprøytene faller ut og gruppens `ZOOM0039_TrLR.WAV` starter som før.

`Objective`, `Chapter` og `Briefing` på nivåroten styrer oppdragsteksten. `field_supply.tscn` er den flyttbare kassen med lagerlisten. Den gjenopprettes ved omstart. Nivåvelgeren er fortsatt åpen, så alle kan teste sitt eget nivå direkte.

## Grafikk

- De opprinnelige PNG-arkene fra gruppen er uendret. Forsiden og baksiden til hovedpersonen bruker fortsatt `protagonist.png`.
- `assets/characters/protagonist_side.svg` er et enkelt profilark med tre 32 × 32-poser tegnet som pikselrektangler. Fargene og klærne følger hovedpersonen. Venstrevendt profil speiles ved bevegelse mot høyre. Nøytralposen brukes ved stopp.
- `assets/world/crate_depth.svg` tegner kassens front, topp og side. Dette er en flat 2D-tekstur med litt dybde, ikke en 3D-modell. Kollisjonen er fortsatt 54 × 54.
- Originale husfasader og rekvisitter brukes fortsatt. `atlas_cutout.gdshader` skjuler den grå rutebakgrunnen på rekvisittene ved tegning. De gamle bakkerutene er bevart, men skjult; en jevn flate og en gate uten kjørefeltstriper unngår synlige skjøter. Kantstein og fortau hører til gaten.
- Menyen bruker nå den samme byen og de samme karakterarkene som selve spillet. Den tidligere genererte illustrasjonen er bevart som eldre materiale og brukes ikke som menybakgrunn.
- `pixel_city_preview.png` er et faktisk Godot-bilde av denne byen med gruppens figurer, brukt som forhåndsvisning på nettsiden.

SVG-ene er kodebaserte vektorfiler, ikke bilder fra en bildegenerator. Oppdeling, tegning, kode og tekster er likevel laget med hjelp fra Codex/AI; dette skal ikke omtales som arbeid utført uten hjelp. Laget kan redigere eller erstatte profilarket og kassen med egne ferdige ark senere.

## Vakter og ruter

Vanlige fiender viser **!** før slaget. Du kan gå unna under forvarselet; slaget treffer bare hvis du fortsatt er nær og uten en vegg mellom dere. De raske vaktene har 2 liv og svakere slag, mens de tunge har 5 liv, lavere fart og et lengre forvarsel. Bossen beholder sine egne varslede angrep.

`Paths` på hvert nivå bygger et AStarGrid2D fra faktiske kollisjoner. Fiendene bruker en fri rett rute når det er plass, ellers går de langs en rute rundt kasser. Rutene oppdateres med et kort mellomrom. Nye faste hindringer må stå i scenen før nivået begynner; ved framtidige ødeleggbare vegger må rutenettet også oppdateres.

## Lyd

Oppdatert 26. november: `pistol.wav`, `shotgun.wav`, `impact.wav` og `pickup.wav` bruker nå Kenneys eksterne lydpakker Sci-fi Sounds, Impact Sounds og Interface Sounds (CC0). De tidligere kodegenererte effektene er erstattet. Originalfilene og lisensene følger med i `assets/audio/`; [README](../../README.md#lyd) og `assets/audio/sources.json` viser nøyaktig opphav og volumtilpasning. De spilles av `GameAudio` og følger **Lydnivå**. Effektene er hoppet over i headless-tester. Treffer, død og rekyl har ikke fått nye visuelle effekter i denne endringen.

## Kontroll

Alle eksisterende røykprøver brukes fortsatt. `tests/polish_smoke.gd` tester i tillegg at en fiende faktisk går forbi en blokkende kasse, at forvarsel kan unngås og pauses, og at det å gå bort til lagerlisten fullfører det andre oppdraget. Testene bekrefter ikke at spillet er perfekt balansert; spilltest med laget er fortsatt nyttig.

API-referanser: [AStarGrid2D](https://docs.godotengine.org/en/stable/classes/class_astargrid2d.html), [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html), [AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html). Koden er tilpasset dette prosjektet, ikke kopiert fra et annet spill.
