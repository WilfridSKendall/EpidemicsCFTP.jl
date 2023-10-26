using EpidemicsCFTP

using Documenter

using DocumenterLaTeX

makedocs(;
    modules=[EpidemicsCFTP],
    format=DocumenterLaTeX.LaTeX(platform="none"),
    authors="Wilfrid S Kendall <W.S.Kendall@warwick.ac.uk>",
#    repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
    sitename="EpidemicsCFTP",
    pages=[
        "Introduction"     => "01-intro.md",
        "Types"            => "02-types.md",
        "Methods"          => "03-methods.md",
        "Exceptions"       => "04-exceptions.md",
        "Display Methods"  => "05-methods-show.md",
        "Index"            => "06-index.md"
    ],
    )


# deploydocs(;
# #     repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
# )
