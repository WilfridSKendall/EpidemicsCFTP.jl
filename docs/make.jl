using EpidemicsCFTP

using Documenter

using DocumenterMarkdown

makedocs(;
    modules=[EpidemicsCFTP],
    authors="Wilfrid Kendall <W.S.Kendall@warwick.ac.uk> and contributors",
    repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
    sitename="EpidemicsCFTP.jl",
#     format=Documenter.HTML(;
#         prettyurls=get(ENV, "CI", "false") == "true",
#         canonical="github.com/WilfridSKendall/EpidemicsCFTP.jl",
#         assets=String[],
    format=Markdown(),
    pages=[
        "Home" => "index.md",
    ],
)

# deploydocs(;
#     repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
# #     julia  = "1.5",
# #     osname = "linus"
# )

# deploydocs(:
#     repo   = "github.com/WilfridSKendall/EpidemicsCFTP.jl", 
#     deps   = Deps.pip("mkdocs", "pygments", "python-markdown-math"),   
#     make   = () -> run(`mkdocs build`)   
#     target = "site" 
# )
