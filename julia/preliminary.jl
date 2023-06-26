# Required modules
using Colors, Compose, DataFrames, Measures
import Cairo, Fontconfig, Gadfly, EpidemicsCFTP # EpidemicsCFTP under development!
gf = Gadfly ; epi = EpidemicsCFTP ; 

# Create union of composite `AbstractIncident` types.
function unionize_composites(a::Type)::Type
  xl = Type[x for x in subtypes(a)]
  if length(xl) == 0
    return a # return a composite type
  else
    xl = Type[unionize_composites(y) for y in xl]
    return reduce((t1, t2) -> Union{t1, t2}, xl) # return a union type
  end
end

BasicIncident = unionize_composites(epi.AbstractIncident) ;

# 
    
# Basic image template elements
function time_axis(duration; sty=style)
  labellocs = [(x)cx for x in 0:duration]
  step = 10^floor(Int, log10(duration))
  tic1  = [(((x)cx,sty.height), ((x)cx, sty.height+sty.tic))    for x in 0:1.0step:duration]
  tic2  = [(((x)cx,sty.height), ((x)cx, sty.height+sty.tic))    for x in 0:0.5step:duration]
  tic3  = [(((x)cx,sty.height), ((x)cx, sty.height+0.5sty.tic)) for x in 0:0.1step:duration]

  (context(), # Returned value of function!
    (context(), text(labellocs, [sty.height + sty.yloc], ["$i" for i in 0:duration], 
      [hcenter], [vcenter]), fontsize(5pt), font("TimesRoman"), ),
    (context(), line([(0cx, sty.height), ((duration)cx, sty.height)]),
      stroke(sty.scaffold), linewidth(0.5mm) ),
    (context(), line(tic1), stroke(sty.scaffold), linewidth(0.2mm)),
    (context(), line(tic2), stroke(sty.scaffold), linewidth(0.1mm)),
    (context(), line(tic3), stroke(sty.scaffold), linewidth(0.1mm)), )
end
    
function time_threads(duration, population; sty=style)
  circlabels   = [string(Char(0x00002460+i-1)) for i in 1:population]

  (context(), # Returned value of function!
    (context(), text([sty.xlab], [(k)cy for k in 1:population], circlabels,
      [hleft], [vcenter]), fontsize(10pt), font("TimesRoman"), ),
    (context(), line([[(0cx, (k)cy), ((duration)cx, (k)cy)] for k in 1:population]), 
      stroke(sty.scaffold), linewidth(0.5mm), ), )
end 
    
function scaffolding(duration, population; sty=style)
  (context(), sty.region, time_axis(duration, sty=sty), 
              time_threads(duration, population, sty=sty))
end 

# Drawing functions (`Compose`)
function draw_incident(xl::Vector{T}; sty=style) where T<:BasicIncident
  if length(xl) > 0
    (context(),
      (context(),
        text(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), 
             map(x -> string(x), xl), [hcenter], [vcenter]), 
        fontsize(5pt), font("Helvetica")),
      (context(),
        circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [sty.radius]), 
        fill(sty.blank), stroke(csty(xl))), )
  end
end

function draw_realized(xl::Vector{T}; sty=style) where T<:BasicIncident
  (context(),
    (context(),
    circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [sty.radius]), 
    sty.active, fill(csty(xl)), fillopacity(0.2), stroke(csty(xl)) ),
    if eltype(xl)<:epi.AbstractInfection
      (context(),
      circle(map(x->(x.t)cx, xl), map(x -> x.infectee, xl), [sty.smradius]),
       sty.active, fill(csty(xl)), fillopacity(0.5), stroke(csty(xl)))
    end, )
end 

function draw_connect(xl::Vector{T}; activated=false, sty=style) where T<:BasicIncident
  if ! (eltype(xl)<:epi.AbstractInfection)
    return
  end
  (context(), 
    line(map(x -> [((x.t)cx, (x.target)cy+sty.radius), ((x.t)cx, (x.infectee)cy)], xl)),
    line(map(x -> [((x.t)cx - 0.3sty.bit, (x.infectee)cy-sty.bit), 
                   ((x.t)cx,          (x.infectee)cy), 
                   ((x.t)cx + 0.3sty.bit, (x.infectee)cy-sty.bit)], xl)), 
    stroke(csty(xl)), (activated ? sty.active : sty.dormant) )
end

function draw_incident(xl::Vector{T}; sty=style) where T<:epi.AbstractIncident 
end
function draw_realized(xl::Vector{T}; sty=style) where T<:epi.AbstractIncident
end
function draw_connect(xl::Vector{T}; activated=false, sty=style) where T<:epi.AbstractIncident 
end 

function draw_elements(env; I=I, P=P, R=R, C=C, sty=style) 
  (context(),
    draw_incident([inc for inc in env.infections if isa(inc, I)], sty=sty),
    draw_incident([inc for inc in env.infections if isa(inc, P)], sty=sty),
    draw_incident([inc for inc in env.removals   if isa(inc, R)], sty=sty),
    draw_incident([inc for inc in env.cremovals  if isa(inc, C)], sty=sty),
    draw_connect([inc for inc in  env.infections if isa(inc, I)], sty=sty),
    draw_connect([inc for inc in  env.infections if isa(inc, P)], sty=sty), )
end
    
function compose_nodes_view(duration, population, env; 
            coordinates=coordinates, I=I, P=P, R=R, C=C, sty=style)
  compose(context(units=coordinates), 
    draw_elements(env, I=I, P=P, R=R, C=C, sty=sty), 
    scaffolding(duration, population))
end 

function draw_active_elements(initial, active; I=I, P=P, R=R, C=C, sty=style)
  active_removals   = [inc for inc in active if (isa(inc, R) || isa(inc, C))]
  enumerated_removals = collect(enumerate(active_removals))

  (context(),
    draw_realized([inc for inc in active if isa(inc, I)]),
    draw_realized([inc for inc in active if isa(inc, P)]),
    draw_realized([inc for inc in active if isa(inc, C)]),
    draw_connect( [inc for inc in active if isa(inc, I)], activated=true),
    draw_connect( [inc for inc in active if isa(inc, P)], activated=true),
    (context(), # Could this be cleaned up?
    (context(),          # Connecting removal nodes
      circle([(inc.t)cx for (k, inc) in enumerated_removals], 
             [(k + initial.r)cy for (k, inc) in enumerated_removals],
             [sty.smradius]), stroke(csty(C[])), 
             sty.active, fill(csty(C[])), fillopacity(0.5) ),
    (context(),          # Connecting removal lines
      line([[((inc.t)cx, (inc.target)cy - sty.radius), 
             ((inc.t)cx, (k + initial.r)cy + sty.radius)]
        for (k, inc) in enumerated_removals]), 
      stroke(csty(R[])), sty.trail, strokedash([0.5mm, 0.5mm]) ) ) )
end

function draw_realized_regions(duration, population, flow; sty=style)
  removed_fill = [(a,b) for (a,b) in zip(flow.t, flow.Removals) if b>0]
  push!(removed_fill, (duration, 1))
  infected_fill = [(a,b) for (a,b) in zip(flow.t, flow.Infectives+flow.Removals) if b>0]
  removed1_fill = [(a,b + 1) for (a,b) in zip(flow.t, flow.Removals) if b < population]
  append!(infected_fill, reverse(removed1_fill))

  (context(),
    (context(),          # Trail of Removals
      line([(a,b) for (a,b) in zip(flow.t, flow.Removals) if b>0]),
      line([[(a,b), (duration, b)] for (a,b) in zip(flow.t, flow.Removals) if b>0]),
      stroke(csty(R[])), sty.boundary ),
    (context(),          # Removals trail fill
      polygon(removed_fill),
      fill(csty(R[])), fillopacity(0.1) ),
    
  (context(),          # Trail of Epidemic
    line([zip(flow.t, flow.Infectives+flow.Removals)]),
    line([[(a,b), (duration, b)] for (a,b) in zip(flow.t, flow.Infectives+flow.Removals) if b>0]),
    stroke(csty(A[])), sty.boundary ),
  (context(),          # Epidemic trail fill
    polygon(infected_fill),
    fill(csty(A[])), stroke(csty(A[])), fillopacity(0.1) ), )
end
    
function compose_epidemic_view(duration, population, env, flow, initial, active; coordinates)
  compose(context(units=coordinates),
          draw_active_elements(initial, active), draw_elements(env), 
          draw_realized_regions(duration, population, flow),
          scaffolding(duration, population))
end 


# Drawing functions (`Gadfly`)
function trajectory_table(duration, initial, traj)
  states = [initial]
  t = [state.t for state in traj] ; push!(t, duration)
  t = repeat(t, inner=2)[2:(end-1)]
  s = repeat([state.s for state in traj], inner=2)
  i = repeat([state.i for state in traj], inner=2)
  r = repeat([state.r for state in traj], inner=2)
  DataFrame(t=t, Susceptibles=s, Infectives=i, Removals=r)
end

function plot_trajectories(flow; sty=style)
  inf_layer = gf.layer(flow, x=:t, y=:Infectives, color=[csty(I[])], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:solid]))
  rem_layer = gf.layer(flow, x=:t, y=:Removals, color=[csty(R[])], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dash]))
  sus_layer = gf.layer(flow, x=:t, y=:Susceptibles, color=[sty.scaffold], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dot]))
  gf.plot(sus_layer, rem_layer, inf_layer,
    gf.style(panel_fill=colorant"bisque"), gf.Guide.xlabel("process time"), 
    gf.Guide.ylabel("removals, infectives, susceptibles", orientation=:vertical))
end
