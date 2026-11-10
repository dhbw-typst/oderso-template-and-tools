#import "@preview/dhbw-oderso:2.4.1": tablefigure, caption-with-source
#import "@preview/merman:0.1.0": mermaid, mermaid-svg
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
//
// A small centered label is placed under the rendered diagram showing the
// caption text, so the diagram carries a visible description of its own (the
// lilaq previews get this for free from the plot's `title`; a bare Mermaid
// diagram has no such title, so we add one here).
#let mermaid-preview(caption, src, reference: none, scale: 1) = tablefigure(
  caption: caption,
  reference: reference,
  columns: 2,
  align: (_, row) => if row == 0 { center } else { horizon + left },
  table-content: (
    table.header("Mermaid Markup", "Output"),
    align(horizon, box(width: 100%, raw(src, lang: "mermaid", block: true))),
    box(width: 100%, align(center, {
      mermaid-bw(src, scale: scale)
      v(0.5em)
      text(size: 0.85em, style: "italic", caption)
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
