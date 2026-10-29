#import "basic_formatting.typ": typst-preview
#import "@preview/dhbw-oderso:2.4.1": caption-with-source
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/cetz:0.4.2"
#import "@preview/pintorita:0.1.4"

= Visualization

Scientific writing lives on good figures. Typst has a growing ecosystem of
visualization packages, each with a different purpose:

- #link("https://typst.app/universe/package/lilaq/")[*lilaq*] produces
  publication-ready, data-driven plots (line, scatter, bar, histogram,
  boxplot, heatmaps, vector fields). Use it whenever you plot *numbers*.
- #link("https://typst.app/universe/package/cetz/")[*CeTZ*] is a general
  vector-drawing package (think TikZ for Typst). Use it for schematic
  drawings, custom shapes, and annotations that are not driven by a dataset.
- #link("https://typst.app/universe/package/pintorita/")[*Pintorita*] renders
  text-based diagram markup (sequence, ER, component, activity, mind map,
  Gantt) similar to Mermaid or PlantUML. Use it for technical diagrams you
  want to describe in words rather than draw by hand.

The larger plots below are wrapped in `#figure(...)` so they appear in the
List of Figures; the small snippets use the `typst-preview` helper to show
code and output side by side.

== Data-Driven Plots with lilaq

Every lilaq plot is placed inside an `lq.diagram(...)`, which takes care of
axes, labels, title and legend. You then pass one or more plot objects
(`lq.plot`, `lq.scatter`, …) as positional arguments. The following sections
walk through the most common plot types.

=== Line and Scatter Plots

`lq.plot(x, y)` draws a connected line; `lq.scatter(x, y)` draws markers only.

#typst-preview(
  "Line Plot with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
#lq.diagram(
  width: 5cm, height: 3cm,
  xlabel: $x$, ylabel: $y$,
  lq.plot((1, 2, 3, 4, 5), (1, 4, 9, 16, 25)),
)",
)

#typst-preview(
  "Scatter Plot with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
#lq.diagram(
  width: 5cm, height: 3cm,
  lq.scatter((1, 2, 3, 4, 5), (2, 1, 3, 5, 4)),
)",
)

=== Bar and Stem Plots

`lq.bar` is ideal for categorical data, `lq.stem` for discrete sequences.

#typst-preview(
  "Bar Plot with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
#lq.diagram(
  width: 5cm, height: 3cm,
  lq.bar((1, 2, 3, 4), (3, 7, 2, 5)),
)",
)

#typst-preview(
  "Stem Plot with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
#lq.diagram(
  width: 5cm, height: 3cm,
  lq.stem((1, 2, 3, 4, 5), (2, 4, 3, 5, 1)),
)",
)

=== Error Bars

Uncertainties are attached directly to `lq.plot` via `yerr` (or `xerr`). The
error can be a single constant or an array with one value per data point.

#typst-preview(
  "Error Bars with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
#lq.diagram(
  width: 5cm, height: 3cm,
  lq.plot(
    range(6), (3, 6, 2, 6, 5, 9),
    yerr: (1, 1, .7, .8, .2, .6),
  ),
)",
)

=== Heatmaps and Contours

For data over a 2D grid, `lq.colormesh(x, y, z)` draws a heatmap and
`lq.contour(x, y, z)` draws level curves. `z` may be an explicit grid or a
function `(x, y) => value`.

#figure(
  lq.diagram(
    width: 6cm,
    height: 4cm,
    title: "Colormesh of sin(x)·cos(y)",
    xlabel: $x$,
    ylabel: $y$,
    lq.colormesh(
      lq.linspace(-3, 3, num: 40),
      lq.linspace(-3, 3, num: 40),
      (x, y) => calc.sin(x) * calc.cos(y),
    ),
  ),
  caption: [A colormesh (heatmap) rendered with lilaq],
)

=== Vector Fields

`lq.quiver(x, y, directions)` draws a field of arrows. The `directions`
argument is a function returning a `(dx, dy)` vector for each grid point.

#figure(
  lq.diagram(
    width: 5cm,
    height: 5cm,
    title: "Vector field",
    lq.quiver(
      lq.arange(-2, 3),
      lq.arange(-2, 3),
      (x, y) => (x + y, y - x),
    ),
  ),
  caption: [A vector field rendered with `lq.quiver`],
)

=== Boxplot with Hardcoded Values

A *boxplot* (box-and-whisker plot) summarizes a dataset's distribution using
five statistics: the minimum/maximum (whisker endpoints, excluding outliers),
the quartiles *Q1* and *Q3* (box edges), and the *median* (line inside the
box). Any value further than $1.5 times "IQR"$ (interquartile range
$= "Q3" - "Q1"$) from the box is drawn as an individual outlier point.

In the simplest case, the data is written directly into the source file:

#figure(
  lq.diagram(
    title: "Sample Boxplot (hardcoded)",
    xlabel: "Group",
    ylabel: "Value",
    lq.boxplot(
      (3, 7, 8, 5, 12, 14, 21, 13, 18, 2, 9, 11, 6, 45, 4, 10, 16, 7, 8, 13),
      x: 1,
      fill: blue.lighten(60%),
      stroke: blue.darken(30%),
      median: 2pt + blue.darken(50%),
    ),
  ),
  caption: [Boxplot of a hardcoded sample dataset with one outlier at 45],
)<boxplot-hardcoded>

=== Boxplot from Parsed JSON Data

Hardcoding data into the document is fine for a quick example, but real
datasets usually live in a separate data file. Typst has a *built-in*
`json()` function — no extra package needed — that reads a `.json` file and
converts it into Typst values (objects become dictionaries, arrays become
arrays). Related built-ins are `csv()`, `toml()` and `yaml()`; `json.decode`
parses a JSON *string* instead of a file.

The file `assets/data/boxplot-sample.json` holds the exact same dataset:

#figure(
  caption: [The JSON data file],
  kind: image,
)[```json
{
  "group": "Sample",
  "values": [3, 7, 8, 5, 12, 14, 21, 13, 18, 2,
             9, 11, 6, 45, 4, 10, 16, 7, 8, 13]
}
```]

We load it once and access the fields like any dictionary. Paths are
resolved relative to the file that contains the call — here the chapter lives
in `chapters/`, so we go up one level with `../assets/...`:

#let boxplot-data = json("../assets/data/boxplot-sample.json")

#figure(
  lq.diagram(
    title: "Sample Boxplot (from JSON)",
    xlabel: "Group",
    ylabel: "Value",
    lq.boxplot(
      boxplot-data.values,
      x: 1,
      fill: green.lighten(60%),
      stroke: green.darken(30%),
      median: 2pt + green.darken(50%),
    ),
  ),
  caption: [Boxplot of group "#boxplot-data.group" loaded from JSON — same
    data as @boxplot-hardcoded, so the plot is identical],
)

The loading code is simply:

#figure(
  caption: [Loading data from JSON],
  kind: image,
)[```typ
#let data = json("../assets/data/boxplot-sample.json")
Group *#data.group* has #data.values.len() values.
```]

== Technical Drawing with CeTZ

When a figure is not a plot of data but a schematic drawing, CeTZ gives you a
drawing canvas. You draw inside `cetz.canvas({ ... })` using commands from
`cetz.draw` such as `line`, `circle`, `rect` and `content` (for labels).

#figure(
  cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: 0.6, fill: blue.lighten(70%))
    content((0, 0), [Client])
    circle((5, 0), radius: 0.6, fill: green.lighten(70%))
    content((5, 0), [Server])
    line((0.7, 0), (4.3, 0), mark: (end: ">"))
    content((2.5, 0.35), text(size: 8pt)[request])
    line((4.3, -0.25), (0.7, -0.25), mark: (end: ">"))
    content((2.5, -0.6), text(size: 8pt)[response])
  }),
  caption: [A schematic client–server drawing made with CeTZ],
)

== Diagrams with Pintorita

Pintorita turns textual diagram markup into rendered diagrams. You enable it
once with a `show` rule that routes `pintora` code blocks through
`pintorita.render`, then write the diagram as a normal fenced code block.

#show raw.where(lang: "pintora"): it => pintorita.render(it.text)

#figure(
  kind: image,
  ```pintora
  sequenceDiagram
    autonumber
    Student->>Supervisor: Submit draft
    Supervisor-->>Student: Feedback
    Student->>Supervisor: Submit final thesis
  ```,
  caption: [A sequence diagram rendered with Pintorita],
)
