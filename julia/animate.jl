# ===============================
using EpidemicsCFTP, EpidemicsCFTP.abbreviations, EpidemicsUtilities
# using DataFrames, PrettyTables
using Colors, Gadfly, Compose


import Distributions: Categorical, DiscreteUniform, Uniform, Poisson
import Random: seed!, rand

import EpidemicsCFTP: alter_sir_infection
import EpidemicsUtilities: ACTIVATED, BOUNDARIES, ELEMENTS, LFET, NFZ
using DataFrames
import EpidemicsUtilities: table_trajectories4
# import Impute, ShiftedArrays


# ===============================
@info "Initializing"

population     = 120
ε              = 0.001 
interremovals  = [13, 7, 2, 3, ε, ε, 1, 4, 5, 3, 2, ε, 2, ε, 5, 3, 1, 4, ε, 1, 
                   1, 1, 2, ε, 1, 5, ε, 5, 5] 
α, β           = 0.0008, 0.088 
size           = length(interremovals) + 1 
#size           = 120  # This is too high for current programme to make any impact at all!
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


seed!(6) ; # Figures for the talk use `seed!(6)`.



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
iv_ST  = InnovationStart_IS(priorprob, 1) ;
iv_sRWM = InnovationStart_sRWM(priorprob, 0.5, 1) ;
iv_aRWM = InnovationStart_aRWM(priorprob, 0.9, 0.5, 1) ;

# -------------------------------
# Here `innovation_stream` is modified to allow addition of columns
# giving alternative ways to alter start of epidemic, while keeping the previous
# columns unchanged.
function innovation_stream(cycle_length, iv_IS=iv_IS, iv_sRWM=iv_sRWM, iv_aRWM=iv_aRWM;
            evmin=evmin0, iv_null=iv_null, duration=duration, α=α, β=β, size=size)
    stream = []
    datastream = DataFrame(innov_trajectory=AbstractInnovation[], 
                           innov_initial_IS=InnovationStart_IS[])
    for iteration ∈ 1:cycle_length
        push!(datastream, (rand(iv_null), rand(iv_IS)))
    end    
    # Now add columns for `InnovationStart_sRWM` and `InnovationStart_aRWM`.
    datastream.innov_initial_sRWM = rand(iv_sRWM, nrow(datastream))
    datastream.innov_initial_aRWM = rand(iv_aRWM, nrow(datastream))
    # Now add a further column based on the `iv_sRWM` column but such that
    # every other entry uses the `iv_IS` column.
    datastream.innov_initial_MIX = collect((mod(n, 2) == 0 ? z1 : z2)
        for (n, (z1, z2)) in enumerate(zip(datastream.innov_initial_IS, datastream.innov_initial_aRWM)))
    return datastream
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
# not sure `specified_opacity` has any effect here!
oldblue = range(colorant"white", theme.max, length=3)[2]
oldred  = range(colorant"white", theme.min, length=3)[2]

function graphic_component!(work, evmin, evmax, duration, iteration, stream_length; 
                tag="demo-e", theme=theme, fixed_font="JuliaMono", variable_font="HelveticaBold",
                logo="Minimum and maximum evolutions (using `IS` at t=0) at algorithmic time step")
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
    stream_length = nrow(stream)

    image = graphic_component!(work, evmin, evmax, duration, 0, stream_length, tag=tag)
    
    for (iteration, iv) ∈ enumerate(eachrow(stream))
        # CHOICE of strategy for initial value proposals
        (evmin, evmax) = single_step(canvas[iteration], evmin, evmax, iv[1], iv[2]) # This is for `iv_IS`
#        (evmin, evmax) = single_step(canvas[iteration], evmin, evmax, iv[1], iv[3]) # This is for `iv_sRWM`
#       (evmin, evmax) = single_step(canvas[iteration], evmin, evmax, iv[1], iv[4]) # This is for `iv_aRWM`
#         (evmin, evmax) = single_step(canvas[iteration], evmin, evmax, iv[1], iv[5]) # This is a mixture

        image = graphic_component!(canvas[iteration], evmin, evmax,
                                duration, iteration, stream_length, tag=tag)
    end

    draw(PNG("animation/$tag.png"), image)

end ;

# ===============================
@info "Preparing the simulation"

max_length = 256 # This influences CFTP outcome _via_ `cycle_length` in `innovation_stream`.
stream = innovation_stream(max_length, iv_ST, iv_sRWM, iv_aRWM)
canvas = [deepcopy(lines_plot) for iteration ∈ 1:max_length]

#lexicon = ["01", "02", "03", "04", "05", "06", "07"]      # NEEDS max_length = 512 
#lexicon = ["01", "02", "03", "04", "05", "06"]            # NEEDS max_length = 256
lexicon = ["01", "02", "03", "04", "05"] # For reduced "size" and IS, only need up to `"05"`
cycles_lexicon = [(c, 4 * 2^k) for (k, c) ∈ enumerate(lexicon)]    

# ===============================
@info "Iterating through the simulation"

for (epithet, cycle_length) ∈ cycles_lexicon 
    @info "Now processing script-$epithet"
    graphic_cycle!(last(stream, cycle_length), 
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
end
run(`convert -loop 1 animation/script-\*.gif -layers Optimize animate.gif`)

@info "Finished"
