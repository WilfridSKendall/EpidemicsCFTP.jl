# # `deprecated.jl` contains obsolete functions withdrawn from `FigureUtilities.jl`

# Here is a function which draws infected and removed regions. 
#
# :::{.callout-warning}
# This function should now be superseded by work carried out in `experiment.qmd`:
# delete and remove from exports, as it is replaced by `region_plot`.
# :::
function draw_realized_regions(duration, population, flow; sty=defaultstyle)

  removed_fill = [(a,b) for (a,b) in zip(flow.t, flow.Removals) if b>0]
  push!(removed_fill, (duration, 1))
  infected_fill = [(a,b) for (a,b) in zip(flow.t, flow.Infectives+flow.Removals) if b>0]
  removed1_fill = [(a,b + 1) for (a,b) in zip(flow.t, flow.Removals) if b < population]
  append!(infected_fill, reverse(removed1_fill))

  (context(),
    (context(),          # Trail of Removals
      line([(a,b) for (a,b) in zip(flow.t, flow.Removals) if b>0]),
      line([[(a,b), (duration, b)] for (a,b) in zip(flow.t, flow.Removals) if b>0]),
      stroke(sty.colour(R[])), sty.boundary ),
    (context(),          # Removals trail fill
      polygon(removed_fill),
      fill(sty.colour(R[])), fillopacity(0.1) ),
    
  (context(),          # Trail of Epidemic
    line([zip(flow.t, flow.Infectives+flow.Removals)]),
    line([[(a,b), (duration, b)] 
             for (a,b) in zip(flow.t, flow.Infectives+flow.Removals) if b>0]),
    stroke(sty.colour(A[])), sty.boundary ),
  (context(),          # Epidemic trail fill
    polygon(infected_fill),
    fill(sty.colour(A[])), stroke(sty.colour(A[])), fillopacity(0.1) ), )
end
