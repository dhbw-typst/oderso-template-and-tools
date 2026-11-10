# oderso-tools

A friendly starting point for your academic writing at the DHBW or your IHK project report. Instead of setting up structure and formatting from scratch, you clone this repository, pick the entry point that matches your work, and start writing right away.

Everything is built on the [`dhbw-oderso`](https://typst.app/universe/package/dhbw-oderso/) template, which already handles the cover page, headers, declarations and all the formal parts. On top of that, this repository shows how to put the wider [Typst Universe](https://typst.app/universe/) to work in a real thesis. We recommend a handful of packages and demonstrate them in the chapters, with a particular focus on **visualizations**: charts, diagrams and plots that make an evaluation or results section genuinely readable rather than a wall of text.

So you get three ready-made entry points, shared chapters, and worked examples, and you only need to write content.

## Prerequisites

- A recent [Typst](https://github.com/typst/typst) release.
- Internet access on the first compile: packages from the Typst Universe are downloaded automatically and cached locally afterwards.

The `dhbw-oderso` version used is pinned in the `#import` line at the top of each entry point; the Typst release you need is whatever that package requires.

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

The three `main-*.typ` files are the entry points. Content chapters live in `chapters/`, with front and back matter split into `misc/` (acknowledgements, abstracts) and `appendix/`. Shared pieces sit at the root: `glossary.typ` for abbreviations and glossary entries, `appendix.typ` for the appendix definition, and `refs.bib` for the bibliography. Images, signatures and sample data are kept in `assets/`.

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
