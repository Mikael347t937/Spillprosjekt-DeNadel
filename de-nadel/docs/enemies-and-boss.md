# Fiender og boss

## Grafikk og kilder

Gruppen leverte nye Piskel-filer 16. november:

- `Vanlig dag på oslo s 3 (2).png` → `assets/characters/syringe_enemy.png`: vanlig fiende med sprøyte. Arket er 96 × 96; radene viser forfra, bakfra og fra siden, med tre 32 × 32-poser per rad.
- `New Piskel (3).png` → `assets/characters/player_front.png`: spilleren sett forfra.
- `New Piskel (1) (1).png` → `assets/characters/player_back.png`: spilleren sett bakfra.
- `New Piskel (2) (1).png` → `assets/characters/player_side.png`: spilleren fra venstre side.

Bildene er kopiert uendret. De tre spillerarkene er 64 × 64, men inneholder bare tre tegnede ruter. Nederste høyre rute er tom og brukes ikke. Gåsyklusen er nøytral–steg–nøytral–motsatt steg. Nøytralposen brukes når figuren stopper.

Både spiller og fiende bruker `scripts/directional_sprite.gd`. Faktisk bevegelse velger retning; ved stillstand beholdes retningen, eller figuren vender mot en hindring/målet sitt. Bare sidevisningen speiles. De leverte sidebildene ser mot venstre, så `flip_h` aktiveres når figuren går til høyre. Diagonaler med like store akser bruker forfra/bakfra konsekvent. Nearest-filtrering holder pikslene skarpe.

`tanks.tscn` og `tanks.gd` beholder filnavnene for å bevare nivåreferanser, men spilleren er nå et menneske. Den gamle tankkanonen er fjernet. Musepekeren styrer fortsatt skuddretningen gjennom `Node2D/Muzzle`; figuren vender etter bevegelsen.

Oppsett og kode er tilpasset med Codex/AI. Referanser for Godot-funksjonene:

- [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html)
- [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html)
- [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html)

## Boss på nivå 3

`scenes/boss.tscn` er en egen scene som arver fra `scenes/enemy.tscn`. Den erstatter den fjerde vanlige fienden. Tre vanlige fiender og bossen må beseires før nivået avsluttes.

Bossen heter **Hitler**, etter gruppens valg. Det endelige bildet er ikke levert; den større, rødfargede spillerfiguren brukes fortsatt som plassholder. Navnet kan endres med **Display Name** på bossen.

- 18 liv; spillerens kuler gjør 1 skade.
- Veksler mellom tre skudd og et rett rykkeangrep.
- En rød linje viser låst angrepsretning før angrepet. Flytt deg etter at retningen er vist.
- Kulene gjør 15 skade. Rykkeangrepet gjør 25 skade og stoppes av kasser.
- Etter et angrep hviler bossen en kort stund. Ved halvparten av livet blir forvarsel og hvile kortere.
- Bossens liv vises øverst på skjermen. Pause, omstart og nivåslutt fungerer som ellers.

Adferden ligger i `scripts/boss.gd`, prosjektilene i `scripts/enemy_projectile.gd`. Parametere for hastighet, liv, forvarsel, rykkeangrep og hvile kan endres i Inspector.

## Når designerne leverer bossen

1. Legg de nye bildefilene under `assets/characters/` og lag en SpriteFrames-ressurs med animasjonene `front`, `back` og `side`.
2. Åpne `scenes/boss.tscn`, velg roten og sett **Custom Frames** til ressursen. Denne overstyrer standardgrafikken.
3. Sett **Body Tint** til hvit og juster skalaen på `Sprite2D`. Juster `CollisionShape2D` til den nye figurens kropp.
4. Behold skriptet, gruppene, `Warning`, `HealthBar` og signalene. Da fortsetter angrep, skade, bossens livsmåler og nivåslutt å fungere.

Flere animasjoner for skudd, rykkeangrep og død kan legges til når de blir levert. Nå brukes retningsbestemte gåanimasjoner og et kort fargeskift ved treff.

## Kontroll

```sh
godot --headless --path de-nadel --script res://tests/boss_smoke.gd
```

Testen sjekker blant annet faktisk treff fra begge siders kuler, dekning, forvarsel, pause, rykkeangrep, fasebytte, nivåslutt og omstart.
