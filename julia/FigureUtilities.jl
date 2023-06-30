# ---
# title:  "FigureUtilities module"
# author: "Wilfrid Kendall"
# ---
# 
# ---
# date-format: "D MMMM YYYY"
# papersize:  a4
# 
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
# # Module supplying utilities for perfect epidemics simulation.
module FigureUtilities

# ## ·Exports
# A composite type made up of basic incidents.
export BasicIncident

# A convenient drawing function to create `PG` and `PDF` variants of the figure.
export depict

# A set of functions to draw the axes _et cetera_. 
export time_axis, time_threads, scaffolding

# A set of functions to draw nodes and regions and connectors.

export draw_incident, draw_realized, draw_connect

export draw_elements, compose_nodes_view, draw_active_elements

export draw_realized_regions, compose_epidemic_view

# Export `Gadfly` drawing functions

export trajectory_table, plot_trajectories

# Now include the source!
include("FigureUtilitiesSource.jl")

end
