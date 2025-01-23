using Documenter, DocumenterCitations, EpidemicsCFTP
import Random: AbstractRNG, SamplerTrivial # Is this necessary?!
import Distributions
import Distributions: Categorical


DocMeta.setdocmeta!(EpidemicsCFTP, :DocTestSetup, :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations); recursive=true)



bib = CitationBibliography(
    joinpath(@__DIR__, "src", "refs.bib");
    style=:authoryear
)



makedocs(;
    modules=[EpidemicsCFTP],
    authors="Wilfrid S Kendall <W.S.Kendall@warwick.ac.uk>",
    sitename="EpidemicsCFTP",

    format=Documenter.LaTeX(platform="none"),

    pages=[
        "index.md",
        "01-Types.md",
        "02-Methods.md",
        "03-Methods-show.md",
        "04-Exceptions.md",
        "05-index.md",
    ],
    plugins=[bib],
)



# deploydocs(;
# #     repo="github.com/WilfridSKendall/EpidemicsCFTP.jl",
# )
