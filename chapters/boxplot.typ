#import "@preview/lilaq:0.6.0" as lq

= Boxplot Visualization

A *boxplot* (also called a box-and-whisker plot) summarizes a dataset's distribution using five statistics:

- *Minimum* / *Maximum* — the whisker endpoints (excluding outliers)
- *Q1* — the 25th percentile (lower edge of the box)
- *Median* — the 50th percentile (line inside the box)
- *Q3* — the 75th percentile (upper edge of the box)

Any value further than $1.5 times "IQR"$ (interquartile range = Q3 - Q1) from the box is shown as an individual outlier point.

== Example

The plot below shows the distribution of a sample dataset. The orange line marks the median; the box spans the interquartile range; whiskers extend to the most extreme non-outlier values.

#figure(
  lq.diagram(
    title: "Sample Boxplot",
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
  caption: [Boxplot of a sample dataset with one outlier at 45],
)
