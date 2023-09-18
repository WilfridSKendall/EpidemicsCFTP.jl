using EpidemicsCFTP, EpidemicsUtilities, Gadfly, DataFrames

# To note:
# 1:
# Guide.annotation(ctx::Compose.Context)
# Overlay a plot with an arbitrary Compose graphic. The context will inherit the plot's coordinate system, unless overridden with a custom unit box.
# 2:
# Colors listed at http://juliagraphics.github.io/Colors.jl/stable/namedcolors/
#

# const?
const population = 5
const duration = 3.0
const ϵ = 1e-7

theme = create_theme(load_theme("config/theme.yml")) ;

circlabels = [string(Char(0x00002460 + i - 1)) for i in 1:population]
timelinelabels = i -> i > 0 ? circlabels[i] : ""

my_theme = Theme(
     panel_fill=theme.blank,
     default_color=theme.default,
     background_color=theme.background,
     major_label_font="CMU Serif", minor_label_font="CMU Serif", minor_label_color=colorant"black",
     major_label_font_size=16pt, minor_label_font_size=14pt, major_label_color=colorant"black",
     grid_line_width=0mm
)

set_default_plot_size(6inch, 3*(3.25inch))


A = AbstractInfection ; R = Removal ; C = CRemoval ; I = Infection ; P = PInfection ;

innov = Innovation(5, 
  A[I(0.11,2,3), I(0.2,2,5), P(0.4,1,2), I(0.5,2,5), I(0.6,2,4), I(0.85,3,4), 
    I(0.9,2,3), I(1.0,2,5), P(1.1,2,3), I(1.05,4,5), I(1.2,2,4), I(1.6,3,5), 
    I(1.5,3,4)], 
  R[R(0.3,5), R(0.42,3), R(0.7,3), R(0.55,3), R(0.95,5), R(1.4,2), R(1.55,1),
    R(1.85,2)],
  C[C(1.3,2), C(0.8,1), C(1.7,4), C(1.8,4), C(1.92,5)] ) 

initial = SIR(0.0, 4, 1, 0)
ev = Evolution(initial, innov)

# Modified table_trajectories that does not repeat!
function table_trajectories1(duration, initial, trajectory)
     t = [state.t for state in trajectory]
     s = [state.s for state in trajectory]
     i = [state.i for state in trajectory]
     r = [state.r for state in trajectory]
     final = trajectory[end]
     push!(t, duration)
     push!(s, s[end])
     push!(i, i[end])
     push!(r, r[end])
     DataFrame(t=t, Susceptibles=s, Infectives=i, Removals=r)
   end

   
flow = table_trajectories1(duration, initial, ev.trajectory) ;
flow[:, :Population] .= population
flow[:, :Empty] .= 0

# First draw epidemic curve together with removals and susceptibles trajectories.

timelines = layer(flow, yintercept=1:population, 
     Geom.hline(style=:dot, size=0.25mm),
     style(default_color=theme.scaffold))
ll0 = layer(flow, x=:t, y=:Empty, Geom.line,
     style(line_width=0.75mm, default_color=theme.scaffold))
ll1 = layer(flow, x=:t, y=:Infectives, Geom.step,
     style(line_width=0.75mm, default_color=theme.colour(I(0.0, 1, 2))))
ll2 = layer(flow, x=:t, y=:Removals, Geom.step,
     style(line_style=[:dashdot], line_width=1mm, default_color=theme.colour(R(0.0,1))))
ll3 = layer(flow[flow.Susceptibles.!=0, :], x=:t, y=:Susceptibles, Geom.step,
     style(line_style=[:dash], line_width=1mm, default_color=theme.scaffold))
fig1 = plot(ll0, ll3, ll2, ll1, timelines,
     Coord.cartesian(xmin=0, xmax=duration, ymin=0, ymax=population + 1),
     Coord.cartesian(xmin=0, xmax=duration),
     Guide.ylabel("Time lines"),
     Guide.xlabel("Process time", orientation=:horizontal),
     Scale.y_discrete(labels=timelinelabels, levels=0:population),
     my_theme)


# Now plot regions
flow[:, :Epidemic] = flow.Removals + flow.Infectives
ll4 = layer(flow, x=:t, y=:Epidemic, Geom.step,
     style(line_width=0.75mm, default_color=theme.colour(I(0.0, 1, 2))))
ll5 = layer(flow, x=:t, y=:Population, Geom.line,
     style(line_width=0.75mm, default_color=theme.scaffold))
fig2 = plot(ll4, ll2, ll5, ll0, timelines,
     Coord.cartesian(xmin=0, xmax=duration, ymin=0, ymax=population + 1),
     Coord.cartesian(xmin=0, xmax=duration),
     Guide.ylabel("Time lines"),
     Guide.xlabel("Process time", orientation=:horizontal),
     Scale.y_discrete(labels=timelinelabels, levels=0:population),
     my_theme)


# Create a lag and blend with original dataset
flowlag = deepcopy(flow)
flowlag.t = circshift(flow.t, (-1)) .- ϵ
flowlag.t[end] = flowlag.t[end-1]
flow2 = sort!(append!(flow, flowlag))

# Now plot regions
ll6 = layer(flow, x=:t, ymin=:Removals, ymax=:Epidemic, Geom.ribbon,
     alpha=[0.3], style(default_color=theme.colour(I(0.0, 1, 2))))
ll7 = layer(flow, x=:t, ymin=:Empty, ymax=:Removals, Geom.ribbon,
     alpha=[0.6], style(default_color=theme.colour(R(0.0, 1))))

fig3 = plot(ll6, ll7, ll4, ll2, ll5, ll0, timelines,
     Coord.cartesian(xmin=0, xmax=duration, ymin=0, ymax=population + 1),
     Coord.cartesian(xmin=0, xmax=duration),
     Guide.ylabel("Time lines"),
     Guide.xlabel("Process time", orientation=:horizontal),
     Scale.y_discrete(labels=timelinelabels, levels=0:population),
     my_theme)

vstack(fig1, fig2, fig3)