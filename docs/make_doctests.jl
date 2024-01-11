using Documenter, EpidemicsCFTP


doctest(EpidemicsCFTP)

# Currently raises error
# ```julia
# UndefVarError: `iocapture` not defined
# ```
# which is odd, as `Documenter.makedocs` runs the doctests just fine!
