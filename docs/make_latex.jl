using EpidemicsCFTP

using Documenter

using DocumenterLaTeX

makedocs(;
    modules=[EpidemicsCFTP],
    format=DocumenterLaTeX.LaTeX(platform="none"),
    authors="Wilfrid S Kendall <W.S.Kendall@warwick.ac.uk>",
    sitename="EpidemicsCFTP",
    pages=[
        "Home" => "index.md",
    ],
    )


# deploydocs(;
# #     repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
# )
