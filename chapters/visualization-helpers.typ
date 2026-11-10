#import "@preview/dhbw-oderso:2.4.1": tablefigure, caption-with-source
#import "@preview/merman:0.1.0": mermaid, mermaid-svg
#import "@preview/diagraph:0.3.8": render as _diagraph-render
#import "@preview/lilaq:0.6.0" as lq

// Body font of the dhbw-oderso template. Mermaid diagrams default to a
// sans-serif (`trebuchet ms`), which clashes with the serif body text; we pass
// this through the theme's `fontFamily` so diagram labels match the surrounding
// prose. Keep in sync with the template's `set text(font: ...)` in base.typ.
#let body-font = "New Computer Modern"

// Black-and-white Mermaid palette: black borders, lines and text on white
// fills, with light-gray only for secondary/alternating surfaces. Covers
// flowcharts, class, ER and sequence diagrams. IEEE figures must be legible in
// grayscale and must not encode information through color alone, so this is the
// default for every Mermaid diagram rendered in this template. `fontFamily`
// aligns diagram text with the document body font (see `body-font`).
#let mermaid-bw-theme = (
  background: "#ffffff",
  fontFamily: body-font,
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
  // ER attribute rows: force both to white. Mermaid's "base" theme otherwise
  // tints the even rows a pale beige that is not grayscale-neutral, and the
  // `attributeBackgroundColorEven` key does not reliably override it, so we set
  // a flat white fill for every row instead.
  attributeBackgroundColorOdd: "#ffffff",
  attributeBackgroundColorEven: "#ffffff",
  actorBkg: "#ffffff",
  actorBorder: "#000000",
  // Sequence/ZenUML lifelines default to yellow in the base theme; pin to black.
  actorLineColor: "#000000",
  actorTextColor: "#000000",
  signalColor: "#000000",
  signalTextColor: "#000000",
  noteBkgColor: "#f2f2f2",
  noteBorderColor: "#000000",
  noteTextColor: "#000000",
)

// Strips the color tints Mermaid bakes directly into the SVG as inline colors,
// and forces every text element onto the document body font.
//
// Even with a fully black-and-white theme, Mermaid's "base" theme hardcodes a
// pale yellow (#fff4dd) behind ER attribute rows and derives tinted hsl()/rgb()
// colors that neither theme variables nor scoped CSS override in this renderer.
// We rewrite the generated SVG string before embedding it:
//   - surface colors (fill, background-color, stop-color) -> white
//   - line colors    (stroke)                             -> black
//
// Likewise, the theme's `fontFamily` is honored by some diagram types (e.g.
// flowcharts) but NOT others (class, ER, sequence diagrams hardcode
// `"trebuchet ms",verdana,...` into the SVG), so a serif body font would end
// up next to sans-serif diagram labels. We therefore also rewrite every
// `font-family:<stack>` declaration to the body font directly.
//
// String rewriting is the only reliable way to keep diagrams grayscale-neutral
// and typographically consistent for IEEE in this renderer.
//
// The color replacements are generated from a small table rather than written
// out by hand. For each property we cover both forms the color can take in an
// SVG, the CSS style `prop:hsl(...)` and the XML attribute `prop="hsl(...)"`,
// in one pass. `(?i)` makes the match case-insensitive and `(?:hsl|rgb)a?`
// catches hsl/hsla/rgb/rgba, so a future Mermaid update that switches notation
// does not silently reintroduce color. `background-color` and `stop-color` are
// included because Mermaid emits those for cluster backgrounds and gradient
// stops; the plain `fill`/`stroke` pair alone would leave them tinted.
#let _mermaid-bw-svg-string(src, theme, font) = {
  let s = mermaid-svg(
    src,
    background: none,
    base-theme: if theme == none { none } else { "base" },
    theme: theme,
  )
  s = s.replace("#fff4dd", "#ffffff")
  let color-fn = "(?:hsl|rgb)a?\\([^)]*\\)"
  // (property, replacement): surface colors become white, line colors black.
  let rules = (
    ("fill", "#ffffff"),
    ("background-color", "#ffffff"),
    ("stop-color", "#ffffff"),
    ("stroke", "#000000"),
  )
  for (prop, repl) in rules {
    // CSS style form, e.g. `fill:hsl(...)`
    s = s.replace(regex("(?i)" + prop + ":" + color-fn), prop + ":" + repl)
    // XML attribute form, e.g. `fill="hsl(...)"`
    s = s.replace(regex("(?i)" + prop + "=\"" + color-fn + "\""), prop + "=\"" + repl + "\"")
  }
  // Force the body font onto every text element. The value is a font *stack*
  // (`"trebuchet ms",verdana,arial,sans-serif`), and Mermaid emits the inner
  // quotes XML-escaped as `&quot;`. Two subtleties:
  //   1. The trailing `;` of `&quot;` would make a naive `[^;}]*` stop in the
  //      middle of the stack, so we treat `&quot;` as an atom and consume it
  //      whole rather than breaking on its semicolon.
  //   2. The value lives inside a `style="..."` attribute. If a stack happens to
  //      end without a trailing `;`, a match class that allowed `"`/`>` would run
  //      past the attribute (and even the element) to some far-off `;`, eating
  //      real markup and producing an empty/invalid SVG. So the class also
  //      excludes `"` and `>`, the attribute and tag boundaries.
  //
  // The replacement font name is wrapped in SINGLE quotes: raw double quotes
  // would prematurely close the surrounding `style` attribute.
  let font-value = "(?:&quot;|[^;}\">])*"
  s = s.replace(regex("(?i)font-family:" + font-value), "font-family:'" + font + "'")
  s = s.replace(regex("(?i)font-family=\"[^\"]*\""), "font-family=\"" + font + "\"")
  s
}

// Renders a Mermaid diagram in the black-and-white IEEE palette. Applies
// `mermaid-bw-theme` on top of Mermaid's "base" theme, then runs the generated
// SVG through `_mermaid-bw-svg-string` to remove any residual baked-in tints.
// Pass `theme: none` for Mermaid's default colors (skips the BW post-processing).
//
// `scale` resizes the *rendered* diagram, not the box around it. `merman`
// places the SVG with `fit: "contain"`, so a `width`/`height` larger than the
// diagram's native size only pads the box with empty space; the diagram stays
// put (this is why bumping `height` earlier just grew the table row). Typst's
// `scale(reflow: true)` instead magnifies the drawn content itself and grows
// the space it occupies with it, so `scale: 1.5` genuinely makes every diagram
// 50% larger. This is the single knob to resize all diagrams.
#let mermaid-bw(src, width: auto, height: auto, scale: 1, theme: mermaid-bw-theme, font: body-font) = {
  let img = if theme == none {
    // Default colored theme: render as-is, no grayscale rewriting.
    mermaid(src, background: none, width: width, height: height, base-theme: none)
  } else {
    image(
      bytes(_mermaid-bw-svg-string(src, theme, font)),
      format: "svg",
      width: width,
      height: height,
    )
  }
  std.scale(x: scale * 100%, y: scale * 100%, reflow: true, img)
}

// Local copy of the `typst-preview` helper (originally in basic_formatting.typ)
// so the visualization chapter also compiles standalone without the template
// entry point. Shows Typst code on the left and its rendered output on the right.
//
// The preview itself is a `tablefigure`, so it is numbered in the List of
// Tables. When the evaluated code produces a GRAPHIC that should also appear in
// the List of Figures as a numbered "Figure N", pass `wrap-figure: true`: the
// output cell is then wrapped in a real `#figure` carrying the same caption.
// Leave it `false` (default) for code/text output, and for code that already
// builds its own figure (e.g. the `boxplot-figure`/`heatmap-figure` helpers),
// which would otherwise be double-wrapped.
#let typst-preview(caption, typst-code, wrap-figure: false, scope: (:)) = tablefigure(
  caption: caption,
  columns: 2,
  align: (_, row) => if row == 0 { center } else { horizon + left },
  table-content: (
    table.header("Typst Code", "Output"),
    align(horizon, box(width: 100%, raw(typst-code, lang: "typ", block: true))),
    box(width: 100%, {
      set heading(outlined: false)
      let output = eval(typst-code, mode: "markup", scope: scope)
      if wrap-figure {
        figure(output, caption: caption, kind: image)
      } else {
        output
      }
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
//
// `title` is a SHORT caption for the rendered diagram. When given, the diagram
// is wrapped in a real `#figure`, so it is numbered as a "Figure N" in the List
// of Figures and carries a visible caption of its own (the preview table itself
// is a `tablefigure`, numbered separately in the List of Tables). Keep `title`
// to a few words: the output column is narrow and a long caption would wrap
// over many lines. Pass `none` to render the bare diagram with no figure.
#let mermaid-preview(caption, src, reference: none, scale: 1, title: none) = tablefigure(
  caption: caption,
  reference: reference,
  columns: 2,
  align: (_, row) => if row == 0 { center } else { horizon + left },
  table-content: (
    table.header("Mermaid Markup", "Output"),
    align(horizon, box(width: 100%, raw(src, lang: "mermaid", block: true))),
    box(width: 100%, align(center, if title == none {
      mermaid-bw(src, scale: scale)
    } else {
      figure(mermaid-bw(src, scale: scale), caption: title, kind: image)
    })),
  ),
)

// Embeds a Mermaid diagram as a proper, numbered `#figure`, the form a
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
//   width:   optional rendered diagram width (defaults to `auto` = native size)
//   height:  optional rendered diagram height (defaults to `auto` = native size)
//   scale:   size multiplier forwarded to `mermaid-bw` (1 = native size,
//            1.5 = 50% larger); the preferred way to resize, see `mermaid-bw`
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
// Data comes in one of two ways, supply exactly one:
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

// Draws a lilaq heatmap (colormesh) as a proper, numbered `#figure` in the
// black-and-white IEEE palette (light-to-dark luma ramp, so a larger value
// reads as a darker cell and the plot stays legible in grayscale print). A
// matching color bar is placed next to the diagram as the legend. This wraps
// the full `lq.colormesh` + `lq.colorbar` call so a chapter only has to pass
// the data and labels.
//
//   caption: the figure caption (string or content)
//   values:  a 2D array (rows of equal length); `values.at(r).at(c)` is the
//            cell in row r, column c. Row 0 is drawn at the bottom.
//   xticks / yticks: optional arrays of column / row labels (content). When
//            given, they replace the numeric axis ticks one-for-one.
//   title:   plot title shown above the matrix (defaults to the caption)
//   xlabel / ylabel: axis labels
//   cbar-label: label printed next to the color bar legend
//   label:   optional label to reference the figure with `@label`
//   source:  optional citation shown after the caption
//   width / height: rendered diagram size
#let heatmap-figure(
  caption,
  values,
  xticks: none,
  yticks: none,
  title: auto,
  xlabel: none,
  ylabel: none,
  cbar-label: none,
  label: none,
  source: none,
  width: 4.5cm,
  height: 4cm,
) = {
  let rows = values.len()
  let cols = values.at(0).len()
  let resolved-title = if title == auto { caption } else { title }
  let xaxis = if xticks == none { (:) } else {
    (ticks: xticks.enumerate().map(((i, l)) => (i + 1, l)))
  }
  let yaxis = if yticks == none { (:) } else {
    (ticks: yticks.enumerate().map(((i, l)) => (i + 1, l)))
  }
  let flat = values.flatten()
  // lilaq draws a colormesh as a raster image the size of the data grid (here
  // just cols x rows pixels) stretched to the plot size. A 4x5-pixel image
  // blown up to several cm is smoothed by PDF viewers, so the cells blur into a
  // continuous gradient. We upsample each value into an f x f block, making the
  // embedded image large enough that the cell edges stay crisp after stretch.
  let f = 20
  let zbig = ()
  for row in values {
    let big-row = ()
    for v in row {
      for _ in range(f) { big-row.push(v) }
    }
    for _ in range(f) { zbig.push(big-row) }
  }
  // Sample centers so logical cell c is centered on integer c and spans the
  // half-open interval (c-0.5, c+0.5]; combined with the matching `xlim`/`ylim`
  // below, the border cells are drawn in full and tick labels land on centers.
  let xs = lq.linspace(0.5 + 0.5 / f, cols + 0.5 - 0.5 / f, num: cols * f)
  let ys = lq.linspace(0.5 + 0.5 / f, rows + 0.5 - 0.5 / f, num: rows * f)
  // `min`/`max` must be set explicitly so the color bar maps to the real range.
  let mesh = lq.colormesh(
    xs, ys, zbig,
    map: (luma(100%), luma(0%)),
    min: calc.min(..flat), max: calc.max(..flat),
  )
  let cap = if source == none { caption } else {
    caption-with-source(caption, source)
  }
  let fig = figure(
    {
      // One set rule gives diagram and color bar the same height.
      show: lq.set-diagram(height: height)
      // A two-column grid keeps the color bar beside the diagram. Two inline
      // boxes would wrap the bar under the diagram inside a narrow container
      // (e.g. the right cell of a preview table); a grid never wraps, so the
      // legend always stays to the right.
      //
      // Vertical alignment: the diagram's `title` (top) and `xlabel` (bottom)
      // push its plot area inward. The color bar is itself a diagram, so we give
      // it the SAME title and xlabel wrapped in `hide()`: that reserves exactly
      // the same top/bottom space (not a guessed blank) without drawing them a
      // second time, so the bar lines up precisely with the matrix. A plain
      // blank spacer is the wrong height and leaves the bar shifted down.
      grid(
        columns: (auto, auto, auto),
        column-gutter: 0.5em,
        align: horizon,
        lq.diagram(
          width: width,
          title: resolved-title,
          xlabel: xlabel, ylabel: ylabel,
          xlim: (0.5, cols + 0.5), ylim: (0.5, rows + 0.5),
          xaxis: xaxis, yaxis: yaxis,
          mesh,
        ),
        // cbar-label as its own column, rotated, so it sits between matrix and bar
        if cbar-label != none {
          rotate(-90deg, reflow: true, cbar-label)
        },
        // shift colorbar up and right to align its scale with the matrix plot area
        move(
          dx: 12pt, dy: -12pt,
          lq.colorbar(
            mesh,
            title: hide(resolved-title),
            xlabel: if xlabel == none { none } else { hide(xlabel) },
          ),
        ),
      )
    },
    caption: cap,
  )
  if label == none { fig } else { [#fig #label] }
}

// Wraps diagraph's `render` with the document body font baked in, so call
// sites only need to pass the graph structure without font boilerplate.
#let render-graph(dot, width: auto) = _diagraph-render(
  "graph _wrap {
  graph [fontname=\"" + body-font + "\" fontsize=13]
  node  [fontname=\"" + body-font + "\" fontsize=13]
  edge  [fontname=\"" + body-font + "\" fontsize=12]
  " + dot + "
}",
  width: width,
)

// Like `render-graph` but for directed graphs (digraph).
#let render-digraph(dot, width: auto) = _diagraph-render(
  "digraph _wrap {
  graph [fontname=\"" + body-font + "\" fontsize=13]
  node  [fontname=\"" + body-font + "\" fontsize=13]
  edge  [fontname=\"" + body-font + "\" fontsize=12]
  " + dot + "
}",
  width: width,
)

// Shows DOT markup on the left and the rendered graph on the right.
// Pass the inner DOT body only (no `digraph { ... }` wrapper, no font
// declarations) — the helper adds the wrapper and font defaults so the
// displayed code stays minimal. `directed: true` (default) uses `digraph`;
// pass `directed: false` for undirected graphs. Pass `title` to wrap the
// output in a numbered `#figure`.
#let diagraph-preview(caption, dot, directed: true, width: auto, title: none) = tablefigure(
  caption: caption,
  columns: (1fr, 1fr),
  align: (_, row) => if row == 0 { center } else { horizon + left },
  table-content: (
    table.header([DOT Source], [Output]),
    align(horizon, box(width: 100%, raw(dot, lang: "dot", block: true))),
    box(width: 100%, align(center,
      if title == none {
        if directed { render-digraph(dot, width: width) }
        else        { render-graph(dot, width: width)   }
      } else {
        figure(
          if directed { render-digraph(dot, width: width) }
          else        { render-graph(dot, width: width)   },
          caption: title,
        )
      }
    )),
  ),
)
