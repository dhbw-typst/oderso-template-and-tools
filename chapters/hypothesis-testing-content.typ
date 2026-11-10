#import "visualization-helpers.typ": typst-preview

== The Example and the Hypotheses

A bottling machine is supposed to fill each bottle with exactly 500 ml. We take
a sample of ten bottles and measure their actual fill volume (in ml):

#align(center, box(width: 90%)[
  498.2, 502.1, 499.5, 501.3, 497.8, 500.6, 503.2, 498.9, 500.1, 499.7
])

We want to know whether the machine is still calibrated, that is, whether the
mean fill volume differs from the target of 500 ml. This gives a two-sided
one-sample test with a significance level of $alpha = 0.05$:

$ H_0: mu = 500 quad "(the machine is calibrated)" $
$ H_1: mu eq.not 500 quad "(it is miscalibrated)" $

== Descriptive Statistics with statastic

First we need the sample size $n$, the sample mean $overline(x)$ and the sample
standard deviation $s$. The #link("https://typst.app/universe/package/statastic/")[*statastic*]
package computes the mean and standard
deviation for us; its standard deviation already uses the $n - 1$ divisor (the
sample, not population, estimate), which is exactly what a t-test needs:

#typst-preview(
  "Sample mean and standard deviation via statastic",
  "#import \"@preview/statastic:1.0.0\": arrayAvg, arrayStd
#let data = (498.2, 502.1, 499.5, 501.3, 497.8,
             500.6, 503.2, 498.9, 500.1, 499.7)
#let n = data.len()
#let mean = arrayAvg(data)
#let sd = arrayStd(data)
n = #n \\
mean = #calc.round(mean, digits: 2) ml \\
sd = #calc.round(sd, digits: 3) ml",
)

== The Test Statistic

The one-sample t-statistic measures how many standard errors the sample mean
lies away from the target value $mu_0 = 500$:

$ t = (overline(x) - mu_0) / (s \/ sqrt(n)) $

This is a single formula built on the two values `statastic` gave us. With
$overline(x) = 500.14$, $s = 1.704$ and $n = 10$ we get $t approx 0.26$:

#typst-preview(
  "Computing the t-statistic from the sample values",
  "#import \"@preview/statastic:1.0.0\": arrayAvg, arrayStd
#let data = (498.2, 502.1, 499.5, 501.3, 497.8,
             500.6, 503.2, 498.9, 500.1, 499.7)
#let n = data.len()
#let mean = arrayAvg(data)
#let sd = arrayStd(data)
#let mu0 = 500
#let t = (mean - mu0) / (sd / calc.sqrt(n))
t = #calc.round(t, digits: 3)",
)

== The Decision

We compare the test statistic against the critical value of the t-distribution.
For a two-sided test at $alpha = 0.05$ with $n - 1 = 9$ degrees of freedom, that
value is $t_(0.975, thin 9) = 2.262$. This number comes from a t-table: Typst
cannot invert the t-distribution, so the critical value is looked up rather than
computed.

Because $|t| = 0.26 < 2.262$, the test statistic stays inside the acceptance
region. We therefore *fail to reject* $H_0$: the sample gives no evidence that
the machine is miscalibrated. Note the careful wording. Failing to reject $H_0$
is not the same as proving it true; it only means the data are consistent with
the target value.

#block(
  fill: luma(95%),
  inset: 8pt,
  radius: 3pt,
  width: 100%,
)[
  *Using your own data.* This is a worked illustration, not a finished
  calculator. If you paste your own values into the `data` array, the sample
  size, mean, standard deviation and the t-statistic update on their own.
  Three things do *not* update automatically and must be adjusted by hand: the
  target value `mu0`, the critical value (look up $t_(1 - alpha\/2, thin n-1)$
  for your own sample size and significance level in a t-table), and the final
  comparison and conclusion sentence above. The numbers quoted in the running
  text ($500.14$, $1.704$, $0.26$) are likewise specific to this example.
]

== Checking Normality with a QQ-plot

The t-test assumes the data are roughly normally distributed. A quick visual
check is a *QQ-plot*: it draws each sorted sample value against the value you
would expect at that position if the data were perfectly normal (its
theoretical quantile). If the points lie close to a straight line, normality is
plausible.

The theoretical quantiles for $n = 10$ are the standard-normal quantiles of the
plotting positions $(i - 0.5) \/ n$. They are the same for any sample of size
ten, so we list them directly rather than computing them (no Typst package
inverts the normal distribution). The reference line shows where the points
would fall for perfectly normal data, $y = overline(x) + s dot x$:

#typst-preview(
  "QQ-plot of the sample against normal quantiles",
  "#import \"@preview/lilaq:0.6.0\" as lq
#let data = (498.2, 502.1, 499.5, 501.3, 497.8,
             500.6, 503.2, 498.9, 500.1, 499.7)
#let sorted = data.sorted()
// Standard-normal quantiles for n = 10 (rankit values).
#let theo = (-1.55, -1.00, -0.65, -0.37, -0.12,
             0.12, 0.37, 0.65, 1.00, 1.55)
#let mean = 500.14
#let sd = 1.704
#let line-y = theo.map(q => mean + sd * q)
#lq.diagram(
  width: 6cm, height: 5cm,
  title: [QQ-plot],
  xlabel: [Theoretical quantiles $x$],
  ylabel: [Sample values $y$],
  lq.plot(theo, line-y, color: luma(50%), mark: none),
  lq.scatter(theo, sorted, color: black),
)",
)

The points hug the reference line without any systematic bend, so treating the
data as normal is reasonable and the t-test is appropriate here. For a formal
answer you would run a dedicated normality test instead, which again is done
outside Typst.
