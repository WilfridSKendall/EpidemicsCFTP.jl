# This is what is needed for graphics to work!

# Specific `Gadfly` and 'Compose' imports, to avoid clashes.
import Compose: context, compose, line, text, fontsize, 
    hcenter, linewidth, stroke
import Gadfly: Coord, Geom, Guide, Scale, Theme, Plot,
    plot, layer, style, set_default_plot_size, pt, mm
# using PrettyTables

theme = create_theme(load_theme("../config/theme.yml"))

gadfly_theme = Theme(
    panel_fill=theme.blank,
    default_color=theme.default,
    background_color=theme.background,
    major_label_font="CMU Serif",   minor_label_font="CMU Serif",
    minor_label_color=theme.legend, major_label_color=theme.legend,
    major_label_font_size=8pt,     minor_label_font_size=6pt,
    grid_line_width=0mm,
)

set_default_plot_size(theme.figwidth, theme.figheight)

curves_template = plot(yintercept=1:initial.n,
    Geom.hline(style=:dash, size=0.1mm, color=theme.scaffold),
    Coord.cartesian(xmin=0, xmax=duration, ymin=0, ymax=initial.n + 0.25),
    Guide.xlabel("Process time", orientation=:horizontal),
    style(default_color=theme.background),
    gadfly_theme) ;

incidents_template = new_figure(curves_template,
    Scale.y_continuous(labels=(initial.n ≤ EpidemicsUtilities.MAXPOP ?
        i -> EpidemicsUtilities.timelinelabels_circled(i; n=initial.n) :
        i -> EpidemicsUtilities.timelinelabels_bracketed(i; n=initial.n))),
    Guide.yticks(ticks=collect(1:(initial.n))),
    Guide.ylabel("Time lines")) ;

push!(curves_template,
    Scale.y_continuous(labels=(i -> EpidemicsUtilities.timelinelabel_raw(i; n=initial.n))),
    Guide.ylabel("Numbers of individuals")) ;
