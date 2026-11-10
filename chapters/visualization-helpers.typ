#import "@preview/dhbw-oderso:2.4.1": tablefigure
#import "@preview/merman:0.1.0": mermaid

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
// of preview render identically. The diagram is scaled down to fit its column.
#let mermaid-preview(caption, src) = tablefigure(
  caption: caption,
  columns: 2,
  align: (_, row) => if row == 0 { center } else { horizon + left },
  table-content: (
    table.header("Mermaid Markup", "Output"),
    align(horizon, box(width: 100%, raw(src, lang: "mermaid", block: true))),
    box(width: 100%, mermaid(src, background: none, width: 4.5cm)),
  ),
)
