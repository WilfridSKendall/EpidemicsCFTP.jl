# Needs to work in environment to which `Literate` is added
using Literate
Literate.markdown("FigureUtilitiesSource.jl",flavor = Literate.CommonMarkFlavor(),codefence="```{julia}" => "```")
mv("FigureUtilitiesSource.md","FigureUtilities.qmd", force=true)

# Not yet perfect!
# Doesn't include directives #| in codeblocks
