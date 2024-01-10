# Methods for display
These definitions overload `Base.show`. Versions without `MIME"text/plain"`
are not listed here. These have
only two arguments, and are "vanilla" versions which will be applied for 
example when echo-ing the respective instance to the terminal.
```@docs
Base.show(::IO, ::MIME"text/plain", ::AbstractRemoval)
Base.show(io::IO, z::AbstractRemoval)
Base.show(::IO, ::MIME"text/plain", ::AbstractInfection)
Base.show(io::IO, z::AbstractInfection)
Base.show(::IO, ::MIME"text/plain", ::Innovation)
Base.show(io::IO, z::Innovation)

Base.show(::IO, ::MIME"text/plain", ::SIR)
Base.show(::IO, ::MIME"text/plain", ::AbstractEvolution)

Base.show(io::IO, ::MIME"text/plain", ::Vector{T}; Int, ::String) where T <: AbstractTimedOccurrence

Base.show(io::IO, e::BadIncident)
```
