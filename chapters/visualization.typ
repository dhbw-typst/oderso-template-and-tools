= Visualization

Scientific writing lives on good figures. For data-driven plots Typst has
#link("https://typst.app/universe/package/lilaq/")[*lilaq*], which produces
publication-ready plots (line, scatter, bar, histogram, boxplot, heatmaps,
vector fields). Use it whenever you plot *numbers*. For schematic diagrams
(class diagrams, flowcharts, entity-relationship models) the
#link("https://typst.app/universe/package/merman/")[*merman*] package renders
#link("https://mermaid.js.org/intro/")[Mermaid] markup directly during
compilation.

The larger plots below are wrapped in `#figure(...)` so they appear in the
List of Figures; the small snippets use the `typst-preview` helper to show
code and output side by side.

#include "visualization-lilaq.typ"
#include "visualization-mermaid.typ"
