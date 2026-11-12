= Visualization

Scientific writing lives on good figures. For data-driven plots Typst has
#link("https://typst.app/universe/package/lilaq/")[*lilaq*], which produces
publication-ready plots (line, scatter, bar, histogram, boxplot, heatmaps).
Use it whenever you plot *numbers*. For schematic diagrams (class diagrams,
flowcharts, entity-relationship models) the
#link("https://typst.app/universe/package/merman/")[*merman*] package renders
#link("https://mermaid.js.org/intro/")[Mermaid] markup directly during
compilation. For graph diagrams that need precise layout control, the
#link("https://typst.app/universe/package/diagraph/")[*diagraph*] package
runs the full #link("https://graphviz.org/")[Graphviz] engine as a
WebAssembly plugin and accepts any DOT source.

The larger plots below are wrapped in `#figure(...)` so they appear in the
List of Figures; the small snippets use the `typst-preview` helper to show
code and output side by side.

A word before you dive in: this template is here to *support* you, not to set a
checklist. Nobody needs every feature shown here, and reaching for one you do
not need only adds work. A project report (Projektarbeit) in particular rarely
calls for elaborate diagrams or statistics, and every thesis is individual to
its topic and its department. Use the parts that help your work and leave the
rest out with a clear conscience.

#include "visualization-lilaq.typ"
#include "visualization-mermaid.typ"
#include "visualization-diagraph.typ"
