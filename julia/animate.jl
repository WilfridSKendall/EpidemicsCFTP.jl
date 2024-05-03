# ===============================
using EpidemicsCFTP, EpidemicsCFTP.abbreviations, EpidemicsUtilities
# using DataFrames, PrettyTables
using Colors, Gadfly, Compose


import Distributions: Categorical, DiscreteUniform, Uniform, Poisson
import Random: seed!, rand

import EpidemicsCFTP: alter_sir_infection
import EpidemicsUtilities: ACTIVATED, BOUNDARIES, ELEMENTS, LFET, NFZ ;

using DataFrames
import Impute, ShiftedArrays


# ===============================
@info "Initializing"

population     = 120
ε              = 0.001 
interremovals  = [13, 7, 2, 3, ε, ε, 1, 4, 5, 3, 2, ε, 2, ε, 5, 3, 1, 4, ε, 1, 
                   1, 1, 2, ε, 1, 5, ε, 5, 5] 
α, β           = 0.0008, 0.088 
size           = length(interremovals) + 1 
cremoval_times = accumulate(+, interremovals) 
pushfirst!(cremoval_times, 0)
t0             = 0.0
duration       = t0 + maximum(cremoval_times) + 10 ;

initial     = SIR(0, population - 1, 1, 0)
initial_min = SIR(0, population - 1, 1, 0)
initial_max = SIR(0, population - size, size, 0)

evmin0 = extremal_evolution(initial_min, duration, cremoval_times; 
    maximal=false, size=size, α=α, β=β) ;
evmax0 = extremal_evolution(initial_max, duration, cremoval_times, 
    maximal=true,  size=size, α=α, β=β, all_cremovals_observed=true) ;
duration       = t0 + maximum(cremoval_times) + 10 ;


initial     = SIR(0, population - 1, 1, 0)
initial_min = SIR(0, population - 1, 1, 0)
initial_max = SIR(0, population - size, size, 0)

evmin0 = extremal_evolution(initial_min, duration, cremoval_times; 
    maximal=false, size=size, α=α, β=β) ;
evmax0 = extremal_evolution(initial_max, duration, cremoval_times, 
    maximal=true,  size=size, α=α, β=β, all_cremovals_observed=true) ;


seed!(6) ;



theme = create_theme(load_theme("config/animation-theme-dark.yml"))
set_default_plot_size(2theme.figwidth, 0.9theme.figheight)

lines_plot = prepare_screen(initial, evmin0; theme=theme) ;


min_cremovals = [CRemoval(t, n) for (n, t) in enumerate(cremoval_times)]
iv_null       = Innovation(initial.n, Infection[], Removal[], min_cremovals;
                            t0=t0, duration=duration, α=α, β=β, size=size) 


# ===============================
@info "Defining various functions"

# -------------------------------
function transition_probability(k)
    return ((population - k) * α) / ((population - k) * α + β)
end
survival = [transition_probability(k) for k in 1:length(min_cremovals)]
priorprob = (1 .- survival) .* pushfirst!(accumulate(*, survival[1:(end-1)]), 1)
push!(priorprob, 1 - sum(priorprob))
iv_ST = InnovationStart_IS(priorprob, 1) ;


# -------------------------------
function innovation_stream(cycle_length;
            evmin=evmin0, iv_null=iv_null, duration=duration, α=α, β=β, size=size)
    stream, initial = [], evmin0.initial
    for iteration ∈ 1:cycle_length
        push!(stream, (rand(iv_null), rand(iv_ST)))
    end
    return stream
end ;

# -------------------------------
function single_step(work, evmin, evmax, iv, new_start_proposal; 
                            duration=duration, theme=theme)
    evmin = evmin ⋄ iv ▷ new_start_proposal 
    evmax = evmax ⋄ iv ▷ new_start_proposal 

    # Omit next conditional statement once thoroughly tested!
    if !(evmin ⪯ evmax)
        error("Monotonicity fails")
    end

    return evmin, evmax
end ;

# -------------------------------
# See https://invenia.github.io/Impute.jl/latest/api/imputation/#Impute.locf
import Impute, ShiftedArrays
"""
    table_trajectories4(evmin, evmax)

Computes `DataFrame` holding coincident segments of `evman` and `evmax` infection trajectories.

Here is an example.
```
using DataFrames, Impute, ShiftedArrays
start_min = 1
df_min = DataFrame(t=[1,4,5,6], xmin=[2,3,4,5]) ;
start_max = 2
df_max = DataFrame(t=[2,5,6],   xmax=[3,4,5]) ;
```

First consider only those rows for which `xmin` and `xmax` agree. These are coincident vertical jumps,
and so `xmin == xmax` both as recorded at `t` but also necessarily just before `t`.
```
ysegment = filter(row -> row.xmin==row.xmax, innerjoin(df_min, df_max, on = :t))

# output
2×3 DataFrame
 Row │ t      xmin   xmax  
     │ Int64  Int64  Int64 
─────┼─────────────────────
   1 │     5      4      4
   2 │     6      5      5
```

Now capture exactly the vertical jumps in `ysegment`.
```
select!(ysegment, :t => :t0, :xmin => (x -> x .- 1) => :x0, :t => :t1, :xmax => :x1)

# output
1×4 DataFrame
 Row │ t0     x0     t1     x1    
     │ Int64  Int64  Int64  Int64 
─────┼────────────────────────────
   1 │     6      4      6      5
```

Now collect together `df_min` and `df_max` indexed per `t`,
and vertically fill to deal with missing values.
```
xsegment = sort(outerjoin(df_min, df_max, on = :t), :t)
pushfirst!(xsegment, (0, start_min, start_max)) 
Impute.locf!(xsegment)

# output
6×3 DataFrame
 Row │ t      xmin    xmax   
     │ Int64  Int64?  Int64? 
─────┼───────────────────────
   1 │     0       1       2
   2 │     1       2       2
   3 │     2       2       3
   4 │     4       3       3
   5 │     5       4       4
   6 │     6       5       5
```

Re-cast into form of possible _starts_ of horizontal jumps, adding the time from the row below
and dropping the row(s) with missing values.
```
xsegment = dropmissing(select(xsegment, :t => :t0, :xmin => :x0, :t => ShiftedArrays.lead => :t1, :xmax => :x1))

# output
5×4 DataFrame
 Row │ t0     x0     t1     x1    
     │ Int64  Int64  Int64  Int64 
─────┼────────────────────────────
   1 │     0      1      1      2
   2 │     1      2      2      2
   3 │     2      2      4      3
   4 │     4      3      5      3
   5 │     5      4      6      4
```

Now keep only those instances where `x0 == x1`.
```
filter!(row -> row.x0 == row.x1, xsegment)

# output
2×4 DataFrame
 Row │ t0     x0     t1     x1    
     │ Int64  Int64  Int64  Int64 
─────┼────────────────────────────
   1 │     0      1      1      2
   2 │     2      2      4      3
```

So the collection of jumps is the union of these.
```
jumps = vcat(xsegment, ysegment)

# output
5×4 DataFrame
 Row │ t0     x0     t1     x1    
     │ Int64  Int64  Int64  Int64 
─────┼────────────────────────────
   1 │     1      2      2      2
   2 │     4      3      5      3
   3 │     5      4      6      4
   4 │     5      3      5      4
   5 │     6      4      6      5
```
"""
function table_trajectories4(evmin, evmax, duration)
    # Dataframe holding `evmin` infection points (not including start) as (roughly) `(:t, :xmin == i+r)`
    start_min  = evmin.initial.i + evmin.initial.r
    infect_min = [z for z in evmin.history if z isa AbstractInfection]
    df_min  = DataFrame(t = [z.t for z in infect_min ], xmin = start_min .+ (1:length(infect_min)))
    
    # Dataframe holding `evmax` infection points (not including start) as (roughly) `(:t, :xmax == i+r)`
    start_max  = evmax.initial.i + evmax.initial.r
    infect_max = [z for z in evmax.history if z isa AbstractInfection]
    df_max  = DataFrame(t = [z.t for z in infect_max ], xmax = start_max .+ (1:length(infect_max)))
    
    # Dataframe holding common vertical jumps from `(:t, :x0)` to `(:t, :x1)`
    ysegment = filter(row -> row.xmin==row.xmax, innerjoin(df_min, df_max, on = :t))
    select!(ysegment, :t => :t0, :xmin => (x -> x .- 1) => :x0, :t => :t1, :xmin => :x1)
    
    # Now collect together `df_min` and `df_max` indexed per `t`, 
    # and vertically fill to deal with missing values.
    xsegment = sort(outerjoin(df_min, df_max, on = :t), :t)
    pushfirst!(xsegment, (0, start_min, start_max)) 
    Impute.locf!(xsegment)
    
    # Re-cast into form of possible _starts_ of horizontal jumps, 
    # adding the time from the row below and dropping the row(s) with missing values.
    xsegment = dropmissing(select(xsegment, :t => :t0, :xmin => :x0, 
                                            :t => ShiftedArrays.lead => :t1, :xmax => :x1))
    # Keep only those instances where `x0 == x1`.
    filter!(row -> row.x0 == row.x1, xsegment)
    
    # Return the vertical concatenation of these as the collection of jumps.
    return vcat(xsegment, ysegment)
end

# -------------------------------
# not sure `specified_opacity` has any effect here!
oldblue = range(colorant"white", theme.max, length=3)[2]
oldred  = range(colorant"white", theme.min, length=3)[2]

function graphic_component!(work, evmin, evmax, duration, iteration, stream_length; 
                tag="demo-e", theme=theme, fixed_font="JuliaMono", variable_font="HelveticaBold",
                logo="Minimum and maximum evolutions (using IS at t=0) at algorithmic time step")
    lstream = "-$(lpad(stream_length, 4, "0"))"
    legend = "-$(lpad(stream_length-iteration, 4, "0"))"

    about = "Cycle at time $legend/$lstream"
    info  = Guide.annotation(compose(context(), 
                    font(fixed_font), fontsize(12pt), fill(theme.legend), 
                    text(0.5w, 0.95h, about), fill(theme.legend)))

    if evmin ≃ evmax
        title  = "$logo $legend [COALESCED]"
        signal = Guide.annotation(compose(context(), 
                        font(variable_font), fontsize(24pt), 
                        text(0.5w, 0.8h, "COALESCED"), fill(theme.legend)))
        draw_evolution!(work, evmin, duration, theme=theme, 
                    select=BOUNDARIES, specified_color=theme.coalesce, order=4)
        image = new_figure(work, info, signal; title=title)
    else
        title  = "$logo $legend"
        work2 = deepcopy(work)

        merges = layer(table_trajectories4(evmin, evmax, duration),
                           x=:t0, y=:x0, xend=:t1, yend=:x1,
                           Geom.segment, 
                           style(line_width=theme.trail, default_color=theme.joined),
                           order=3)
        push!(work2, merges)
        
        draw_evolution!(work, evmin, duration, theme=theme, 
                    select=BOUNDARIES, specified_color=oldred)
        draw_evolution!(work, evmax, duration, theme=theme,
                    select=BOUNDARIES, specified_color=oldblue)
       
        draw_evolution!(work2, evmin, duration, theme=theme,
                    select=BOUNDARIES, specified_color=theme.min, order=2)
        draw_evolution!(work2, evmax, duration, theme=theme,
                    select=BOUNDARIES, specified_color=theme.max, order=2)
        
        image = new_figure(work2, info; title=title)
    end
                    
    fname   = "animation/$tag-$(lpad(iteration, 4, "0"))"
    draw(PNG("$fname.png"), image)

    return image
    
end ;

# -------------------------------
function graphic_cycle!(stream, canvas; 
        evmin0=evmin0, evmax0=evmax0, tag="demo-e", lines_plot=lines_plot, 
        fixed_font="JuliaMono", variable_font="HelveticaBold", theme=theme)
    # Create deep copies of plot background and of extremal `CEvolution`s
    evmin, evmax = deepcopy(evmin0), deepcopy(evmax0)
    work = deepcopy(lines_plot)
    stream_length = length(stream)

    image = graphic_component!(work, evmin, evmax, duration, 0, stream_length, tag=tag)
    
    for (iteration, pair) ∈ enumerate(stream)
        (evmin, evmax) = single_step(canvas[iteration], evmin, evmax, pair...)
        image = graphic_component!(canvas[iteration], evmin, evmax,
                                duration, iteration, stream_length, tag=tag)
    end

    draw(PNG("animation/$tag.png"), image)

end ;

# ===============================
@info "Running the simulation"

max_length = 256
stream = innovation_stream(max_length)
canvas = [deepcopy(lines_plot) for iteration ∈ 1:max_length]

lexicon = ["01", "02", "03", "04", "05"] 
cycles_lexicon = [(c, 4 * 2^k) for (k, c) ∈ enumerate(lexicon)]    

for (epithet, cycle_length) ∈ cycles_lexicon 
    graphic_cycle!(stream[max_length - cycle_length + 1:max_length], 
        canvas[max_length - cycle_length + 1:max_length], 
        tag="script-$epithet")
end

# ===============================
@info "Creating the GIF"

dt1 = 15
dt2 = 300
for epithet ∈ lexicon
    prefix = "animation/script"
    run(`convert -delay $dt1 $prefix-$epithet-\*.png -delay $dt2 $prefix-$epithet.png -layers Optimize $prefix-$epithet.gif`)
    run(`convert -loop 1 animation/script-\*.gif -layers Optimize animate.gif`)
    # run(`rm animation/script\*.\*`) # DOESN'T WORK ?!
end

@info "Finished"
