# ===============================
using EpidemicsCFTP, EpidemicsCFTP.abbreviations, EpidemicsUtilities
# using DataFrames, PrettyTables
using Colors, Gadfly, Compose


import Distributions: Categorical, DiscreteUniform, Uniform, Poisson
import Random: seed!, rand

import EpidemicsCFTP: alter_sir_infection
import EpidemicsUtilities: ACTIVATED, BOUNDARIES, ELEMENTS, LFET, NFZ ;


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



theme = create_theme(load_theme("config/animation-theme.yml"))
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
iv_ST = InnovationStart_IS(priorprob) ;


# -------------------------------
function innovation_stream(cycle_length;
            evmin=evmin0, iv_null=iv_null, duration=duration, α=α, β=β, size=size)
    stream, initial = [], evmin0.initial
    for iteration ∈ 1:cycle_length
        push!(stream, (rand(iv_null), alter_sir_infection(initial, rand(iv_ST))))
    end
    return stream
end ;

# -------------------------------
function single_step(work, evmin, evmax, iv, new_sir; duration=duration, theme=theme)
    evmin = evmin ⋄ iv ▷ new_sir 
    evmax = evmax ⋄ iv ▷ new_sir 

    # Omit next conditional statement once thoroughly tested!
    if !(evmin ⪯ evmax)
        error("Monotonicity fails")
    end

    return evmin, evmax
end ;

# -------------------------------
# not sure `specified_opacity` has any effect here!
function graphic_component!(work, evmin, evmax, duration, iteration, stream_length; 
                tag="demo-e", theme=theme, fixed_font="JuliaMono", variable_font="HelveticaBold",
                logo="Minimum and maximum evolutions at algorithmic time step")
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
                    select=BOUNDARIES, specified_color=theme.coalesce, order=3)
        image = new_figure(work, info, signal; title=title)
    else
        title  = "$logo $legend"
        work2 = deepcopy(work)

        draw_evolution!(work, evmin, duration, theme=theme, 
                    select=BOUNDARIES, specified_color=colorant"tomato")
        draw_evolution!(work, evmax, duration, theme=theme,
                    select=BOUNDARIES, specified_color=colorant"skyblue")

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
end

@info "Finished"
