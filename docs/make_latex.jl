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
#         "Types"                   => "02-Types.md",
#         "Methods for computation" => "03-Methods.md",
#         "Methods for display"     => "04-Methods-show.md",
#         "Exceptions"              => "05-Exceptions.md",
#         "Index"                   => "06-index.md",
#     ],
    pages=[
        "index.md",
        "01-Types.md",
        "02-Methods.md",
        "03-Methods-show.md",
        "04-Exceptions.md",
        "05-index.md",
    ],
)



# deploydocs(;
# #     repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
# )
