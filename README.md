# rca8 — 8-bit Ripple Carry Adder, RTL to GDSII

A sequential 8-bit ripple-carry adder taken end to end through the Synopsys flow — VCS/Verdi for
verification, Design Compiler for synthesis, IC Compiler II for place & route, PrimeTime for
sign-off STA. SAED32nm RVT library, single TT corner. Done as coursework during a 5-day RTL2GDSII
workshop at PDEU; what's here is the scripts and data I actually ran, cleaned up for reading
rather than for a terminal history.

There's nothing exotic in the RTL — eight 1-bit full adders chained on the carry, registered at
the boundary. The point of the exercise wasn't the adder itself, it was two things a block this
small is actually a *good* vehicle for teaching: (1) watching real numbers move as you take a
design through every stage of the flow instead of stopping at synthesis, and (2) a controlled
study of what happens to area, timing, and hold behavior as you strip cells out of DC's search
space with `set_dont_use`. That study is in [`docs/cell-tradeoff-study.md`](docs/cell-tradeoff-study.md).

## Result at sign-off (PrimeTime, post-route)

| Metric | Value |
|---|---|
| Leaf cell count | 95 |
| Design area | 437.45 µm² |
| Clock period | 2.4 ns |
| Max frequency | 416.67 MHz |
| Worst setup slack | +0.32 ns (met) |
| Total power | 1.75 mW |

Slack tightened at every stage of PnR, which is the normal story once real parasitics enter the
picture: floorplan-stage estimates put slack around 1.5 ns, and by the time clock tree and
post-route RC were in play it had settled to +0.32 ns. No hold violations at final sign-off. Setup
and hold reports, QoR, area, and power reports are written out by `sim/PT/run_pt_p1.tcl`; the
slack histogram in `results/screenshots/` was pulled from the same PT session in the GUI.

**Sign-off scope, stated plainly:** this is single-corner (TT, 0.78V, −40°C) STA, on-die variation
folded into the flat clock-uncertainty numbers in the SDC rather than AOCV/POCV. A real tapeout
sign-off would run this across the full PVT corner set — at minimum WCS for setup and BCS for
hold — plus multi-mode (functional/test/scan) if applicable. Fine for what this exercise is
demonstrating; don't read the single-corner number as "signed off" in the production sense.

## Layout

```
rtl/                    1-bit full adder + 8-bit RCA, plus the testbench
constraints/8bit.sdc     clock, I/O delay, uncertainty, max transition
sim/DC/                  Design Compiler: common_setup.tcl, run_dc.tcl
sim/ICCII/               floorplan / power planning / placement / CTS / route
sim/PT/                  PrimeTime sign-off script
results/                 tradeoff study CSV + tool screenshots + PT reports
docs/                    cell-tradeoff-study.md — writeup of the 12-case DC experiment
```

`ref/` (the PDK, the .ndm, the Milkyway tech files) isn't here and won't be — that's the
workshop's licensed library, not mine to redistribute. If you're rerunning this against your own
SAED32 install, point `common_setup.tcl`'s `PDK_PATH` at it and the rest of the flow should run
unmodified; file paths elsewhere assume that same relative layout.

## Flow order

```
rtl/8bit_rtl.v  →  sim/DC (synthesis)  →  sim/ICCII (floorplan → power → placement → CTS → route)  →  sim/PT (sign-off STA)
```

Each ICC2 stage script (`floorplan.tcl`, `power_planning.tcl`, `placement.tcl`, `clock.tcl`,
`route.tcl`) is meant to be sourced in that order against the same open block — they're stage
scripts, not standalone entry points, and each one assumes the block state the previous stage left
behind. `power_planning.tcl` is intentionally empty for this design; see the comment inside it for
why that's a real decision and not an oversight.

## The cell-tradeoff study

`set_dont_use` is normally something you reach for once, to keep DC off a handful of cells you
don't trust in a given corner or for a specific reason (DFT, IR-drop, whatever). Here it's used
deliberately as an experimental knob — the same RTL run twelve times with a shrinking library, a
few different corners, and a few different clock periods, to build intuition for how much of DC's
QoR is coming from the macro cells (FADD, HADD, AO, OA, MUX) versus the underlying primitives.
Full writeup in [`docs/cell-tradeoff-study.md`](docs/cell-tradeoff-study.md), raw numbers in
[`results/cell_tradeoff_study.csv`](results/cell_tradeoff_study.csv).

Short version: restricting to primitive gates only (no FADD/HADD macros, no AO/OA, no MUX) is
free at a relaxed clock — DC finds an equivalent-area, equivalent-timing solution with
`compile_ultra` and the restriction costs nothing. Push the clock down toward sub-nanosecond and
the picture changes fast: area balloons past 220 µm², buffer count climbs into the teens, and
setup slack goes negative no matter how hard you lean on `compile_ultra`. For a design this small
the ripple-carry topology itself is the limiter, not the cell library — eight sequential carry
hops don't go away under synthesis pressure. If the real target were sub-nanosecond, the fix isn't
a synthesis knob, it's swapping the RTL to a carry-lookahead or carry-select adder — a structural
change, not a library change.

## What I'd flag if this were going further

Worth saying out loud rather than leaving implicit, since a repo can otherwise read as more
finished than it is:

- **Single-corner sign-off.** Noted above — this is TT only, not a multi-corner sign-off.
- **Testbench is directed, not self-checking.** Ten hand-picked vectors, verified against
  `$monitor` output and the Verdi waveform by inspection. Adequate for an 8-bit combinational-ish
  block; I would not ship this checking methodology on anything with real corner-case risk.
- **No formal equivalence check (LEC)** between the RTL and the post-synthesis or post-route
  netlist. In a real flow I'd run Formality (or equivalent) at each handoff, particularly
  DC → ICC2 and ICC2 → PT, rather than trusting `write_verilog` output on inspection.
- **`write_parasitics` in `route.tcl` is disabled** — it errored out in the workshop environment
  and I didn't have the time box to chase it down. The `.spef` PrimeTime actually reads for
  sign-off was extracted separately via StarRC; see the comment in that script.

None of these change the numbers above, but they're the difference between "coursework exercise"
and "sign-off ready," and I'd rather say so than let the polish of the writeup imply otherwise.

## Toolchain

VCS, Verdi, Design Compiler (`dc_shell`), IC Compiler II (`icc2_shell`), PrimeTime (`pt_shell`).
SAED32nm RVT standard cells, TT corner (0.78V, −40°C) unless a case in the tradeoff study says
otherwise.
