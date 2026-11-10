#import "@preview/lilaq:0.6.0" as lq
#import "visualization-helpers.typ": typst-preview, boxplot-figure, heatmap-figure

== Data-Driven Plots with lilaq

Every lilaq plot is placed inside an `lq.diagram(...)`, which takes care of
axes, labels, title and legend. You then pass one or more plot objects
(`lq.plot`, `lq.scatter`, ...) as positional arguments. The following sections
walk through the most common plot types.

=== Line and Scatter Plots

`lq.plot(x, y)` draws a connected line; `lq.scatter(x, y)` draws markers only.
The first example is a real quadratic relationship: a car's braking distance
grows with the *square* of its speed (roughly $s = v^2 / 200$). We store the
speeds in `x` and the braking distances in `y`, then hand them to `lq.plot`:

#typst-preview(
  "Line Plot with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
#let x = (50, 70, 90, 110, 130)       // speed in km/h
#let y = (12.5, 24.5, 40.5, 60.5, 84.5)  // braking distance in m
#lq.diagram(
  width: 5cm, height: 3cm,
  title: [Braking distance],
  xlabel: [Speed $x$], ylabel: [Distance $y$],
  lq.plot(x, y, color: black),
)",
  wrap-figure: true,
)

For a scatter plot the idea is the same, but the points need not follow a
formula. Here `x` holds the body height of five people and `y` their shoe
size, and `lq.scatter` draws one marker per pair:

#typst-preview(
  "Scatter Plot with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
#let x = (160, 170, 175, 180, 190)  // height in cm
#let y = (38, 41, 42, 44, 46)       // shoe size
#lq.diagram(
  width: 5cm, height: 3cm,
  title: [Height vs. shoe size],
  xlabel: [Height $x$], ylabel: [Shoe size $y$],
  lq.scatter(x, y, color: black),
)",
  wrap-figure: true,
)

=== Bar and Stem Plots

`lq.bar` is ideal for categorical data, `lq.stem` for discrete sequences. The
bar example compares the revenue of four quarters: `x` numbers the quarters,
`y` holds the revenue in thousands of euro.

#typst-preview(
  "Bar Plot with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
#let x = (1, 2, 3, 4)            // quarter
#let y = (30, 45, 38, 52)        // revenue in k€
#lq.diagram(
  width: 5cm, height: 3cm,
  title: [Revenue per quarter],
  xlabel: [Quarter $x$], ylabel: [Revenue $y$],
  lq.bar(x, y, fill: luma(80%), stroke: black),
)",
  wrap-figure: true,
)

The stem plot below shows a discrete sequence: `x` is the index and `y` the
corresponding power of two ($y = 2^x$).

#typst-preview(
  "Stem Plot with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
#let x = (0, 1, 2, 3, 4)
#let y = (1, 2, 4, 8, 16)        // powers of two
#lq.diagram(
  width: 5cm, height: 3cm,
  title: [Powers of two],
  xlabel: [Index $x$], ylabel: [Value $y$],
  lq.stem(x, y, color: black),
)",
  wrap-figure: true,
)

=== Error Bars

Uncertainties are attached directly to `lq.plot` via `yerr` (or `xerr`). An
error bar makes the measurement uncertainty of each value visible: a point at
18 with a bar of 1 means the true value is very likely somewhere in the range
18 plus/minus 1, not exactly 18. This matters whenever data is measured rather
than exact (benchmark timings, sensor readings), and scientific work usually
expects it. The error can be a single constant or an array with one value per
data point. In this example `x` is the day, `y` the measured temperature, and
`err` the measurement uncertainty of each value:

#typst-preview(
  "Error Bars with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
#let x = (1, 2, 3, 4, 5, 6)              // day
#let y = (18, 21, 19, 23, 22, 25)        // temperature in °C
#let err = (1, 1, .7, .8, .2, .6)        // uncertainty
#lq.diagram(
  width: 5cm, height: 3cm,
  title: [Daily temperature],
  xlabel: [Day $x$], ylabel: [Temp. $y$],
  lq.plot(x, y, yerr: err, color: black),
)",
  wrap-figure: true,
)

=== Heatmaps and Contours

For data over a 2D grid, `lq.colormesh(x, y, z)` draws a heatmap and
`lq.contour(x, y, z)` draws level curves. A heatmap is useful whenever a value
depends on two categories or coordinates at once and you want to spot the hot
and cold spots at a glance, for example a correlation matrix, a classifier's
confusion matrix, or activity over time.

Assembling the colormesh, the axis ticks and the color-bar legend by hand is
verbose, so this template provides a `heatmap-figure` helper. You pass a 2D
array of values plus optional row and column labels, and it renders a numbered
figure with a matching legend in the grayscale IEEE palette (a larger value is a
darker cell). Here the data is a small table of commit counts per weekday and
time of day, the same idea as the activity graph on a code-hosting site:

#typst-preview(
  "Heatmap with lilaq: commit activity by weekday and time of day",
  "#import \"visualization-helpers.typ\": heatmap-figure
// Rows are weekdays, columns are times of day; each cell is a commit count.
#heatmap-figure(
  [Commit activity],
  (
    (2, 5,  8, 3),   // Mon
    (1, 6,  9, 4),   // Tue
    (0, 4,  7, 2),   // Wed
    (3, 7, 10, 5),   // Thu
    (1, 3,  5, 1),   // Fri
  ),
  xticks: ([night], [morn], [noon], [eve]),
  yticks: ([Mon], [Tue], [Wed], [Thu], [Fri]),
  xlabel: [Time of day], ylabel: [Weekday],
  cbar-label: [Commits],
)",
)

Under the hood the helper calls `lq.colormesh` for the cells and `lq.colorbar`
for the legend. If your surface follows a formula rather than a fixed table,
`lq.colormesh` also accepts a function `(x, y) => value` in place of the array.

=== Vector Fields

`lq.quiver(x, y, directions)` draws a field of arrows. The `directions`
argument is a function returning a `(dx, dy)` vector for each grid point.

#typst-preview(
  "Vector field with lilaq",
  "#import \"@preview/lilaq:0.6.0\" as lq
// Rotating field: each arrow points (x+y, y-x)
#lq.diagram(
  width: 4cm, height: 4cm,
  title: [Vector field],
  xlabel: [Position $x$], ylabel: [Position $y$],
  lq.quiver(
    lq.arange(-2, 3),
    lq.arange(-2, 3),
    (x, y) => (x + y, y - x),
  ),
)",
  wrap-figure: true,
)

=== Boxplot with Hardcoded Values

A *boxplot* (box-and-whisker plot) summarizes a dataset's distribution using
five statistics: the minimum and maximum (whisker endpoints, excluding
outliers), the quartiles *Q1* and *Q3* (box edges), and the *median* (line
inside the box). Any value further than $1.5 dot "IQR"$ (interquartile range
$= "Q3" - "Q1"$) from the box is drawn as an individual outlier point.

In the simplest case, the data is written directly into the source file. Here
the data is the exam scores (out of 100) of a class. One student clearly
underperformed at 30 points, which shows up as an outlier below the whisker.

Rather than assembling an `lq.diagram` by hand, this template provides a
`boxplot-figure` helper. It renders the boxplot as a numbered, referenceable
#link("https://typst.app/docs/reference/model/figure/")[figure] in the
black-and-white IEEE palette (white box, black outline, median, whiskers and
outliers), so distributions stay legible in grayscale print. You pass the data
through `values` and get the figure back, numbered and referenceable:

#typst-preview(
  "Boxplot with lilaq (via the boxplot-figure helper)",
  "#import \"visualization-helpers.typ\": boxplot-figure
#boxplot-figure(
  [Exam scores],
  values: (82, 75, 88, 91, 68, 79,
           85, 72, 95, 30, 77, 84),
  xlabel: [Class $x$], ylabel: [Points $y$],
)",
)

=== Boxplot from Parsed JSON Data

Hardcoding data into the document is fine for a quick example, but real
datasets usually live in a separate data file. Typst has a *built-in*
`json()` function (no extra package needed) that reads a `.json` file and
converts it into Typst values: objects become dictionaries and arrays become
arrays. Related built-ins are `csv()`, `toml()` and `yaml()`; `json.decode`
parses a JSON *string* instead of a file.

The file `assets/data/boxplot-sample.json` holds the scores of a second exam:

#figure(
  caption: [The JSON data file],
  kind: image,
)[```json
{
  "exam": "Math Exam B",
  "scores": [82, 75, 88, 91, 68, 79,
             85, 72, 95, 30, 77, 84]
}
```]

We read the file with Typst's built-in `json()` and feed the `scores` array
straight into `lq.boxplot`. Paths are resolved relative to the file doing the
reading, which lives in `chapters/`, so we go up one level with `../assets/...`.
The preview shows the loading code next to its output:

#typst-preview(
  "Boxplot with lilaq (parsed from JSON)",
  "#import \"@preview/lilaq:0.6.0\" as lq
#let data = json(\"../assets/data/boxplot-sample.json\")
#lq.diagram(
  width: 3.5cm, height: 6cm,
  title: [#data.exam],
  xlabel: [Class $x$], ylabel: [Points $y$],
  xlim: (0, 2),
  lq.boxplot(data.scores, x: 1, width: 0.6,
    fill: luma(92%), stroke: 1pt + black,
    median: 1.5pt + black, whisker: black,
    cap: black, outlier-stroke: black),
)",
  wrap-figure: true,
)

If you need the raw data elsewhere, you can still load it yourself: Typst's
`json()` returns a dictionary you access like any other. `data.exam` is the
title string and `data.scores` the array of numbers.

#figure(
  caption: [Loading data from JSON],
  kind: image,
)[```typ
#let data = json("../assets/data/boxplot-sample.json")
Exam *#data.exam* has #data.scores.len() scores.
```]

To compare several groups, pass one `lq.boxplot` per group with a distinct
`x` position: `xticks` labels each box and `xlim` keeps them evenly spaced.
The block below is commented out. Remove the `/*` and `*/` to render a second
boxplot that compares the exam scores of three parallel classes:

/*
#figure(
  lq.diagram(
    width: 7cm, height: 6cm,
    title: [Exam scores by class],
    xlabel: [Class $x$], ylabel: [Points $y$],
    xlim: (0, 4),
    xticks: ((1, [A]), (2, [B]), (3, [C])),
    lq.boxplot((82, 75, 88, 91, 68, 79, 85, 30), x: 1, width: 0.6,
      fill: luma(100%), stroke: black,
      median: 1.5pt + black, whisker: black, cap: black, outlier-stroke: black),
    lq.boxplot((70, 65, 72, 60, 68, 74, 66, 71), x: 2, width: 0.6,
      fill: luma(80%), stroke: black,
      median: 1.5pt + black, whisker: black, cap: black, outlier-stroke: black),
    lq.boxplot((90, 94, 88, 92, 85, 96, 89, 91), x: 3, width: 0.6,
      fill: luma(60%), stroke: black,
      median: 1.5pt + black, whisker: black, cap: black, outlier-stroke: black),
  ),
  caption: [Exam scores of three parallel classes compared],
)
*/
