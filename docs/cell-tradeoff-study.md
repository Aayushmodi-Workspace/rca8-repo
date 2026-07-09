# Cell-tradeoff study — rca8

*Author: [Author]*

Twelve Design Compiler runs of the same RTL, varying three things: which cells were blacklisted
with `set_dont_use`, the library corner, and the clock period. Goal was to build some intuition
for how much of DC's QoR is coming from the macro cells (FADD, HADD, AO, OA, MUX) versus the
underlying primitives, and where the design actually starts to hurt when you take the easy cells
away.

Raw data: [`../results/cell_tradeoff_study.csv`](../results/cell_tradeoff_study.csv).

## Cases 1–5: unconstrained, FF corner, 2.4 ns

Baseline (Case-1) uses the full library — area 145.29 µm², 12 combinational cells, no timing
report since these first runs were left unconstrained (`report_qor` before an SDC was read in).
Excluding FADD/HADD (Case-2) changes nothing — DC wasn't reaching for the composite adder cells
at 2.4 ns anyway, so the restriction costs nothing and gains nothing.

Cases 3–5 start pulling out AO/OA, then OR/AND, then MUX. Area creeps up from 145 to 153 µm² as
DC is forced into more primitive gate combinations to implement the same logic, and Case-4 is the
first run to show hold violations — expected, since a comb.-cell count going from 12 to 23 means
more, shorter logic stages between flops, which is exactly what tightens hold margin. Case-5
(adding the MUX restriction on top) is functionally identical to Case-4 — the synthesizer wasn't
using MUX cells in this datapath regardless.

## Case 6: same restriction set, `compile_ultra`, SDC applied

This is the first run with a real timing constraint (2.4 ns, FF corner) and the first with
`compile_ultra` instead of `compile`. Area drops back to 151.27 µm² and the hold violations from
Case-4/5 clear up — `compile_ultra`'s incremental optimization pass is doing real work here, not
just running longer for the same result. Slack: +1.42 ns.

## Cases 7–11: corner and clock sweeps, full restriction set

This block is where the library restriction actually starts to bite:

- **Case-7 (SS, 2.4 ns)** — same clock as Case-6 but slow-slow corner instead of fast-fast. Area
  more than doubles to 228 µm², buffer count appears for the first time (17 buffers — DC is now
  inserting buffers to fix transition violations it didn't need to worry about at FF), and slack
  goes negative (-0.68 ns). This is the corner effect alone, nothing to do with the clock.
- **Case-8 (TT, 1 ns)** — back to typical corner but the clock is cut to under half of Case-6's.
  Area stays high (231 µm²), slack is still negative but less so (-0.18 ns) than Case-7's slow
  corner.
- **Case-9 (TT, 1.5 ns)** — relaxing to 1.5 ns brings area down to 168 µm² and slack essentially
  to zero (-0.02 ns). This is close to the real limit of what this cell set can hit at TT.
- **Case-10 (TT, 0.5 ns, plain `compile`)** — a clock this aggressive was never going to close;
  area is high (192 µm²) and slack is -0.62 ns.
- **Case-11 (TT, 0.5 ns, `compile_ultra`)** — same clock as Case-10, but with `compile_ultra`.
  Slack doesn't move at all (still -0.62 ns) even though area goes up to 227 µm² and cell count
  jumps to 632. Worth noting on its own: at some point more synthesis effort just moves area
  around without buying timing, because the bottleneck stops being cell selection and becomes the
  ripple-carry critical path itself — eight sequential full-adder stages, no way to synthesize
  around that structurally without changing the RTL to a faster adder topology (carry-lookahead,
  carry-select, etc).

## Case 12: relaxed clock, full restriction set, `compile_ultra`

Back off the clock to 3 ns and the restricted cell set is no longer a problem at all — 160.92 µm²,
+1.63 ns slack, best margin of any constrained case in the table. This is really the same lesson
as Case-9 vs Case-10/11 from the other direction: give the ripple-carry path enough cycle time and
which cells you allow barely matters; starve it and no amount of `compile_ultra` effort recovers
the slack, because the delay is structural, not a synthesis quality problem.

## Takeaway

For a topology like this, the cell library restriction is a second-order effect. The first-order
effect is the eight-stage carry chain, and once the clock period gets close to that chain's
intrinsic delay, nothing DC does — full library, restricted library, `compile` vs `compile_ultra`
— moves the needle. If the target were sub-nanosecond, the right fix isn't a synthesis knob, it's
swapping the RTL to a carry-lookahead or carry-select adder.

**Methodology note:** all twelve cases are DC-stage numbers (`report_qor` / `report_timing` out of
`dc_shell`), single corner per case, no post-route parasitics involved. Area and slack move again
once real placement/routing parasitics enter the picture — compare against the post-route sign-off
numbers in the top-level [README](../README.md) rather than treating any row here as a final
number. The value of this study is the *trend* across cases, not any individual case's absolute
area or slack.
