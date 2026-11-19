# Mynter, patroner, hagle og sluttsekvens

## Bruke objektene i Godot

Dra disse scenene fra FileSystem inn i et nivå, akkurat som `box.tscn`:

- `scenes/coin.tscn`: en roterende mynt. **Amount** er hvor mange mynter den gir.
- `scenes/ammo.tscn`: ammunisjonskasse. **Amount** er antall haglepatroner, normalt 8.
- `scenes/shotgun.tscn`: låser opp haglen, velger den og gir normalt 6 patroner.
- `scenes/supply_cage.tscn`: låst lagerbur med sprøyter. **Syringe Count** styrer antallet som flyr ut, normalt 24.

Flytt objektene med Position eller musepekeren i 2D-visningen. Bruk **Cmd+D** på Mac for å kopiere dem. De ligger som egne sceneinstanser og kan åpnes hver for seg. Pickup-scenene har en Area2D som oppdager spilleren; buret har en kollisjon som forsvinner når porten åpnes. Ikke legg pickups inne i vegger eller kasser.

## Spilling

**1** velger pistol, **2** velger hagle hvis den er funnet og har patroner. Pistolen har ubegrenset ammunisjon. Haglen sender tre kuler med spredning og bruker én patron per skudd. Når den er tom, velges pistolen automatisk. En kort skuddpause hindrer dobbeltavfyring.

Mynter fungerer foreløpig som poeng; det er ingen butikk. HUD viser myntantall, valgt våpen og ammunisjon. Mynter, haglen og patroner følger med når **Neste nivå** brukes. **Prøv igjen** gjenoppretter inventaret fra starten av nivået. Nivåvalg og **Spill igjen** starter en ny runde.

## Etter bossen

På nivå 3 må alle fiendene, inkludert Hitler-bossen, være beseiret. Spilleren stoppes og beskyttes mot skade mens buret åpnes. Porten bruker fire bilder fra arket. Deretter flyr sprøytene ut i små buer og lander foran buret. Først når animasjonen er ferdig vises **Diktaturet er beseiret!** og **Sprøytene er frigjort.**, med **Spill igjen** og **Hovedmeny**.

Hvis et nivå har flere kopier av buret, åpnes alle før seiersmenyen. Nivåer uten bur bruker den vanlige nivåslutten. Animert dør og løse sprøyter hører til bur-scenen, så de blir med når scenen flyttes eller kopieres.

## Grafikk og kilder

`assets/items/loot_atlas.png` er ett transparent 4 × 4-spritemap. Det er laget med den innebygde imagegen-funksjonen og tilpasset prosjektets pikselstil. Kode og Godot-oppsett er tilpasset med Codex/AI. Lærerens skjermbilde ble brukt som eksempel på mynter og en frigjøringsmekanikk.

Radene i arket:

1. Fire myntbilder.
2. Fire ammunisjonskassebilder.
3. To haglebilder og to løse sprøyter.
4. Buret lukket, delvis åpent, åpent med innhold og åpent uten innhold.

`.tres`-filene ved siden av arket inneholder ferdige AtlasTexture-utsnitt og SpriteFrames. De refererer til samme PNG. Godot bruker nearest-filtrering. Den fullstendige bildeprompten ligger i `docs/loot-art-prompt.txt`. Verktøy: innebygd imagegen; originalen er beholdt i Codex sin generated_images-mappe og den brukte kopien følger med i repoet.

Referanser: [Godot Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html), [AtlasTexture](https://docs.godotengine.org/en/stable/classes/class_atlastexture.html), [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html).

## Kontroll

Kjør `godot --headless --path de-nadel --script res://tests/loot_smoke.gd`. Testen kontrollerer fysisk oppsamling, dobbeltkall, patronforbruk, skuddpause, inventar mellom nivåer, omstart og rekkefølgen i sluttsekvensen.
