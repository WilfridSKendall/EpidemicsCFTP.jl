using Documenter, DocumenterLaTeX, EpidemicsCFTP

makedocs(;
#    modules=[EpidemicsCFTP],
    authors="Wilfrid S Kendall <W.S.Kendall@warwick.ac.uk>",
    repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
    sitename="EpidemicsCFTP",
##
    format=DocumenterLaTeX.LaTeX(platform="none"),
##
#     pages=[
#         "Introduction"            => "index.md",
#         "Types"                   => "02-types.md",
#         "Methods for computation" => "03-methods.md",
#         "Methods for display"     => "04-methods-show.md",
#         "Exceptions"              => "05-exceptions.md",
#         "Index"                   => "06-index.md",
#     ],
    pages=[
        "index.md",
        "02-types.md",
        "03-methods.md",
        "04-methods-show.md",
        "05-exceptions.md",
        "06-index.md",
    ],
)



# deploydocs(;
# #     repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
# )
