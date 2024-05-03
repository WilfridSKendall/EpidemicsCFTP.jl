using Test, EpidemicsCFTP, Documenter
DocMeta.setdocmeta!(EpidemicsCFTP, :DocTestSetup, :(using EpidemicsCFTP, EpidemicsCFTP.abbreviations, Distributions); recursive=true)
doctest(EpidemicsCFTP)

