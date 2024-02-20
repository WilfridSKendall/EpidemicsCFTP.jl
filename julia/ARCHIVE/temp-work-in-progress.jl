using EpidemicsCFTP, EpidemicsCFTP.abbreviations
import EpidemicsCFTP: evolution_history

import Random

Random.seed!(44)

const population = 6
const duration   = population
const cremoval_times = collect(1:(population-3))
const iv0 = Innovation(population, I[], R[], [C(t,t) for t in cremoval_times])
const initial = SIR(0, population - 1, 1, 0)

const REPLICATES=40


#ev = extremal_evolution(initial, duration, cremoval_times, maximal=false)
ev = extremal_evolution(initial, duration, cremoval_times, maximal=true)

count_tests = 0
for i in 1:REPLICATES
    global count_tests, ev, state
    ev = ev ⋄ generate_innovation(iv0, duration)
    print("Step $i   \t")
    println(EpidemicsCFTP.is_correct_NFZ(ev))

    if !all(t==-Inf for t in ev.NFZ) && any(z isa XI for z in ev.infections)
        println(ev.NFZ)
    end
end
