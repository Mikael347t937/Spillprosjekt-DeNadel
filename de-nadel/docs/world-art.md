# Kartgrafikk fra gruppen

## Originaler

Levert av gruppen 19. november 2026:

- `verden.png` (1536 × 1024), kopiert uendret til `assets/world/verden.png`: bakke, asfalt, vann, 16 husfasader, kasse, tønne, gjerde, sperring, lykt, skilt, benk, tre, busk og stein.
- `Skjermbilde 2026-11-19 kl. 10.08.13 (1).png` (1644 × 876), kopiert uendret til `assets/world/narko_logo.png`. Brukes som NARKO-logo i hovedmenyen, ikke på kartene. Den grå sjakkbakgrunnen i skjermbildet er en del av bildet, ikke gjennomsiktighet. `shaders/logo_ink.gdshader` skjuler de grå områdene ved tegning; originalfilen er uendret. Et originalt eksportert PNG med alfa kan erstatte skjermbildet senere.

Vi kjenner ikke en ekstern kilde eller lisens utover at bildene ble levert av gruppen. Grafikeren bør føre opp navn og eventuell opprinnelig kilde før offentlig utgivelse. Ingen nye bilder er generert i denne endringen. Oppdeling i AtlasTexture, sceneoppsett og integrasjon er gjort med Codex/AI.

## Redigere i Godot

`assets/world/*.tres` er AtlasTexture-ressurser som peker til områder i originalbildene. De svarte rutelinjene i atlaset er utelatt. Arket har ulik radhøyde, så det skal ikke deles som et jevnt 192 × 192-rutenett. Originalbildene trenger ikke å klippes opp eller endres.

- Åpne et nivå og velg **City**. Velg **Editable Children** i høyreklikkmenyen for å flytte enkeltobjekter lokalt i dette nivået.
- `scenes/world/city_1.tscn`, `city_2.tscn` og `city_3.tscn` inneholder hver sin gate og bakgrunn. Åpne en av dem for å redigere kartgrafikken direkte. `Ground` inneholder bakken, `Decorations` hus og andre detaljer. Husene er klippet langs silhuetten med Polygon2D, så de ikke får en firkant med atlasbakgrunn rundt seg. Flytt roten av huset for å beholde tekstur og silhuett sammen.
- Dra en av `scenes/world/house_01.tscn` til `house_16.tscn`, eller `barrel.tscn`, `fence.tscn`, `lamp.tscn`, `bench.tscn`, `tree.tscn` osv. inn i scenen. **Cmd+D** lager en kopi. Posisjon, skala og tekstur kan endres i Inspector.
- `narko_sign.tscn` er bevart som en valgfri ressurs, men brukes ikke på nivåene. Logoen ligger i hovedmenyens `Interface/NarkoLogo`.
- Husene er en bakgrunnsrekke, og de andre nye miljøobjektene er dekor. De har ingen kollisjon. Skal et nytt objekt blokkere spilleren, legg det i en StaticBody2D med CollisionShape2D og collision layer **2**. Ikke legg kollisjon over startpunkter eller gjenstander.
- Eksisterende `box.tscn` bruker den nye kassegrafikken. Både den synlige kassen og kollisjonen er **54 × 54**, og alle kasser står på sine opprinnelige plasser. Flytt eller kopier Box for spillbar dekning.

City ligger bak spillfigurene med `z_index = -20`. Den gamle `TileMapLayer` er bevart, men skjult, slik at lagets tidligere terrengoppsett fortsatt finnes. Fiender, startpunkter, bølger, skudd, mynter, bur og nivåslutt er beholdt. Bruk Nearest-filtrering for å beholde skarpe piksler.

Godot-referanser: [AtlasTexture](https://docs.godotengine.org/en/stable/classes/class_atlastexture.html), [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html) og [sceneinstanser](https://docs.godotengine.org/en/stable/getting_started/step_by_step/instancing.html). Dette er API-referanser, ikke kilden til bildene.
