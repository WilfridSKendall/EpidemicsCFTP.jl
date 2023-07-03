# ---
# title:  "FigureUtilities module"
# author: "Wilfrid Kendall"
# date:   today
# ---
# 
# ---
# date-format: "D MMMM YYYY"
# papersize:  a4
# 
# execute:
#   eval: false
# format:
#   html:
#     toc: true
#     toc-depth: 2
#     code-fold: true
#     self-contained: true
#   pdf:
#     link-citations: true
#     numbersections: true
#     mainfont: "Times New Roman"
#     monofont: "JuliaMono"
#     monofontoptions:
#        - Scale=0.7
# jupyter:    julia-1.9
# ---
#
# 
# \newcommand{\SIR}{\operatorname{S-I-R}}
#
# # Exports
# We begin with a module declaration (terminated at end of this file!),
# and then list exports.
module FigureUtilities

# ## Constructed types
# Here is a composite type made up of basic incidents.
export BasicIncident

# ## Default style
# A default style for all figures (other than those generated using `Gadfly`).
export defaultstyle

# ## Producing various renditions of a drawing
# A convenient drawing function to create `PNG` and `PDF` variants of a figure.
export depict

# ## Various drawing functions
# A set of functions to draw the axes _et cetera_. 
export time_axis, time_threads, scaffolding

# A set of functions to draw nodes and regions and connectors.
export draw_incident, draw_realized, draw_connect

export draw_elements, compose_nodes_view, draw_active_elements

export draw_realized_regions, compose_epidemic_view

# ## Functions using `Gadfly`
# Specific `Gadfly` drawing functions
export trajectory_table, plot_trajectories

# # Imports
# This module requires import of a number of other modules as follows. 
# Note that we introduce a prefix for `Gadfly`, to avoid excessive name-space pollution.
using Colors, Compose, DataFrames, Measures
import Cairo, Fontconfig, Gadfly
gf = Gadfly ; 

# The next module is required in order to access the `subtypes` function.
using InteractiveUtils 

# Finally the `EpidemicsCFTP` is a module currently under development.
using EpidemicsCFTP 

# # Constructions and definitions
# ## Creation of union of composite `AbstractIncident` type.
# The composite type `BasicIncident` is computed when the module is imported / used.
function unionize_composites(a::Type)::Type
  coll = subtypes(a)
  xl = Type[x for x in coll]
  if length(xl) == 0
    return a # return a composite type
  else
    xl = Type[unionize_composites(y) for y in xl]
    return reduce((t1, t2) -> Union{t1, t2}, xl) # return a union type
  end
end

BasicIncident = unionize_composites(AbstractIncident) ;



# ## Colours related to various incidents, using function `csty`.
# Various incidents and markers will be used sufficiently often to justify abbreviations.
# These abbreviations (or an appropriate subset) are often repeated on scripts.
A = AbstractInfection
R = Removal   ; C = CRemoval   
I = Infection ; P = PInfection
IR = InitialRemoved    ; II = InitialInfected    ; IS = InitialSusceptible
CR = ContinuingRemoved ; CI = ContinuingInfected ; CS = ContinuingSusceptible
MIA = MarkerInfectionA ; MRA = MarkerRemovalA
MIB = MarkerInfectionB ; MRB = MarkerRemovalB

# They are associated to colours as part of a general style. 
# (Note the use of the style hierarchy here.)
# See <https://juliagraphics.github.io/Colors.jl/stable/namedcolors/> for a useful and extensive list of colours.
function csty(x::Vector{R}) colorant"tan"       end 
function csty(x::Vector{C}) colorant"purple"    end 
function csty(x::Vector{I}) colorant"orange"    end 
function csty(x::Vector{P}) colorant"darkgreen" end 

function csty(x::Vector{T}) where T<:AbstractInfection         colorant"yellow" end 
function csty(x::Vector{T}) where T<:AbstractInfectionMarker   colorant"orange" end
function csty(x::Vector{T}) where T<:AbstractRemovalMarker     colorant"tan"    end
function csty(x::Vector{T}) where T<:AbstractSusceptibleMarker colorant"blue"   end 
function csty(x::Vector{T}) where T<:AbstractIncident                           end ;
  

# ## Default drawing styles forming a structure `defaultstyle`.
# This default style structyre is frequently used by
# the `FigureUtilities` functions defined below,
# using a keyword argument `sty`.
defaultstyle = (
  radius   =  0.2cy,              smradius =  0.9 * 0.2cy,
  bit      = -0.02h,              tic      = -0.2cy,
  xlab     =  0cx-0.4inch,        yloc     = 0.25inch,
  height   =  0.0cy,              
  boundary =  linewidth(1.00mm),  trail    =  linewidth(0.75mm),
  active   =  linewidth(0.75mm),  dormant  =  linewidth(0.25mm),
  blank    =  colorant"white",    scaffold =  colorant"grey",
  region   =  (context(), rectangle(), fill(colorant"bisque"), fillopacity(0.3)),
  colour   =  csty,
) ;

# Creation of union of composite `AbstractIncident` types.
# This computation is carried out within the module when it is called.

function unionize_composites(a::Type)::Type
  coll = subtypes(a)
  xl = Type[x for x in coll]
  if length(xl) == 0
    return a # return a composite type
  else
    xl = Type[unionize_composites(y) for y in xl]
    return reduce((t1, t2) -> Union{t1, t2}, xl) # return a union type
  end
end 

BasicIncident = unionize_composites(AbstractIncident) ;

# ## Graphics utility
# The following short utility function is helpful.
# It displays a `Compose` figure
# and also creates corresponding PNG and PDF renderings in directory `image`.
function depict(title, coordinates, compose_list...)
  composition = compose(context(units=coordinates), compose_list...)
  draw(PNG("image/$title.png"), composition)
  draw(PDF("image/$title.pdf"),  composition)
  composition
end ;

    
# ## Basic image template elements
# We define a function to draw the time axis, with tick marks at integer times.
# Note, both here and following, the careful use of graphics area units (`cx`, `cy`).
function time_axis(duration; sty=defaultstyle)
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
end ;

# Now we define a function to draw all time-lines as threads labelled by circled integers.
#
# ::: {.callout-caution}
# The definition of `circlabels` below needs to be changed if `population > MAXPOP=20`,
# as unicode then runs out of circled integers!
# (Figure out how to use 
# one of the many ideas in 
# <https://tex.stackexchange.com/questions/7032/good-way-to-make-textcircled-numbers>.)
# :::
function time_threads(duration, population; sty=defaultstyle)
  circlabels   = [string(Char(0x00002460+i-1)) for i in 1:population]

  (context(), # Returned value of function!
    (context(), text([sty.xlab], [(k)cy for k in 1:population], circlabels,
      [hleft], [vcenter]), fontsize(10pt), font("TimesRoman"), ),
    (context(), line([[(0cx, (k)cy), ((duration)cx, (k)cy)] for k in 1:population]), 
      stroke(sty.scaffold), linewidth(0.5mm), ), )
end ;

# A third function constructs scaffolding (axes, time lines _etc_).
function scaffolding(duration, population; sty=defaultstyle)
  (context(), sty.region, time_axis(duration, sty=sty), 
              time_threads(duration, population, sty=sty))
end ;

# ## Drawing functions (`Compose`)
# Here are functions to draw inactive (respectively, active) nodes for each of a list
# conposed of incidents from some prescribed composite sub-types of `BasicIncident`, while doing nothing 
# for all other `AbstractIncident[]` vectors.
function draw_incident(xl::Vector{T}; sty=defaultstyle) where T<:BasicIncident
  if length(xl) > 0
    (context(),
      (context(),
        text(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), 
             map(x -> string(x), xl), [hcenter], [vcenter]), 
        fontsize(5pt), font("Helvetica")),
      (context(),
        circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [sty.radius]), 
        fill(sty.blank), stroke(sty.colour(xl))), )
  end
end

function draw_realized(xl::Vector{T}; sty=defaultstyle) where T<:BasicIncident
  (context(),
    (context(),
    circle(map(x -> (x.t)cx, xl), map(x -> (x.target)cy, xl), [sty.radius]), 
    sty.active, fill(sty.colour(xl)), fillopacity(0.2), stroke(sty.colour(xl)) ),
    if eltype(xl)<:AbstractInfection
      (context(),
      circle(map(x->(x.t)cx, xl), map(x -> x.infectee, xl), [sty.smradius]),
       sty.active, fill(sty.colour(xl)), fillopacity(0.5), stroke(sty.colour(xl)))
    end, )
end 

function draw_connect(xl::Vector{T}; activated=false, sty=defaultstyle) where T<:BasicIncident
  if ! (eltype(xl)<:AbstractInfection)
    return
  end
  (context(), 
    line(map(x -> [((x.t)cx, (x.target)cy+sty.radius), ((x.t)cx, (x.infectee)cy)], xl)),
    line(map(x -> [((x.t)cx - 0.3sty.bit, (x.infectee)cy-sty.bit), 
                   ((x.t)cx,          (x.infectee)cy), 
                   ((x.t)cx + 0.3sty.bit, (x.infectee)cy-sty.bit)], xl)), 
    stroke(sty.colour(xl)), (activated ? sty.active : sty.dormant) )
end

function draw_incident(xl::Vector{T}; sty=defaultstyle) where T<:AbstractIncident 
end
function draw_realized(xl::Vector{T}; sty=defaultstyle) where T<:AbstractIncident
end
function draw_connect(xl::Vector{T}; activated=false, sty=defaultstyle) where T<:AbstractIncident 
end 

# The next function draws the various incidents.
function draw_elements(env; I=I, P=P, R=R, C=C, sty=defaultstyle) 
  (context(),
    draw_incident([inc for inc in env.infections if isa(inc, I)], sty=sty),
    draw_incident([inc for inc in env.infections if isa(inc, P)], sty=sty),
    draw_incident([inc for inc in env.removals   if isa(inc, R)], sty=sty),
    draw_incident([inc for inc in env.cremovals  if isa(inc, C)], sty=sty),
    draw_connect([inc for inc in  env.infections if isa(inc, I)], sty=sty),
    draw_connect([inc for inc in  env.infections if isa(inc, P)], sty=sty), )
end

# The next function combines depiction of the incidents with the axes.
function compose_nodes_view(duration, population, env; 
                               coordinates, I=I, P=P, R=R, C=C, sty=defaultstyle)
  compose(context(units=coordinates), 
    draw_elements(env, I=I, P=P, R=R, C=C, sty=sty), 
    scaffolding(duration, population))
end 

# The next function draws the realized elements together with connectors.
function draw_active_elements(initial, active; 
            I=I, P=P, R=R, C=C, sty=defaultstyle)
  active_removals   = [inc for inc in active if (isa(inc, R) || isa(inc, C))]
  enumerated_removals = collect(enumerate(active_removals))

  (context(),
    draw_realized([inc for inc in active if isa(inc, I)], sty=sty),
    draw_realized([inc for inc in active if isa(inc, P)], sty=sty),
    draw_realized([inc for inc in active if isa(inc, C)], sty=sty),
    draw_connect( [inc for inc in active if isa(inc, I)], activated=true, sty=sty),
    draw_connect( [inc for inc in active if isa(inc, P)], activated=true, sty=sty),
    (context(), # Could this be cleaned up?
    (context(),          # Connecting removal nodes
      circle([(inc.t)cx for (k, inc) in enumerated_removals], 
             [(k + initial.r)cy for (k, inc) in enumerated_removals],
             [sty.smradius]), stroke(sty.colour(C[])), 
             sty.active, fill(sty.colour(C[])), fillopacity(0.5) ),
    (context(),          # Connecting removal lines
      line([[((inc.t)cx, (inc.target)cy - sty.radius), 
             ((inc.t)cx, (k + initial.r)cy + sty.radius)]
        for (k, inc) in enumerated_removals]), 
      stroke(sty.colour(R[])), sty.trail, strokedash([0.5mm, 0.5mm]) ) ) )
end

# Here is a function which draws infected and removed regions. 
#
# :::{.callout-warning}
# This function should now be superseded by work carried out in `experiment.qmd`.
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

# Finally, here is a function which presents incidents, realized incidents,
# connectors and regions on a single figure.
function compose_epidemic_view(duration, population, env, flow, initial, active; 
                                  coordinates, sty=defaultstyle)
  compose(context(units=coordinates),
          draw_active_elements(initial, active, sty=sty), 
          draw_elements(env, sty=sty), 
          draw_realized_regions(duration, population, flow, sty=sty),
          scaffolding(duration, population))
end ;


# ## Drawing functions (`Gadfly`)
# Define functions to construct and plot a dataframe
# of trajectories as knots of piecewise constant functions, using `evolution_recurse!`
# to deliver the \(\SIR\) trajectory `traj`,
# and realized incidents in `active`.
function trajectory_table(duration, initial, traj)
  states = [initial]
  t = [state.t for state in traj] ; push!(t, duration)
  t = repeat(t, inner=2)[2:(end-1)]
  s = repeat([state.s for state in traj], inner=2)
  i = repeat([state.i for state in traj], inner=2)
  r = repeat([state.r for state in traj], inner=2)
  DataFrame(t=t, Susceptibles=s, Infectives=i, Removals=r)
end

function plot_trajectories(flow; sty=defaultstyle)
  inf_layer = gf.layer(flow, x=:t, y=:Infectives, color=[sty.colour(I[])], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:solid]))
  rem_layer = gf.layer(flow, x=:t, y=:Removals, color=[sty.colour(R[])], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dash]))
  sus_layer = gf.layer(flow, x=:t, y=:Susceptibles, color=[sty.scaffold], 
    gf.Geom.line, gf.style(line_width=1mm, line_style=[:dot]))
  gf.plot(sus_layer, rem_layer, inf_layer,
    gf.style(panel_fill=colorant"bisque"), gf.Guide.xlabel("process time"), 
    gf.Guide.ylabel("removals, infectives, susceptibles", orientation=:vertical))
end ;


# # Conclusion of module
# The following terminates the material forming the module `FigureUtilities`.
end
