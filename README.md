# RushDungeon — Proof of Concept (2D)

Dungeon crawler / roguelike z nagłą śmiercią i presją czasu.
Projekt zespołowy, Akademia WSB, Wydział Zamiejscowy w Cieszynie.
Autorzy: Jan Szewieczek, Jakub Bąk, Martyna Wawak.

Silnik: **Godot 4** (zalecane 4.3 lub nowsze), renderer GL Compatibility.
Zero zewnętrznych assetów — cała grafika jest rysowana wektorowo w kodzie (`_draw()`).

---

## Jak uruchomić

1. Pobierz Godot 4 ze strony https://godotengine.org/download (wersja Standard).
2. Godot → **Import** → wskaż `project.godot` w folderze `RushDungeon` → **Import & Edit**.
3. **F5** uruchamia grę.

## Sterowanie

- Ruch: **WASD** / **strzałki**
- Atak: **Spacja** (lub **J**)
- Restart / nowy losowy poziom: **R** (po zakończeniu rundy)

## Zasady

- Dojdź do **portalu** (wyjścia), zanim skończy się **czas**.
- Gracz nie ma HP — każdy wróg ma procentową *szansę na zabicie*. Pancerz ją obniża:
  `szansa skuteczna = szansa wroga − pancerz`.
- **Śmierć** = odrodzenie na starcie piętra, ale **timer leci dalej**.
- **Czas = 0** → porażka.

Podniesienie tarczy (pancerz −70%): Goblin 90%→20% (do ogrania), Ogr 175%→105% (wciąż
100% śmierci — trzeba go unikać).

## Co jest generowane losowo

Przy każdym uruchomieniu i po naciśnięciu **R**:

- rozkład **przeszkód** (kamiennych bloków) na siatce,
- pozycje **gracza** i **portalu** (portal zawsze daleko od startu),
- liczba, typy i pozycje **przeciwników** (Goblin / Ogr),
- pozycja **przedmiotu**.

Generator (`scripts/LevelGenerator.gd`) sprawdza algorytmem **BFS**, że wyjście jest
osiągalne — jeśli losowy układ zablokowałby drogę, próbuje ponownie.

## Ikony

Każdy byt ma osobną ikonę wektorową rysowaną w `_draw()`:
Gracz (kierunek + zamach), Goblin (uszy, czerwone oczy), Ogr (większy, z pałą),
portal (wirujące łuki), pancerz (tarcza). To celowo czytelne kształty geometryczne,
nie pixel-art — docelowe sprite'y można podmienić bez ruszania logiki.

## Struktura

```
RushDungeon/
├─ project.godot
├─ Main.tscn              # ściany zewnętrzne + HUD (reszta generowana w kodzie)
├─ scenes/                # Player, Enemy, Pickup, Exit, Obstacle, HUD
└─ scripts/
   ├─ GameManager.gd      # autoload: stan, timer, sterowanie
   ├─ LevelGenerator.gd   # proceduralne piętro + walidacja BFS
   ├─ Main.gd             # spawn bytów wg wygenerowanego układu
   ├─ Player.gd  Enemy.gd  Pickup.gd  Exit.gd  Obstacle.gd  HUD.gd
```

## Znane uproszczenia (świadome, do rozwinięcia)

- AI przeciwników to prosty pościg w linii prostej (bez omijania przeszkód —
  docelowo pathfinding, np. `NavigationAgent2D`).
- Jedno piętro. Kolejne: w `Exit.gd` zamiast `GameManager.win()` wczytać następną scenę.
- Ekwipunek 4×5, pierścienie, więcej typów wrogów — kolejne moduły na bazie tego rdzenia.

## Dodawanie zawartości

- Nowy typ wroga: dodaj wartość w `enum Kind` i gałąź w `_apply_archetype()` + `_draw()`.
- Inny przedmiot: nowa scena na bazie `Pickup.tscn` z inną wartością i ikoną.
- Parametry piętra (czas, gęstość przeszkód, liczba wrogów): eksporty w węźle `Main`.
