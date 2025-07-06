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

import Random
Random.seed!(2)

duration = 2.0;
α, β     = 0.2, 1.5;
initial  = SIR(0.0, 5, 1, 0);

include("../src/graphics-setup.jl")

iv0 = Innovation(initial.n,
    AIF[I(0.11, 2, 3), I(0.2, 2, 5), P(0.4, 1, 2), I(0.5, 2, 5),  I(0.6, 2, 4), I(0.75, 1, 2), 
        I(0.85, 3, 4), I(0.9, 2, 3), I(1.0, 2, 5), I(1.05, 4, 5), I(1.1, 2, 3), P(1.2, 2, 4), 
        I(1.45, 4, 6), I(1.5, 3, 4),  I(1.6, 3, 5)  ],
    R[  R(0.3, 5), R(0.42, 3), R(0.7, 3), R(0.55, 3), R(0.95, 5), R(1.4, 2), R(1.55, 1),
        R(1.85, 2) ],
    C[  C(1.3, 2), C(0.8, 1), C(1.7, 4), C(1.8, 4), C(1.92, 5) ];
    duration=duration, α=α, β=β)
ev0 = CEvolution(initial, iv0)
iv1 = rand(iv0) ;
ev1 = ev0 ⋄ iv1 ;
                                                             # hide
figure_zones2a = draw_regions!(deepcopy(incidents_template), # hide
    duration, ev1, theme=theme, select=BOUNDARIES | REGIONS) # hide
depict("snapshot2-adorned", new_figure(                      # hide
    draw_evolution!(deepcopy(figure_zones2a), ev1, duration, # hide
        theme=theme, select=MOST | LFE | NFZ)),              # hide
    imagetype="pdfonly"                                      # hide
) ;  nothing                                                 # hide
```

# Introduction

## Abstract
The package 
[`EpidemicsCFTP`](https://github.com/WilfridSKendall/EpidemicsCFTP.jl)
provides 
[`julia`](https://julialang.org/) 
object types and methods
to perform perfect simulation (_CFTP_) of epidemics conditioned on 
the set of observed (_active_) removal times.
The aim is to provide 
Coupling from the Past
[ProppWilson-1996a](@cite)
for a stochastic `S-I-R` epidemic
conditioned on all (observed) removal times and 
making transitions according to the following rates:
```math
\begin{aligned}
S \to S-1\,, \quad &I \to I+1 \qquad && \text{ at rate } \alpha \; S I \,,
\cr
I \to I-1\,, \quad &R \to R+1 \qquad && \text{ at rate } \beta \; I    \,.
\end{aligned}
```

The simulation mechanism uses "algorithmic time" to vary an event-based simulation of the epidemic trajectory such that:  
1. the random trajectory converges in law to the conditioned `S-I-R` epidemic as algorithmic time tends to infinity, 
2. successive trajectories maintain the conditioning on active (observed) removals,
3. the mechanism possesses sufficient monotonicity to permit construction of a classical CFTP algorithm.

Figure 1.1 (see also cover page of manual) illustrates a single step of this procedure.

![Snap-shot of single algorithmic time step towards a conditional epidemic equilibrium,
together with associated geometric structures.](image/snapshot2-adorned.pdf)


## Information 

### General advice on installation
General advice on developing a `julia` package is given at 
[`julialang.org/contribute/developing_package`](https://julialang.org/contribute/developing_package/).
Here is a basic summary. Working in `pkg` mode (using `]` at `julia` prompt):

* Inform `pkg` that the package exists and is under development with `dev` (it is best to do this within a particular `julia` environment) using `pkg> dev ~/.julia/dev/EpidemicsCFTP`
* Check that the package can be seen by `julia` using `pkg> status`
* Check for code problems by triggering unit tests and doctests using `pkg> test EpidemicsCFTP`  
(Alternatively run `make test` in the directory `EpidemicsCFTP`;
run `make doctest` to perform doctests alone.)
* Commit and push to `github` with `make commit`.
* Documentation is produced as follows: in directory `EpidemicsCFTP`,  
    - run `make documentation`
    - or `make html-format` (for `gitbook` documentation)
    - or `make pdf-format` (for `pdf` documentation).

### Specifics concerning `EpidemicsCFTP`  
```@docs
EpidemicsCFTP
```

Version information:
```@eval
import Markdown, EpidemicsCFTP
Markdown.parse("""
| _Software_       | _Version_                  | _Branch_                  | _Last commit_         |
|:-----------------|:---------------------------|:--------------------------|:----------------------|
| `julia` version  | `$VERSION`                 | --                        |                       |
| `EpidemicsCFTP`  | `$(EpidemicsCFTP.version)` | `$(EpidemicsCFTP.branch)` | $(EpidemicsCFTP.date) |
""")```@example CFTP
civ2   = rand(civ1)
evmin2 = evmin1 ⋄ civ2 ;
evmax2 = evmax1 ⋄ civ2 ;
                                                               # hide
tutorial_evmin2 = new_figure(                                  # hide
    draw_evolution!(deepcopy(incidents_template), evmin2,      # hide
        duration, theme=theme, select=MOST))                   # hide
tutorial_evmax2 = new_figure(                                  # hide
    draw_evolution!(deepcopy(incidents_template), evmax2,      # hide
        duration, theme=theme, select=MOST))                   # hide
                                                               # hide
depict("tutorial-evmin2-evmax2", new_figure(                   # hide
    hstack(tutorial_evmin2, tutorial_evmax2)),                 # hide
    imagetype="pdfonly"                                        # hide
) ; nothing                                                    # hide
```
![Algorithmic time 2. Left: minimal. Right: maximal.](image/tutorial-evmin2-evmax2.pdf) 

```


## Tutorial
### Unconditional epidemic
Consider the simulation of an `S-I-R` epidemic
in a population of 6 individuals, with 1 initial infective.
The simulation is driven by an "innovation" `iv0`,
a randomly generated set of potential infections and removals 
(Figure 3.1, left).
This innovation `iv0` generates an "evolution" `ev0`, an `S-I-R` epidemic trajectory
(Figure 3.1, right).
![Algorithmic time 0. Left: incidents. Right: incidents with superimposed trajectory.](image/tutorial-iv0-ev0.pdf) 
```@example CFTP
initial  = SIR(0.0, 5, 1, 0);
iv0 = rand(Innovation(initial.n, AI[], duration=duration, α=α, β=β)) ;
ev0 = Evolution(initial, iv0)
                                                               # hide
set_default_plot_size(theme.figwidth, 0.75theme.figheight)     # hide
                                                               # hide
tutorial_iv0 = new_figure(                                     # hide
    draw_innovation!(deepcopy(incidents_template),             # hide
    iv0, theme=theme, select=ELEMENTS))                        # hide
figure_zones1 = draw_regions!(deepcopy(incidents_template),    # hide
    duration, ev0, theme=theme, select=BOUNDARIES | REGIONS)   # hide
tutorial_ev0 = new_figure(                                     # hide
    draw_evolution!(deepcopy(figure_zones1), ev0, duration,    # hide
        theme=theme, select=MOST))                             # hide
                                                               # hide
depict("tutorial-iv0-ev0", new_figure(                         # hide
    hstack(tutorial_iv0, tutorial_ev0)),                       # hide
    imagetype="pdfonly"                                        # hide
) ; nothing                                                    # hide
                                                               # hide
ev0                                                            # hide
```

We consider a new random innovation `iv1` (Figure 3.2, left).
This innovation `iv1` is used in turn to generate a further `S-I-R` epidemic trajectory `ev1`
(Figure 3.2, right).
```@example CFTP
iv1 = rand(iv0) ;
ev1 = Evolution(initial, iv1) 
                                                               # hide
tutorial_iv1 = new_figure(                                     # hide
    draw_innovation!(deepcopy(incidents_template),             # hide
    iv1, theme=theme, select=ELEMENTS))                        # hide
figure_zones2 = draw_regions!(deepcopy(incidents_template),    # hide
    duration, ev1, theme=theme, select=BOUNDARIES | REGIONS)   # hide
tutorial_ev1 = new_figure(                                     # hide
    draw_evolution!(deepcopy(figure_zones2), ev1, duration,    # hide
        theme=theme, select=MOST))                             # hide
                                                               # hide
depict("tutorial-iv1-ev1", new_figure(                         # hide
    hstack(tutorial_iv1, tutorial_ev1)),                       # hide
    imagetype="pdfonly"                                        # hide
) ; nothing                                                    # hide
ev1                                                            # hide
```
![Algorithmic time 1. Left: incidents. Right: incidents with superimposed trajectory.](image/tutorial-iv1-ev1.pdf) 


### Conditional epidemic
Now consider the same `S-I-R` epidemic, but conditioned by requiring
removals to occur at times
```@example CFTP
ctimes = collect(0.05:0.4:2.0)
crem = [R(t,i) for (i,t) in enumerate(0.05:0.4:2.0)] ;
println(ctimes)                          # hide
```
We consider simulations beginning at maximal and minimal trajectories
compatible with the conditioning (Figure 3.3).
```@example CFTP
evmax0 = extremal_evolution(initial, duration, ctimes) ;
evmin0 = extremal_evolution(initial, duration, ctimes; maximal=false) ;
                                                               # hide
tutorial_evmin0 = new_figure(                                  # hide
    draw_evolution!(deepcopy(incidents_template), evmin0,      # hide
        duration, theme=theme, select=MOST))                   # hide
tutorial_evmax0 = new_figure(                                  # hide
    draw_evolution!(deepcopy(incidents_template), evmax0,      # hide
        duration, theme=theme, select=MOST))                   # hide
                                                               # hide
depict("tutorial-evmin0-evmax0", new_figure(                   # hide
    hstack(tutorial_evmin0, tutorial_evmax0)),                 # hide
    imagetype="pdfonly"                                        # hide
) ; nothing                                                    # hide
```
![Algorithmic time 0. Left: minimal. Right: maximal.](image/tutorial-evmin0-evmax0.pdf) 

Maximal and minimal trajectories are now evolved by three steps
in algorithmic time, using the same innovations `civ1` then `civ2`,
`civ3`
(Figures 3.4, 3.5, 3.6).
```@example CFTP
civ1   = rand(Innovation(initial.n, AI[x for x in evmin0.cremovals], 
            duration=duration,α=α, β=β))
evmin1 = evmin0 ⋄ civ1 ;
evmax1 = evmax0 ⋄ civ1 ;
                                                               # hide
tutorial_evmin1 = new_figure(                                  # hide
    draw_evolution!(deepcopy(incidents_template), evmin1,      # hide
        duration, theme=theme, select=MOST))                   # hide
tutorial_evmax1 = new_figure(                                  # hide
    draw_evolution!(deepcopy(incidents_template), evmax1,      # hide
        duration, theme=theme, select=MOST))                   # hide
                                                               # hide
depict("tutorial-evmin1-evmax1", new_figure(                   # hide
    hstack(tutorial_evmin1, tutorial_evmax1)),                 # hide
    imagetype="pdfonly"                                        # hide
) ; nothing                                                    # hide
```
![Algorithmic time 1. Left: minimal. Right: maximal.](image/tutorial-evmin1-evmax1.pdf) 

```@example CFTP
civ2   = rand(civ1)
evmin2 = evmin1 ⋄ civ2 ;
evmax2 = evmax1 ⋄ civ2 ;
                                                               # hide
tutorial_evmin2 = new_figure(                                  # hide
    draw_evolution!(deepcopy(incidents_template), evmin2,      # hide
        duration, theme=theme, select=MOST))                   # hide
tutorial_evmax2 = new_figure(                                  # hide
    draw_evolution!(deepcopy(incidents_template), evmax2,      # hide
        duration, theme=theme, select=MOST))                   # hide
                                                               # hide
depict("tutorial-evmin2-evmax2", new_figure(                   # hide
    hstack(tutorial_evmin2, tutorial_evmax2)),                 # hide
    imagetype="pdfonly"                                        # hide
) ; nothing                                                    # hide
```
![Algorithmic time 2. Left: minimal. Right: maximal.](image/tutorial-evmin2-evmax2.pdf) 

```@example CFTP
civ3   = rand(civ1)
evmin3 = evmin2 ⋄ civ3 ;
evmax3 = evmax2 ⋄ civ3 ;
                                                               # hide
tutorial_evmin3 = new_figure(                                  # hide
    draw_evolution!(deepcopy(incidents_template), evmin3,      # hide
        duration, theme=theme, select=MOST))                   # hide
tutorial_evmax3 = new_figure(                                  # hide
    draw_evolution!(deepcopy(incidents_template), evmax3,      # hide
        duration, theme=theme, select=MOST))                   # hide
                                                               # hide
depict("tutorial-evmin3-evmax3", new_figure(                   # hide
    hstack(tutorial_evmin3, tutorial_evmax3)),                 # hide
    imagetype="pdfonly"                                        # hide
) ; nothing                                                    # hide
```
![Algorithmic time 3. Left: minimal. Right: maximal.](image/tutorial-evmin3-evmax3.pdf) 

Observe that monotonicity is maintained: proving this is a significant
piece of theoretical work [ProppWilson-1996a](@cite). 
Eventually the trajectories derived
from the original maximal trajectory will coalesce with those
derived from the original minimal trajectory. This phenomenon
makes perfect simulation possible.

#### Reference

```@bibliography
```


