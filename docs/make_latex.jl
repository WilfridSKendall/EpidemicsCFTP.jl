using Documenter, DocumenterLaTeX, EpidemicsCFTP

makedocs(;
    modules=[EpidemicsCFTP],
    authors="Wilfrid S Kendall <W.S.Kendall@warwick.ac.uk>",
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
        "01-types.md",
        "02-methods.md",
        "03-methods-show.md",
        "04-exceptions.md",
        "05-index.md",
    ],
)



# deploydocs(;
# #     repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
# )
