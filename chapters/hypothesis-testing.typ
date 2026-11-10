= Hypothesis Testing

Many empirical theses back up a claim with a statistical test. This chapter
works through one complete example so you can see how the pieces fit together
in Typst: state a hypothesis, compute a test statistic from the data, and reach
a decision. A short normality check with a QQ-plot is included, because the test
used here assumes roughly normal data.

Treat this as *one illustrative example*, not a recipe you must follow. It uses
a one-sample t-test and a QQ-plot, but these are only one choice among many.
Depending on your data and research question you might instead reach for a
two-sample or Welch t-test, a Wilcoxon or Mann-Whitney test, a chi-square test,
or an ANOVA; and you might check normality with Shapiro-Wilk, Kolmogorov-Smirnov
or a histogram with an overlaid curve. Pick what fits your question. Nobody
needs all of these, and most project reports need none of them.

A note on tooling: Typst is a typesetting language, not a statistics system, so
there is no package that performs a full hypothesis test for you. We use the
#link("https://typst.app/universe/package/statastic/")[*statastic*] package for
the descriptive statistics (mean, standard deviation), compute the t-statistic
from those values with a one-line formula, and look up the critical value in a
t-table (Typst cannot invert the t-distribution). In practice the inference is
often done in R or Python and only the results are typeset here; computing it
inside the document, as below, is mainly instructive.

#include "hypothesis-testing-content.typ"
