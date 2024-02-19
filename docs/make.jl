using Documenter, EpidemicsCFTP
DocMeta.setdocmeta!(EpidemicsCFTP, :DocTestSetup, :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations); recursive=true)
makedocs(;
    modules=[EpidemicsCFTP],
    authors="Wilfrid S Kendall <W.S.Kendall@warwick.ac.uk>",
    sitename="EpidemicsCFTP.jl",
##
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="github.com/WilfridSKendall/EpidemicsCFTP.jl",
        assets=String[],
    ),
##
    pages=[
        "Introduction"            => "index.md",
        "Types"                   => "01-Types.md",
        "Methods for computation" => "02-Methods.md",
        "Methods for display"     => "03-Methods-show.md",
        "Exceptions"              => "04-Exceptions.md",
        "Index"                   => "05-index.md",
    ],
)



#=
deploydocs(;
    repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
)=#
        
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



# Raised odd error
# ```julia
# UndefVarError: `iocapture` not defined
# ```
# (Note that `Documenter.makedocs` ran the doctests just fine!)
#
# Fixed by `]add Documenter` within `julia` in this environment.
# See passing remark in https://stackoverflow.com/questions/50763456/julia-can-i-run-doctests-without-makedocs.
