using Test, EpidemicsCFTP, Documenter
DocMeta.setdocmeta!(EpidemicsCFTP, :DocTestSetup, :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations); recursive=true)
doctest(EpidemicsCFTP)

