```@meta
CurrentModule = EpidemicsCFTP
DocTestSetup = quote
 using EpidemicsCFTP
end
```

```@setup CFTP
using EpidemicsCFTP, EpidemicsCFTP.abbreviations
using EpidemicsUtilities
import EpidemicsUtilities: ACTIVATED, REGIONS, BOUNDARIES, BASIC, ELEMENTS, LFE, LFET, LFER, MOST, NFZ

# Specific `Gadfly` and 'Compose' imports, to avoid clashes.
import Compose: context, compose, line, text, fontsize, 
    hcenter, linewidth, stroke
import Gadfly: Coord, Geom, Guide, Scale, Theme, Plot,
    plot, layer, style, set_default_plot_size, pt, mm
using PrettyTables

import Random
Random.seed!(2)

const duration = 2.0;
const α, β     = 0.2, 1.5;
const initial  = SIR(0.0, 5, 1, 0);

iv1 = Innovation(initial.n,
    AIF[I(0.11, 2, 3), I(0.2, 2, 5), P(0.4, 1, 2), I(0.5, 2, 5),  I(0.6, 2, 4), I(0.75, 1, 2), 
        I(0.85, 3, 4), I(0.9, 2, 3), I(1.0, 2, 5), I(1.05, 4, 5), I(1.1, 2, 3), P(1.2, 2, 4), 
        I(1.45, 4, 6), I(1.5, 3, 4),  I(1.6, 3, 5)  ],
    R[  R(0.3, 5), R(0.42, 3), R(0.7, 3), R(0.55, 3), R(0.95, 5), R(1.4, 2), R(1.55, 1),
        R(1.85, 2) ],
    C[  C(1.3, 2), C(0.8, 1), C(1.7, 4), C(1.8, 4), C(1.92, 5) ];
    duration=duration, α=α, β=β)
ev1 = CEvolution(initial, iv1)

flow = table_trajectories1(duration, ev1.trajectory) ;

theme = create_theme(load_theme("../config/theme.yml"))

gadfly_theme = Theme(
    panel_fill=theme.blank,
    default_color=theme.default,
    background_color=theme.background,
    major_label_font="CMU Serif",   minor_label_font="CMU Serif",
    minor_label_color=theme.legend, major_label_color=theme.legend,
    major_label_font_size=8pt,     minor_label_font_size=6pt,
    grid_line_width=0mm,
)

set_default_plot_size(theme.figwidth, theme.figheight)

curves_template = plot(flow, yintercept=1:initial.n,
    Geom.hline(style=:dash, size=0.1mm, color=theme.scaffold),
    Coord.cartesian(xmin=0, xmax=duration, ymin=0, ymax=initial.n + 0.25),
    Guide.xlabel("Process time", orientation=:horizontal),
    style(default_color=theme.background),
    gadfly_theme) ;

push!(curves_template, layer(flow, x=:t, y=:empty, Geom.line,
    style(line_width=2theme.trail, default_color=theme.scaffold))) ;

incidents_template = new_figure(curves_template,
    Scale.y_continuous(labels=(initial.n ≤ EpidemicsUtilities.MAXPOP ?
        i -> EpidemicsUtilities.timelinelabels_circled(i; n=initial.n) :
        i -> EpidemicsUtilities.timelinelabels_bracketed(i; n=initial.n))),
    Guide.yticks(ticks=collect(1:(initial.n))),
    Guide.ylabel("Time lines")) ;

push!(curves_template,
    Scale.y_continuous(labels=(i -> EpidemicsUtilities.timelinelabel_raw(i; n=initial.n))),
    Guide.ylabel("Numbers of individuals")) ;

figure03 = new_figure(curves_template, 
    layer(flow, x=:t, y=:infectives, Geom.step,
        style(line_width=theme.boundary, default_color=theme.colour(I))),
    layer(flow, x=:t, y=:removals, Geom.step,
        style(line_style=[:dashdot], line_width=theme.boundary, default_color=theme.colour(R))),
    layer(flow[flow.susceptibles.!=0, :], x=:t, y=:susceptibles, Geom.step,
        style(line_style=[:dash], line_width=theme.boundary, default_color=theme.scaffold)),
) ;  nothing
```

# Introduction

## Abstract
The package 
[`EpidemicsCFTP`](https://github.com/WilfridSKendall/EpidemicsCFTP.jl)
provides 
[`julia`](https://julialang.org/) 
object types and methods
to perform perfect simulation (_CFTP_) of epidemics conditioned on observed (_active_) removals.
The aim is to provide 
Coupling from the Past
[ProppWilson-1996a](@cite)
for a `S-I-R` epidemic
conditioned on all (observed) removal times and 
making transitions according to the following rates:
```math
\begin{aligned}
S \to S-1\,, \quad I \to I+1 \qquad & \text{ at rate } \alpha \; S I \,,
\cr
I \to I-1\,, \quad R \to R+1 \qquad & \text{ at rate } \beta \; I    \,.
\end{aligned}
```

The simulation mechanism uses "algorithmic time" to vary an event-based simulation such that  
1. detailed balance holds with respect to algorithmic time, 
2. respects the conditioning on active removals,
3. possesses sufficient monotonicity to permit construction of a classical CFTP algorithm.

Given an initial conditional evolution `ev1` and a conditional innovation `iv1`,
here we compute the next step `ev2` in the algorithmic development of `ev1`.
```@example CFTP
iv2c = rand(iv1) ;
ev2 = ev1 ⋄ iv2c ;

figure_zones2 = draw_regions!(deepcopy(incidents_template),                                           # hide
    duration, ev2, theme=theme, select=BOUNDARIES | REGIONS)                                          # hide
depict("snapshot", new_figure(                                                                        # hide
    draw_evolution!(deepcopy(figure_zones2), ev2, duration, theme=theme, select=MOST | LFE | NFZ)),   # hide
    imagetype="pdfonly"                                                                               # hide
) ;  nothing                                                                                          # hide
```

![A snap-shot of a simulation of a single step towards a conditional epidemic.](image/snapshot.pdf)

    
#### Reference

```@bibliography
```


## Information 


#### General advice on installation
General advice on developing a `julia` package is given at 
[`julialang.org/contribute/developing_package`](https://julialang.org/contribute/developing_package/).
Here is a basic summary. Working in `pkg` mode (using `]` at `julia` prompt):  
* Inform `pkg` that the package folder exists and is under development with `dev` (it is best to do this within a particular `julia` environment):  
```julia
(julia) pkg> dev ~/.julia/dev/EpidemicsCFTP
```
* Check that the package can be seen by `julia`:  
```julia
(julia) pkg> status
```
* Check that everything passes by triggering performance of unit tests and doctests:  
```julia
(julia) pkg> test EpidemicsCFTP
```
(Alternatively run `make test` in the directory `EpidemicsCFTP`;
run `make doctest` to perform doctests.)
* Commit and push to `github` with `make commit`.
* Documentation is produced as follows: in directory `EpidemicsCFTP`,  
    - run `make documentation`
    - or `make html-format` (for `gitbook` documentation)
    - or `make pdf-format` (for `pdf` documentation).

#### Specifics concerning `EpidemicsCFTP`  

```@eval
import Markdown, EpidemicsCFTP
Markdown.parse("""
| _Software_       | _Version_                  | _Branch_                  | _Last commit_         |
|:-----------------|:---------------------------|:--------------------------|:----------------------|
| `julia` version  | `$VERSION`                 | --                        |                       |
| `EpidemicsCFTP`  | `$(EpidemicsCFTP.version)` | `$(EpidemicsCFTP.branch)` | $(EpidemicsCFTP.date) |
""")
```

Documentation string for the module (under development):
```@docs
EpidemicsCFTP
```


