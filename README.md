# oderso-tools

Typst-Vorlage für wissenschaftliche Arbeiten an der DHBW und für den IHK-Projektbericht, aufgebaut auf dem Paket [`dhbw-oderso`](https://typst.app/universe/package/dhbw-oderso/). Das Repository bündelt drei fertige Einstiegspunkte, gemeinsame Kapitel und Beispiele, sodass du nur noch Inhalt schreiben musst.

## Voraussetzungen

- [Typst](https://github.com/typst/typst) **0.14.2** (das Projekt ist mit dieser Compiler-Version getestet).
- Internetzugang beim ersten Kompilieren: Pakete aus dem Typst-Universe werden automatisch heruntergeladen und danach lokal zwischengespeichert.

Installation von Typst (macOS):

```sh
brew install typst
```

## Die drei Einstiegspunkte

Jede dieser Dateien ist ein eigenständiges Dokument. Welche du nimmst, hängt von der Art deiner Arbeit ab:

| Datei | Verwendung | Adapter |
| --- | --- | --- |
| `main-dhbw-ka.typ` | DHBW-Arbeit, Standort Karlsruhe | `dhbw-ka-adapter` |
| `main-dhbw-ma.typ` | DHBW-Arbeit, Standort Mannheim | `dhbw-ma-adapter` |
| `main-ihk.typ` | IHK-Projektbericht | `ihk-adapter` |

Die Einstiegspunkte unterscheiden sich im Wesentlichen nur im Adapter (Deckblatt, Kopfzeilen, rechtliche Formulierungen). Titel, Autor, AI-Acknowledgement und weitere Metadaten konfigurierst du im Kopf der jeweiligen Datei im `#show: ...adapter.with(...)`-Block.

## Kompilieren

Einmalig ein PDF erzeugen:

```sh
typst compile main-dhbw-ka.typ
```

Während des Schreibens mit Live-Vorschau (Datei wird bei jeder Änderung neu gebaut):

```sh
typst watch main-dhbw-ka.typ
```

Ersetze `main-dhbw-ka.typ` durch den Einstiegspunkt, den du verwendest.

## Projektstruktur

```
.
├── main-dhbw-ka.typ      # Einstiegspunkt DHBW Karlsruhe
├── main-dhbw-ma.typ      # Einstiegspunkt DHBW Mannheim
├── main-ihk.typ          # Einstiegspunkt IHK
├── glossary.typ          # Abkürzungen und Glossareinträge
├── appendix.typ          # Anhang-Definition
├── refs.bib              # Literaturquellen (BibTeX)
├── chapters/             # Fachkapitel (per #include eingebunden)
│   ├── introduction.typ
│   ├── basic_formatting.typ
│   ├── advanced_elements.typ
│   ├── references_citations.typ
│   ├── reference_management.typ
│   └── conclusion.typ
├── misc/                 # Danksagung, Abstracts (de/en)
├── assets/               # Logos, Signaturen, Beispieldaten
└── appendix/             # Anhang-Inhalte (Tabellen etc.)
```

## Wie der Inhalt eingebunden wird

Die Fachkapitel liegen in `chapters/` und werden am Ende jedes Einstiegspunkts per `#include` eingebunden, zum Beispiel:

```typ
#include "chapters/introduction.typ"
#include "chapters/basic_formatting.typ"
// ...
```

Ein neues Kapitel fügst du hinzu, indem du eine Datei unter `chapters/` anlegst und in **jedem** Einstiegspunkt, in dem es erscheinen soll, eine `#include`-Zeile ergänzt.

### Eigenständig kompilierbare Kapitel

Kapitel, die eigene Pakete oder Hilfsfunktionen brauchen, importieren diese selbst am Dateianfang. Dadurch lässt sich ein einzelnes Kapitel auch allein bauen, ohne das komplette Dokument zu kompilieren:

```sh
typst compile --root . chapters/<kapitel>.typ
```

Das `--root .` ist wichtig, wenn das Kapitel auf Dateien außerhalb des `chapters/`-Ordners zugreift (zum Beispiel `assets/`). Ohne das Flag verweigert Typst den Zugriff auf Pfade oberhalb der Quelldatei.

## Konventionen

- **Sprache:** Code, Kommentare, Variablen- und Funktionsnamen sind durchgängig auf Englisch. Deutsch nur in sichtbaren Textinhalten der Arbeit.
- **Externe Pakete** werden über `@preview/<name>:<version>` eingebunden und sind an die installierte Typst-Version gebunden. Achte beim Hinzufügen eines Pakets auf die vom Paket geforderte Mindest-Compiler-Version.
- **Literatur** pflegst du in `refs.bib` und zitierst sie im Text mit `@key`.

## Lizenz

Siehe Repository bzw. das zugrunde liegende `dhbw-oderso`-Paket.
