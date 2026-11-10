#import "@preview/dhbw-oderso:2.4.1": tablefigure, caption-with-source
#import "@preview/merman:0.1.0": mermaid
#import "@preview/lilaq:0.6.0" as lq

// Black-and-white Mermaid palette: black borders, lines and text on white
// fills, with light-gray only for secondary/alternating surfaces. Covers
// flowcharts, class, ER and sequence diagrams. IEEE figures must be legible in
// grayscale and must not encode information through color alone, so this is the
// default for every Mermaid diagram rendered in this template.
#let mermaid-bw-theme = (
  background: "#ffffff",
  primaryColor: "#ffffff",
  primaryBorderColor: "#000000",
  primaryTextColor: "#000000",
  secondaryColor: "#f2f2f2",
  secondaryBorderColor: "#000000",
  secondaryTextColor: "#000000",
  tertiaryColor: "#e6e6e6",
  tertiaryBorderColor: "#000000",
  tertiaryTextColor: "#000000",
  lineColor: "#000000",
  textColor: "#000000",
  mainBkg: "#ffffff",
  nodeBorder: "#000000",
  nodeTextColor: "#000000",
  clusterBkg: "#f2f2f2",
  clusterBorder: "#000000",
  edgeLabelBackground: "#ffffff",
  defaultLinkColor: "#000000",
  classText: "#000000",
  attributeBackgroundColorOdd: "#ffffff",
  attributeBackgroundColorEven: "#f2f2f2",
  actorBkg: "#ffffff",
  actorBorder: "#000000",
  actorTextColor: "#000000",
  signalColor: "#000000",
  signalTextColor: "#000000",
  noteBkgColor: "#f2f2f2",
  noteBorderColor: "#000000",
  noteTextColor: "#000000",
)

// Renders a Mermaid diagram in the black-and-white IEEE palette. Thin wrapper
// around `mermaid(...)` that applies `mermaid-bw-theme` on top of Mermaid's
// "base" theme; pass `theme: none` for Mermaid's default colors.
//
// `scale` resizes the *rendered* diagram, not the box around it. `merman`
// places the SVG with `fit: "contain"`, so a `width`/`height` larger than the
// diagram's native size only pads the box with empty space — the diagram stays
// put (this is why bumping `height` earlier just grew the table row). Typst's
// `scale(reflow: true)` instead magnifies the drawn content itself and grows
// the space it occupies with it, so `scale: 1.5` genuinely makes every diagram
// 50% larger. This is the single knob to resize all diagrams.
#let mermaid-bw(src, width: auto, height: auto, scale: 1, theme: mermaid-bw-theme) = std.scale(
  x: scale * 100%,
  y: scale * 100%,
  reflow: true,
  mermaid(
    src,
    background: none,
    width: width,
    height: height,
    base-theme: if theme == none { none } else { "base" },
    theme: theme,
  ),
)

// Local copy of the `typst-preview` helper (originally in basic_formatting.typ)
// so the visualization chapter also compiles standalone without the template
// entry point. Shows Typst code on the left and its rendered output on the right.
#let typst-preview(caption, typst-code) = tablefigure(
  caption: caption,
  columns: 2,
  align: (_, row) => if row == 0 { center } else { horizon + left },
  table-content: (
    table.header("Typst Code", "Output"),
    align(horizon, box(width: 100%, raw(typst-code, lang: "typ", block: true))),
    box(width: 100%, {
      set heading(outlined: false)
      eval(typst-code, mode: "markup")
    }),
  ),
)

// Shows Mermaid markup on the left and the rendered diagram on the right,
// using the same IEEE-styled `tablefigure` as `typst-preview` so both kinds
// of preview render identically. Uses the black-and-white palette so previews
// match the diagrams produced by `mermaid-figure`. Pass `reference` (a string)
// to make the figure cross-referenceable with `@name`. `scale` is the size
// multiplier forwarded to `mermaid-bw` (1 = native size, 1.5 = 50% larger);
// see the note on `mermaid-bw`.
#let mermaid-preview(caption, src, reference: none, scale: 1) = tablefigure(
  caption: caption,
  reference: reference,
  columns: 2,
  align: (_, row) => if row == 0 { center } else { horizon + left },
  table-content: (
    table.header("Mermaid Markup", "Output"),
    align(horizon, box(width: 100%, raw(src, lang: "mermaid", block: true))),
    box(width: 100%, mermaid-bw(src, scale: scale)),
  ),
)

// Embeds a Mermaid diagram as a proper, numbered `#figure` — the form a
// scientific thesis needs. Unlike a bare `#mermaid(...)` call, this gives the
// diagram a figure number, an entry in the "List of Figures", and a label so
// it can be cross-referenced with `@label` in the running text.
//
//   caption: the figure caption (string or content)
//   src:     the Mermaid markup
//   label:   optional label to reference the figure, e.g. `<fig-flow>`
//   source:  optional citation shown after the caption, e.g. `[@smith2023]`;
//            uses `caption-with-source` so it does not disturb IEEE outline
//            sorting (see the note in `advanced_elements.typ`)
//   width:   rendered diagram width (defaults to `auto`)
//   width:   optional rendered diagram width (defaults to `auto` = native size)
//   height:  optional rendered diagram height (defaults to `auto` = native size)
//   scale:   size multiplier forwarded to `mermaid-bw` (1 = native size,
//            1.5 = 50% larger); the preferred way to resize — see `mermaid-bw`
//   theme:   Mermaid theme variables; defaults to the black-and-white palette.
//            Pass `none` for Mermaid's default colored theme.
#let mermaid-figure(
  caption,
  src,
  label: none,
  source: none,
  width: auto,
  height: auto,
  scale: 1,
  theme: mermaid-bw-theme,
) = {
  let cap = if source == none { caption } else {
    caption-with-source(caption, source)
  }
  let fig = figure(
    mermaid-bw(src, width: width, height: height, scale: scale, theme: theme),
    caption: cap,
  )
  if label == none { fig } else { [#fig #label] }
}

// Draws a lilaq boxplot as a proper, numbered `#figure`, in the black-and-white
// IEEE palette (white box, black outline/median/whiskers/outliers). A boxplot
// summarizes a distribution with five numbers: min/max whiskers, the quartiles
// Q1/Q3 (box edges) and the median (line in the box); points beyond
// 1.5·IQR are drawn as individual outliers.
//
// Data comes in one of two ways — supply exactly one:
//   values: an array of numbers, e.g. `(82, 75, 88, 91)`
//   json:   a path to a JSON file; `field` names the array inside it
//           (default "scores"). Paths resolve relative to THIS helper file,
//           which lives in `chapters/`, so use `../assets/...` just like a
//           direct `json()` call in a chapter.
//
// Important axis parameters are passed straight through:
//   caption, xlabel, ylabel, title (title defaults to the caption),
//   label (for `@ref`), source (citation after the caption),
//   width / height, and `box-width` for the box thickness.
#let boxplot-figure(
  caption,
  values: none,
  json: none,
  field: "scores",
  title: auto,
  xlabel: none,
  ylabel: none,
  label: none,
  source: none,
  width: 3.5cm,
  height: 6cm,
  box-width: 0.6,
) = {
  // Resolve the data from exactly one source.
  let data = if values != none {
    assert(json == none, message: "boxplot-figure: pass either `values` or `json`, not both")
    values
  } else if json != none {
    let loaded = std.json(json)
    // Accept either a bare array file or an object with a data field.
    if type(loaded) == array { loaded } else { loaded.at(field) }
  } else {
    panic("boxplot-figure: supply `values` or `json`")
  }

  let cap = if source == none { caption } else {
    caption-with-source(caption, source)
  }
  let resolved-title = if title == auto { caption } else { title }

  let fig = figure(
    lq.diagram(
      width: width, height: height,
      title: resolved-title,
      xlabel: xlabel, ylabel: ylabel,
      xlim: (0, 2),
      lq.boxplot(
        data,
        x: 1, width: box-width,
        fill: luma(92%),
        stroke: 1pt + black,
        median: 1.5pt + black,
        whisker: black,
        cap: black,
        outlier-stroke: black,
      ),
    ),
    caption: cap,
  )
  if label == none { fig } else { [#fig #label] }
}
