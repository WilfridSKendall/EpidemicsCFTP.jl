# Needs to work in environment to which `Literate` is added
using Literate
Literate.markdown("FigureUtilities.jl",flavor = Literate.CommonMarkFlavor(),codefence="```{julia}" => "```")
mv("FigureUtilities.md","FigureUtilities.qmd", force=true)

# Not yet perfect!
# Doesn't include directives #| in codeblocks
