# Fiender og boss

## Grafikk og kilder

Gruppen leverte tre Piskel-ark på 64 × 64 piksler. De er kopiert uendret inn i prosjektet:

- `New Piskel.png` → `assets/characters/guard.png`
- `New Piskel (2).png` → `assets/characters/scout.png`
- `New Piskel (1).png` → `assets/characters/soldier.png`

Hvert ark er delt i fire 32 × 32-ruter i en SpriteFrames-ressurs. `walk` spilles mens figuren beveger seg. Nearest-filtrering holder pikslene skarpe. Utseendet endrer ikke skade eller liv: alle tre er vanlige nærkampfiender. Velg **Appearance** på en fiende i Inspector. Bølgene velger mellom de tre variantene.

Oppsett og kode er tilpasset med Codex/AI. Referanser for Godot-funksjonene:

- [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html)
- [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html)
- [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html)

## Boss på nivå 3

`scenes/boss.tscn` er en egen scene som arver fra `scenes/enemy.tscn`. Den erstatter den fjerde vanlige fienden. Tre vakter og bossen må beseires før nivået avsluttes.

Foreløpig heter bossen **Kommandanten**. Den bruker en større, rødfarget versjon av vaktgrafikken som plassholder. Dette er ikke endelig bossdesign.

- 18 liv; spillerens kuler gjør 1 skade.
- Veksler mellom tre skudd og et rett rykkeangrep.
- En rød linje viser låst angrepsretning før angrepet. Flytt deg etter at retningen er vist.
- Kulene gjør 15 skade. Rykkeangrepet gjør 25 skade og stoppes av kasser.
- Etter et angrep hviler bossen en kort stund. Ved halvparten av livet blir forvarsel og hvile kortere.
- Bossens liv vises øverst på skjermen. Pause, omstart og nivåslutt fungerer som ellers.

Adferden ligger i `scripts/boss.gd`, prosjektilene i `scripts/enemy_projectile.gd`. Parametere for hastighet, liv, forvarsel, rykkeangrep og hvile kan endres i Inspector.

## Når designerne leverer bossen

1. Legg de nye bildefilene under `assets/characters/` og lag en SpriteFrames-ressurs med en animasjon kalt `walk`.
2. Åpne `scenes/boss.tscn`, velg roten og sett **Custom Frames** til ressursen. Denne overstyrer standardgrafikken.
3. Sett **Body Tint** til hvit og juster skalaen på `Sprite2D`. Juster `CollisionShape2D` til den nye figurens kropp.
4. Behold skriptet, gruppene, `Warning`, `HealthBar` og signalene. Da fortsetter angrep, skade, bossens livsmåler og nivåslutt å fungere.

Flere animasjoner for skudd, rykkeangrep og død kan legges til når de blir levert. Nå brukes gåanimasjonen og et kort fargeskift ved treff.

## Kontroll

```sh
godot --headless --path de-nadel --script res://tests/boss_smoke.gd
```

Testen sjekker blant annet faktisk treff fra begge siders kuler, dekning, forvarsel, pause, rykkeangrep, fasebytte, nivåslutt og omstart.
