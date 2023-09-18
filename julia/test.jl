
using DataFrames, Gadfly, Compose

# To note:
# 1:
# Guide.annotation(ctx::Compose.Context)
# Overlay a plot with an arbitrary Compose graphic. The context will inherit the plot's coordinate system, unless overridden with a custom unit box.
# 2:
# Colors listed at http://juliagraphics.github.io/Colors.jl/stable/namedcolors/
#
my_theme = Theme(
     panel_fill=colorant"white",
     default_color=colorant"blue",
     background_color=colorant"white",
     major_label_font="CMU Serif", minor_label_font="CMU Serif", minor_label_color=colorant"black",
     major_label_font_size=16pt, minor_label_font_size=14pt, major_label_color=colorant"black",
     grid_line_width=0mm
)

population = 4
duration = 7.0
ϵ = 1e-7

set_default_plot_size(6inch, 2*(3.25inch)) # (because we will place one figure above the other!)

circlabels = [string(Char(0x00002460 + i - 1)) for i in 1:population]
timelinelabels = i -> circlabels[i]

df1 = DataFrame(t=0:duration, s=[4, 4, 4, 3, 2, 2, 2, 2], i=[1, 1, 1, 2, 3, 2, 1, 1], r=[0, 0, 0, 0, 0, 1, 2, 2])

df1[:, :infect] = df1.r + df1.i
df1[:, :population] .= population

# Plot epidemic dividing boundaries
timelines = layer(df1, yintercept=1:population, Geom.hline(style=:dot, size=0.25mm),
     style(default_color=colorant"grey"))
ll1 = layer(df1, x=:t, y=:population, Geom.step,
     style(line_width=1mm, default_color=colorant"green"))
ll2 = layer(df1, x=:t, y=:infect, Geom.step,
     style(line_width=1mm, default_color=colorant"orange"))
ll3 = layer(df1[df1.r.!=0, :], x=:t, y=:r, Geom.step,
     style(line_width=1mm, default_color=colorant"brown"))
fig1 = plot(ll1, ll2, ll3, timelines,
     Coord.cartesian(xmin=0, xmax=duration, ymin=0, ymax=population + 1),
     Coord.cartesian(xmin=0, xmax=duration),
     Guide.ylabel("Time lines"),
     Guide.xlabel("Process time", orientation=:horizontal),
     Scale.y_discrete(labels=timelinelabels, levels=0:population),
     my_theme)

# Create a lag and blend with original dataset
df1lag = deepcopy(df1)
df1lag.t = circshift(df1.t, (-1)) .- ϵ
df1lag.t[end] = df1lag.t[end-1]
df2 = sort!(append!(df1, df1lag))

# Plot infected region
ll4 = layer(df2, x=:t, ymin=:r, ymax=:infect, Geom.ribbon,
     alpha=[0.6], style(default_color=colorant"yellow"))
ll5 = layer(df2, x=:t, ymin=[0], ymax=:r, Geom.ribbon,
     alpha=[0.6], style(default_color=colorant"bisque"))
fig2 = plot(ll1, ll2, ll3, ll4, ll5, timelines,
     Coord.cartesian(xmin=0, xmax=duration, ymin=0, ymax=population + 1),
     Guide.xlabel("Process time", orientation=:horizontal),
     Guide.ylabel("Time lines", orientation=:vertical),
     Scale.y_discrete(labels=timelinelabels, levels=0:population), my_theme)

# Display both figures
vstack(fig1, fig2)
