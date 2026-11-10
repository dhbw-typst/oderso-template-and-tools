#import "visualization-helpers.typ": mermaid-preview, mermaid-figure

== Diagrams with Mermaid

#link("https://mermaid.js.org/intro/")[Mermaid] is a text-based diagram
language: you describe a diagram in a few lines of markup and the renderer
lays it out for you. The `merman` package ships a WebAssembly renderer, so the
diagrams are produced during compilation, with no browser or Node.js required.
A single function call renders any Mermaid source:

```typ
#import "@preview/merman:0.1.0": mermaid
#mermaid("flowchart TD
  A[Start] --> B[Stop]", background: none)
```

Passing `background: none` keeps the diagram transparent so it blends into the
page. The helper used below shows the Mermaid source on the left and the
rendered diagram on the right.

=== Diagrams as Numbered Figures

A bare `#mermaid(...)` call drops the diagram into the page as a loose image:
it has no figure number, no entry in the "List of Figures", and cannot be
cross-referenced. For a scientific thesis, every diagram should instead be a
proper #link("https://typst.app/docs/reference/model/figure/")[figure] so it is
numbered, listed, and referenceable like any other illustration. The
`mermaid-figure` helper wraps the diagram accordingly:

```typ
#import "visualization-helpers.typ": mermaid-figure
#mermaid-figure(
  [Build pipeline stages],
  "flowchart LR
    A[Compile] --> B[Test]
    B --> C[Deploy]",
  label: <fig-pipeline>,
)
```

This produces a numbered figure you can reference with its label — for example
the flowchart in @fig-order-flow below. Pass an optional
`source: [@key]` to add a citation after the caption (routed through
`caption-with-source` so it does not disturb IEEE outline sorting), and `width`
to control the rendered size.

By default `mermaid-figure` renders in *black and white* rather than Mermaid's
colored theme. This matches scientific conventions: IEEE figures, for example,
must stay legible in grayscale and must never encode information through color
alone. Pass `theme: none` for Mermaid's default colors, or your own theme
variable map to override individual values.

The side-by-side previews below show the Mermaid syntax next to its output for
learning purposes; in an actual thesis, prefer `mermaid-figure` so each diagram
is a proper figure.

=== Class Diagram

A `classDiagram` shows classes with their attributes and methods, plus the
relationships between them. The arrow `<|--` means "inherits from": a `Dog`
*is an* `Animal`.

#mermaid-preview(
  [Class Diagram with Mermaid: inheritance between Animal and Dog],
  "classDiagram
  class Animal {
    +String name
    +makeSound()
  }
  class Dog {
    +fetch()
  }
  Animal <|-- Dog",
  scale: 1,
)

=== Flowchart

A `flowchart` describes a process. `TD` lays it out top-down; `[...]` is a
step, `{...}` a decision, and the arrow labels (`|yes|`) annotate the branches.

#mermaid-preview(
  [Flowchart with Mermaid: order handling with a stock-check decision],
  "flowchart TD
  A[Receive order] --> B{In stock?}
  B -->|yes| C[Ship order]
  B -->|no| D[Restock]
  D --> B",
  reference: "fig-order-flow",
  scale: 1,
)

=== Entity-Relationship Diagram

An `erDiagram` models how database entities relate. The crow's-foot notation
`||--o{` reads "one customer places zero or more orders".

#mermaid-preview(
  [Entity-Relationship Diagram with Mermaid: customers, orders and line items],
  "erDiagram
  CUSTOMER ||--o{ ORDER : places
  ORDER ||--|{ LINE_ITEM : contains
  CUSTOMER {
    string name
    string email
  }
  ORDER {
    int id
    date created
  }",
  scale: 1,
)

=== ZenUML Sequence Diagram

Mermaid also supports #link("https://mermaid.js.org/syntax/zenuml.html")[ZenUML],
a compact way to write sequence diagrams. Each line is one message from a
sender to a receiver.

#mermaid-preview(
  [ZenUML Sequence Diagram with Mermaid: draft submission and feedback],
  "zenuml
  Student->Supervisor: Submit draft
  Supervisor->Student: Return feedback",
  scale: 1,
)
