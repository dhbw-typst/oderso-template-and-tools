#import "visualization-helpers.typ": diagraph-preview, render-digraph

== Graph Diagrams with diagraph

#link("https://typst.app/universe/package/diagraph/")[*diagraph*] is a
#link("https://graphviz.org/")[Graphviz] binding for Typst. It runs the
full Graphviz layout engine as a WebAssembly plugin, so graphs are rendered
during compilation with no external tools. You write a graph in
#link("https://graphviz.org/doc/info/lang.html")[DOT language] and
`diagraph` produces a vector image directly in the document.

Every Graphviz attribute (`shape`, `label`, `rankdir`, `style`, ...) works
as-is. `diagraph` is the right choice for diagrams that need precise layout
control: automata, dependency graphs, syntax trees, or any graph you already
have in DOT format. Choose Mermaid when a quick, readable markup syntax
matters more than fine-grained layout.

The preview below shows the DOT source for a finite automaton on the left
and the rendered diagram on the right. The start state $q_0$ is marked by
an incoming arrow, the accepting state $q_2$ by a double circle.

#let _dfa-dot = "rankdir=LR
start [shape=none label=\"\" width=0 height=0]
start -> q0
q0 [label=\"q\u{2080}\" shape=circle]
q1 [label=\"q\u{2081}\" shape=circle]
q2 [label=\"q\u{2082}\" shape=doublecircle]
q0 -> q1 [label=\"a\"]
q1 -> q2 [label=\"b\"]
q2 -> q0 [label=\"a\"]
q1 -> q0 [label=\"b\"]"

#diagraph-preview(
  [Finite automaton rendered with diagraph],
  _dfa-dot,
  width: 100%,
  title: [Automaton over ${a, b}$],
)
