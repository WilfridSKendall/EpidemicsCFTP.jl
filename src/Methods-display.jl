# # Compact printing
# # -------------------------------
### Helper functions and format specifications for subscripts and superscripts
subs = split("₀₁₂₃₄₅₆₇₈₉._ ", "")
sups = split("⁰¹²³⁴⁵⁶⁷⁸⁹˙¯ ", "")
nums = split("0123456789.- ", "")
lows = Dict(nums[i]=>subs[i]  for i = 1:13)
upps = Dict(nums[i]=>sups[i]  for i = 1:13)

function lowers(x::String)::String
    join(lows[c] for c ∈ split(x, ""))
end

function uppers(x::String)::String
    join(upps[c] for c ∈ split(x, ""))
end

fspec = FormatSpec(".2f")

function timespec(t::Float64)::String
    lowers(fmt(fspec, t))
end

# # Actual display functions
# # -------------------------------
"""
    Base.show(io::IO, ::MIME"text/plain", z::AbstractRemoval)
    
Implementation of `show` for [`AbstractRemoval`](@ref), using `MIME("text/plain")` as the
middle of three arguments and employing subscripts and 2 decimal places for time `t`,
and superscript for the `target` field.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Removal(0.10, 3)
ℛ₀.₁₀³
julia> CRemoval(0.10, 3)
𝒞₀.₁₀³
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::AbstractRemoval)
    t = timespec(z.t)
    printfmt(io, "{1}{2}{3}", z.kind, t, uppers(string(z.target)))
end

"""
    Base.show(io::IO, z::AbstractRemoval)

This applies when used with `print`, being the string produced
buy `repr`, and can be used 
as input to produce a copy.
## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> print(Removal(0.10, 3))
Removal(0.1, 3)
julia> print(CRemoval(0.10, 3))
CRemoval(0.1, 3)
```
"""
function Base.show(io::IO, z::AbstractRemoval)
    t = timespec(z.t)
    print(io, "$(typeof(z))($(z.t), $(z.target))")
end

"""
    Base.show(io::IO, ::MIME"text/plain", z::AbstractInfection)
    
Implementation of `show` for [`AbstractInfection`](@ref), using `MIME("text/plain")` as the
middle of three arguments and employing subscripts and 2 decimal places for time `t`,
and superscripts for the `target` and `infectee` fields.
Note that a more general form (arising for example from use of `print`) can be used 
as input to produce a copy.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> Infection(0.10, 3, 4)
ℐ₀.₁₀³⁻⁴
julia> PInfection(0.10, 3, 4)
𝒫₀.₁₀³⁻⁴
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::AbstractInfection)
    t = timespec(z.t)
    printfmt(io, "{1}{2}{3}⁻{4}", z.kind, t, uppers(string(z.target)), uppers(string(z.infectee)))
end

"""
    show(io::IO, z::AbstractInfection)

This applies when used with `print`, being the string produced
buy `repr`, and can be used 
as input to produce a copy.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> print(Infection(0.10, 3, 4))
Infection(0.1, 3, 4)
julia> print(PInfection(0.10, 3, 4))
PInfection(0.1, 3, 4)
```
"""
function Base.show(io::IO, z::AbstractInfection)
    t = timespec(z.t)
    print(io, "$(typeof(z))($(z.t), $(z.target), $(z.infectee))")
end

"""
    Base.show(io::IO, ::MIME"text/plain", z::Innovation)
    
Implementation of `show` for [`Innovation`](@ref) as three rows of lists of incidents
-- or two rows if no [`CRemoval`](@ref)s. We illustrate this second version here.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> population = 3
3
julia> infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] 
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.1, 2), Removal(0.2, 3)] 
Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]

julia> Innovation(population, infections, removals, CRemoval[])
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³])
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::Innovation)
    println(io, "$(typeof(z))($(z.population),")
    println(io, rpad("infections:",12," "), sprint(show, MIME("text/plain"), z.infections))
    print(io, rpad("removals:",12," "), sprint(show, MIME("text/plain"), z.removals))
    isempty(z.cremovals) ? nothing : print(io, rpad("\ncremovals:",12," "),sprint(show, MIME("text/plain"), z.cremovals))
    print(io, ")\n")
end

"""
    Base.show(io::IO, z::Innovation)
    
## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> population = 3
3
julia> infections = [Infection(0.7,1,2), PInfection(0.5,1,2)] 
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.1, 2), Removal(0.2, 3)]
Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]

julia> print(Innovation(population, infections, removals, CRemoval[]))
Innovation(3,
  OperativeInfection[PInfection(0.5, 1, 2), Infection(0.7, 1, 2)],
  Removal[Removal(0.1, 2), Removal(0.2, 3)])
```
"""
function Base.show(io::IO, z::Innovation)
    if isempty(z.cremovals)
        printfmt(io, "{1}({2},\n  {3},\n  {4})",
                    typeof(z), z.population, z.infections, z.removals)
    else
        printfmt(io, "{1}({2},\n  {3},\n  {4},\n  {5})",
                    typeof(z), z.population, z.infections, z.removals, z.cremovals)
    end
end


"""
    Base.show(io::IO, ::MIME"text/plain", z::SIR)
    
Implementation of `show` for [`SIR`](@ref) using subscript and 2 decimal places for time.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> SIR(0.4, 1, 2, 3)
SIR₀.₄₀(1:2:3)
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::SIR)
    printfmt(io, "SIR{1}({2}:{3}:{4})", timespec(z.t), z.s, z.i, z.r)
end


"""
    Base.show(io::IO, ::MIME"text/plain", z::AbstractEvolution)
    
Implementation of `show` for [`AbstractEvolution`](@ref) as three rows of lists of incidents
-- or two rows if no [`CRemoval`](@ref)s -- together with further calculations. 
We illustrate both these versions here.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> initial    = SIR(0.0, 2,1,0)
SIR₀.₀₀(2:1:0)
julia> population = initial.n
3
julia> infections = [Infection(0.7,1,2), PInfection(0.5,1,2)]
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
julia> removals   = [Removal(0.1, 2), Removal(0.2, 3)]
Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
julia> cremovals = [CRemoval(0.6, 2)]
CRemoval[𝒞₀.₆₀²]
julia> innovation = Innovation(population, infections, removals, CRemoval[])
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³])

julia> Evolution(initial, innovation) 
Evolution(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
chronology: AbstractIncident[ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₅₀(1:2:0)]
history:    AbstractIncident[𝒫₀.₅₀¹⁻²])

julia> innovation = Innovation(population, infections, removals, cremovals)
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₆₀²])

julia> Evolution(initial, innovation)
Evolution(3,
infections: OperativeInfection[𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₆₀²]
chronology: AbstractIncident[ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹⁻²,𝒞₀.₆₀²,ℐ₀.₇₀¹⁻²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₅₀(1:2:0),SIR₀.₆₀(1:1:1)]
history:    AbstractIncident[𝒫₀.₅₀¹⁻²,𝒞₀.₆₀²]) 
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::AbstractEvolution) 
    println(io, "$(typeof(z))($(z.population),")
    println(io, rpad("infections:",12," "), sprint(show, MIME("text/plain"), z.infections))
    println(io, rpad("removals:",12," "), sprint(show, MIME("text/plain"), z.removals))
    isempty(z.cremovals) ? nothing : println(io, rpad("cremovals:",12," "), sprint(show, MIME("text/plain"), z.cremovals))
    println(io, rpad("chronology:",12," "), sprint(show, MIME("text/plain"), z.chronology))
    println(io, rpad("trajectory:",12," "), sprint(show, MIME("text/plain"), z.trajectory))
    print(io, rpad("history:",12," "), sprint(show, MIME("text/plain"), z.history))
    println(io, ")")
end

"""
    show(::IO, ::MIME"text/plain", ::Vector{T}; ::Int, ::String) where T <: AbstractTimedOccurrence

Implementation of `show` for vector of [`AbstractTimedOccurrence`](@ref)
incidents with line-breaking.

## Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> infections = repeat([Infection(0.7,1,2), PInfection(0.5,1,2)], 6)
OperativeInfection[ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²,
    𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²,ℐ₀.₇₀¹⁻²,𝒫₀.₅₀¹⁻²]
```
"""
function Base.show(io::IO, ::MIME"text/plain", xv::Vector{T}; width::Int=75, tab::String=' '^4) where T <: AbstractTimedOccurrence
    if isempty(xv)
        print(io, "$(string(T))[]")
    else
        parts = [sprint(show, MIME("text/plain"), a) for a ∈ xv]
        parts[1] = "$(string(T))[" * parts[1]
        parts[end] = parts[end]*"]"
        broken = []
        cumulative, clength, initial = [], 0, true
        for bit ∈ parts
            clength = clength + length(bit)
            if clength > width
                addition = join(cumulative, ',') * ','
                push!(broken, initial ? addition : tab * addition)
                cumulative, clength, initial = [bit], length(bit), false
            else
                push!(cumulative, bit)
            end
        end
        if ! isempty(cumulative)
            addition = join(cumulative, ',')
            push!(broken, initial ? addition :  tab * addition)
        end
        print(io, join(broken, '\n'))
        #for section ∈ broken
        #    print(io, section)
        #end
    end
end

"""
    Base.show(io::IO, e::BadIncident)
    
Printing a `BadIncident` exception.
Sub-types of this exception are:
[`EmployedRemoval`](@ref) and [`MissedCRemoval`](@ref), raised respectively when a 
conditioned evolution uses a [`Removal`](@ref) which _is_ _not_ conditioned to appear in the trajectory,
or doesn't use a [`CRemoval`](@ref) which _is_ conditioned to appear in the trajectory.
See these types for doctests.
"""
function Base.show(io::IO, e::BadIncident)
    print(io, "[$(typeof(e))] The (conditioned) evolution misused $(e.incident)")
end
