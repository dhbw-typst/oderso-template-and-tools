# oderso-tools

Typst template for academic writing at the DHBW and for the IHK project report, built on top of the [`dhbw-oderso`](https://typst.app/universe/package/dhbw-oderso/) package. This repository bundles three ready-made entry points, shared chapters and examples, so you only need to write content.

## Prerequisites

- [Typst](https://github.com/typst/typst) **0.14.2** (the project is tested with this compiler version).
- Internet access on the first compile: packages from the Typst Universe are downloaded automatically and cached locally afterwards.

Installing Typst (macOS):

```sh
brew install typst
```

## The three entry points

Each of these files is a standalone document. Which one you pick depends on the kind of work you are writing:

| File | Use case | Adapter |
| --- | --- | --- |
| `main-dhbw-ka.typ` | DHBW thesis, Karlsruhe campus | `dhbw-ka-adapter` |
| `main-dhbw-ma.typ` | DHBW thesis, Mannheim campus | `dhbw-ma-adapter` |
| `main-ihk.typ` | IHK project report | `ihk-adapter` |

The entry points differ essentially only in their adapter (cover page, headers, legal wording). Title, author, AI acknowledgement and other metadata are configured in the header of each file inside the `#show: ...adapter.with(...)` block.

## Compiling

Produce a PDF once:

```sh
typst compile main-dhbw-ka.typ
```

Write with a live preview (the file is rebuilt on every change):

```sh
typst watch main-dhbw-ka.typ
```

Replace `main-dhbw-ka.typ` with the entry point you are using.

## Project structure

```
.
├── main-dhbw-ka.typ      # Entry point DHBW Karlsruhe
├── main-dhbw-ma.typ      # Entry point DHBW Mannheim
├── main-ihk.typ          # Entry point IHK
├── glossary.typ          # Abbreviations and glossary entries
├── appendix.typ          # Appendix definition
├── refs.bib              # Bibliography sources (BibTeX)
├── chapters/             # Content chapters (included via #include)
│   ├── introduction.typ
│   ├── basic_formatting.typ
│   ├── advanced_elements.typ
│   ├── references_citations.typ
│   ├── reference_management.typ
│   └── conclusion.typ
├── misc/                 # Acknowledgements, abstracts (de/en)
├── assets/               # Logos, signatures, sample data
└── appendix/             # Appendix content (tables etc.)
```

## How content is wired in

The content chapters live in `chapters/` and are pulled into each entry point via `#include` at the end of the file, for example:

```typ
#include "chapters/introduction.typ"
#include "chapters/basic_formatting.typ"
// ...
```

To add a new chapter, create a file under `chapters/` and add an `#include` line in **every** entry point where it should appear.

### Standalone-compilable chapters

Chapters that need their own packages or helper functions import those themselves at the top of the file. This lets you build a single chapter on its own, without compiling the whole document:

```sh
typst compile --root . chapters/<chapter>.typ
```

The `--root .` matters when a chapter accesses files outside the `chapters/` folder (for example `assets/`). Without the flag, Typst refuses access to paths above the source file.

## Conventions

- **Language:** code, comments, variable and function names are consistently in English. German only in the visible text content of the thesis.
- **External packages** are imported via `@preview/<name>:<version>` and are tied to the installed Typst version. When adding a package, check the minimum compiler version it requires.
- **Bibliography** is maintained in `refs.bib` and cited in the text with `@key`.

## License

See the repository or the underlying `dhbw-oderso` package.
