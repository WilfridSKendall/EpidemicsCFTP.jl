# Methods for display

## Methods for displaying incidents
These definitions overload `Base.show`. Versions without `MIME"text/plain"`
are not listed here. These have
only two arguments, and are "vanilla" versions which will be applied for 
example when echo-ing the respective instance to the terminal.
```@docs
Base.show(::IO, ::MIME"text/plain", ::AbstractRemoval)
Base.show(io::IO, z::AbstractRemoval)

Base.show(::IO, ::MIME"text/plain", ::AbstractInfection)
Base.show(io::IO, z::AbstractInfection)

show(::IO, ::MIME"text/plain", ::Vector{<:AbstractTimedOccurrence}; ::Int, ::String)
```

## Methods for displaying states, innovations, and evolutions
```@docs
Base.show(::IO, ::MIME"text/plain", ::SIR)

Base.show(::IO, ::MIME"text/plain", ::AbstractInnovation)
Base.show(io::IO, z::AbstractInnovation)

Base.show(::IO, ::MIME"text/plain", ::AbstractEvolution)
```
