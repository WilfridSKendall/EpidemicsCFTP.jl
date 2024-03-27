# Methods for display

## Methods for displaying incidents
These definitions overload `Base.show`. Versions without `MIME"text/plain"`
have
only two arguments, and are "vanilla" versions which will be applied for 
example when echo-ing the respective instance to the terminal.
```@docs
Base.show(::IO, ::MIME"text/plain", ::AbstractRemoval)
Base.show(::IO, ::AbstractRemoval)

Base.show(::IO, ::MIME"text/plain", ::AbstractInfection)
Base.show(::IO, ::AbstractInfection)

Base.show(::IO, ::MIME"text/plain", ::Vector{<:AbstractTimedOccurrence})
```

## Methods for displaying states, innovations, and evolutions
```@docs
Base.show(::IO, ::MIME"text/plain", ::SIR)

Base.show(::IO, ::MIME"text/plain", ::AbstractInnovation)
Base.show(::IO, ::AbstractInnovation)

Base.show(::IO, ::MIME"text/plain", ::AbstractEvolution)
```
