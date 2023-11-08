using EpidemicsCFTP

using Documenter

using DocumenterMarkdown

makedocs(;
    modules=[EpidemicsCFTP],
    authors="Wilfrid S Kendall <W.S.Kendall@warwick.ac.uk>",
#    repo="https://github.com/WilfridSKendall/EpidemicsCFTP.jl",
    sitename="EpidemicsCFTP.jl",
#     format=Documenter.HTML(;
#         prettyurls=get(ENV, "CI", "false") == "true",
#         canonical="github.com/WilfridSKendall/EpidemicsCFTP.jl",
#         assets=String[],
    format=Markdown(),
    pages=[
        "Start"            => "index.md",
        "Introduction"     => "01-intro.md",
        "Types"            => "02-types.md",
        "Methods"          => [
            "Methods for computation" => "03-methods.md",
            "Methods for display"     => "04-methods-show.md"
                ],
        "Exceptions"       => "05-exceptions.md",
        "Index"            => "06-index.md"
    ],
)

deploydocs(;
    repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
)
        
# deploydocs(;
#     repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
# #     julia  = "1.9",
# #     osname = "linus"
# )

# deploydocs(:
#     repo   = "github.com/WilfridSKendall/EpidemicsCFTP.jl", 
#     deps   = Deps.pip("mkdocs", "pygments", "python-markdown-math"),   
#     make   = () -> run(`mkdocs build`)   
#     target = "site" 
# )
