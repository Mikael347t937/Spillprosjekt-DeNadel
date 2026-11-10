# Spillprosjekt-DeNadel

## Åpne spillet

1. Hent siste versjon med **Fetch origin → Pull origin** i GitHub Desktop.
2. I Godot 4.7.2: velg **Import**, og åpne **`de-nadel/project.godot`** fra dette repositoriet.
3. Trykk **F5**. Hovedscenen er `de-nadel/scenes/main_menu.tscn`.

Startmenyen har **Start spill**, **Innstillinger**, **Om spillet** og **Avslutt**. Bruk mus eller piltastene og Enter. Esc går tilbake. Lydnivå, fullskjerm og redusert bevegelse lagres lokalt. **Start spill** åpner `de-nadel/Level.tscn`. For å bytte nivå senere: endre **First Scene** på rotnoden i hovedmenyen. Hovedmenyen er prosjektets hovedscene; bruk **Run Current Scene** for å teste et nivå direkte.

Alle spillressurser ligger inne i `de-nadel/`. Bakgrunn, lyd og fonter følger med, og fontlisensene ligger i `de-nadel/assets/fonts/`. Bakgrunnens kildebeskrivelse er i `de-nadel/docs/art-direction.md`.

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
