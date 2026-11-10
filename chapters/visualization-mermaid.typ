#import "visualization-helpers.typ": mermaid-preview

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

=== Class Diagram

A `classDiagram` shows classes with their attributes and methods, plus the
relationships between them. The arrow `<|--` means "inherits from": a `Dog`
*is an* `Animal`.

#mermaid-preview(
  [A UML class diagram],
  "classDiagram
  class Animal {
    +String name
    +makeSound()
  }
  class Dog {
    +fetch()
  }
  Animal <|-- Dog",
)

=== Flowchart

A `flowchart` describes a process. `TD` lays it out top-down; `[...]` is a
step, `{...}` a decision, and the arrow labels (`|yes|`) annotate the branches.

#mermaid-preview(
  [A flowchart with a decision],
  "flowchart TD
  A[Receive order] --> B{In stock?}
  B -->|yes| C[Ship order]
  B -->|no| D[Restock]
  D --> B",
)

=== Entity-Relationship Diagram

An `erDiagram` models how database entities relate. The crow's-foot notation
`||--o{` reads "one customer places zero or more orders".

#mermaid-preview(
  [An entity-relationship diagram],
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
)

=== ZenUML Sequence Diagram

Mermaid also supports #link("https://mermaid.js.org/syntax/zenuml.html")[ZenUML],
a compact way to write sequence diagrams. Each line is one message from a
sender to a receiver.

#mermaid-preview(
  [A ZenUML sequence diagram],
  "zenuml
  Student->Supervisor: Submit draft
  Supervisor->Student: Return feedback",
)
