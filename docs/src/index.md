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

const duration = 2.0;
const α, β     = 0.2, 1.5;
const initial  = SIR(0.0, 5, 1, 0);

include("../src/graphics-setup.jl")

iv1 = Innovation(initial.n,
    AIF[I(0.11, 2, 3), I(0.2, 2, 5), P(0.4, 1, 2), I(0.5, 2, 5),  I(0.6, 2, 4), I(0.75, 1, 2), 
        I(0.85, 3, 4), I(0.9, 2, 3), I(1.0, 2, 5), I(1.05, 4, 5), I(1.1, 2, 3), P(1.2, 2, 4), 
        I(1.45, 4, 6), I(1.5, 3, 4),  I(1.6, 3, 5)  ],
    R[  R(0.3, 5), R(0.42, 3), R(0.7, 3), R(0.55, 3), R(0.95, 5), R(1.4, 2), R(1.55, 1),
        R(1.85, 2) ],
    C[  C(1.3, 2), C(0.8, 1), C(1.7, 4), C(1.8, 4), C(1.92, 5) ];
    duration=duration, α=α, β=β)
ev1 = CEvolution(initial, iv1)
iv2 = rand(iv1) ;
ev2 = ev1 ⋄ iv2 ;
                                                             # hide
figure_zones2a = draw_regions!(deepcopy(incidents_template), # hide
    duration, ev2, theme=theme, select=BOUNDARIES | REGIONS) # hide
depict("snapshot2-adorned", new_figure(                      # hide
    draw_evolution!(deepcopy(figure_zones2a), ev2, duration, # hide
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
to perform perfect simulation (_CFTP_) of epidemics conditioned on observed (_active_) removals.
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
""")
```


## Tutorial
Consider the production of an `S-I-R` epidemic
with `initial` state given by
```@example CFTP
initial                                                        # hide
```
The simulation is driven by an "innovation"`iv1`,
a randomly generated set of potential infections and removals 
(Figure 3.1).
The innovation `iv1` generates an "evolution" `ev1`, an `S-I-R` epidemic trajectory
(Figure 3.2).
```@example CFTP
iv1 = rand(Innovation(initial.n, AI[], duration=duration, α=α, β=β)) ;
ev1 = Evolution(initial, iv1) 
set_default_plot_size(theme.figwidth, 0.5theme.figheight) # hide
depict("tutorial-iv1", new_figure(                             # hide
    draw_innovation!(deepcopy(incidents_template),             # hide
    iv1, theme=theme, select=ELEMENTS))                        # hide
)                                                              # hide
figure_zones1 = draw_regions!(deepcopy(incidents_template),    # hide
    duration, ev1, theme=theme, select=BOUNDARIES | REGIONS)   # hide
depict("tutorial-ev1", new_figure(                             # hide
    draw_evolution!(deepcopy(figure_zones1), ev1, duration,    # hide
        theme=theme, select=MOST)),                            # hide
    imagetype="pdfonly"                                        # hide
) ; nothing                                                    # hide
ev1                                                            # hide
```
![Initial set of incidents (algorithmic time 0).](image/tutorial-iv1.pdf) ![Corresponding evolution (algorithmic time 0).](image/tutorial-ev1.pdf)

We consider a new random innovation `iv2=rand(iv1)` (Figure 3.3).
This innovation `iv2` is used in turn to generate a further `S-I-R` epidemic trajectory `ev2`
(Figure 3.4).
```@example CFTP
iv2 = rand(iv1) ;
ev2 = Evolution(initial, iv2) 
                                                             # hide
depict("tutorial-iv2", new_figure(                           # hide
    draw_innovation!(deepcopy(incidents_template),           # hide
    iv2, theme=theme, select=ELEMENTS))                      # hide
)                                                            # hide
                                                             # hide
figure_zones2 = draw_regions!(deepcopy(incidents_template),  # hide
    duration, ev2, theme=theme, select=BOUNDARIES | REGIONS) # hide
depict("tutorial-ev2", new_figure(                           # hide
    draw_evolution!(deepcopy(figure_zones2), ev2, duration,  # hide
        theme=theme, select=MOST)),                          # hide
    imagetype="pdfonly"                                      # hide
) ; nothing                                                  # hide
ev2                                                          # hide
```
![Incidents generating a single step of algorithmic time.](image/tutorial-iv2.pdf)
 ![State after a single step of algorithmic time.](image/tutorial-ev2.pdf)


    
#### Reference

```@bibliography
```


