# # Compact printing
# # -------------------------------
# Format specifications.

fspec0  = FormatSpec(".2f")
fexpr3  = FormatExpr("{1}{2}{3}")
# fexpr4a = FormatExpr("{1}{2}{3}⁻{4}") # OLD
fexpr4a = FormatExpr("{1}{2}{3}ᑉ{4}")
fexpr4b = FormatExpr("{1}({2},\n  {3},\n  {4})")
fexpr4c = FormatExpr("SIR{1}({2}:{3}:{4})")
fexpr5  = FormatExpr("{1}({2},\n  {3},\n  {4},\n  {5})")

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

function timespec(t::Float64)::String
    if t == -Inf
        "[-∞]"
    elseif t == Inf
        "[∞]"
    else
        lowers(pyfmt(fspec0, t))
    end
end

# # Actual display functions
# # -------------------------------
"""
Implements `show` for [`AbstractRemoval`](@ref), using `MIME("text/plain")` as the
middle of three arguments and employing subscripts and 2 decimal places for time `t`,
and superscript for the `target` field.

### Example
```jldoctest
julia> R(0.10, 3)
ℛ₀.₁₀³
julia> C(0.10, 3)
𝒞₀.₁₀³
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::AbstractRemoval)
    t = timespec(z.t)
    printfmt(io, fexpr3, z.kind, t, uppers(string(z.target)))
end

"""
Applies when used with `print`, being the string produced
buy `repr`, and can be used 
as input to produce a copy.
### Example
```jldoctest
julia> print(R(0.10, 3))
Removal(0.1, 3)
julia> print(C(0.10, 3))
CRemoval(0.1, 3)
```
"""
function Base.show(io::IO, z::AbstractRemoval)
    t = timespec(z.t)
    print(io, "$(typeof(z))($(z.t), $(z.target))")
end

"""
Implementation of `show` for [`AbstractInfection`](@ref), using `MIME("text/plain")` as the
middle of three arguments and employing subscripts and 2 decimal places for time `t`,
and superscripts for the `target` and `infectee` fields.
Note that a more general form (arising for example from use of `print`) can be used 
as input to produce a copy.

### Example
```jldoctest
julia> I(0.10, 3, 4)
ℐ₀.₁₀³ᑉ⁴
julia> P(0.10, 3, 4)
𝒫₀.₁₀³ᑉ⁴
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::AbstractInfection)
    t = timespec(z.t)
    printfmt(io, fexpr4a, z.kind, t, uppers(string(z.target)), uppers(string(z.infectee)))
end

"""
This applies when used with `print`, being the string produced
buy `repr`, and can be used 
as input to produce a copy.

### Example
```jldoctest
julia> print(I(0.10, 3, 4))
Infection(0.1, 3, 4)
julia> print(P(0.10, 3, 4))
PInfection(0.1, 3, 4)
```
"""
function Base.show(io::IO, z::AbstractInfection)
    t = timespec(z.t)
    print(io, "$(typeof(z))($(z.t), $(z.target), $(z.infectee))")
end

"""
Implements `show` for [`AbstractInnovation`](@ref) as three rows of lists of incidents
-- or two rows if no [`CRemoval`](@ref)s. We illustrate this second version here.

### Example
```jldoctest
julia> population = 3
3
julia> infections = [I(0.7,1,2), P(0.5,1,2)] 
OperativeInfection[ℐ₀.₇₀¹ᑉ²,𝒫₀.₅₀¹ᑉ²]
julia> removals   = [R(0.1, 2), R(0.2, 3)] 
Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]

julia> Innovation(population, infections, removals, C[])
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³])
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::AbstractInnovation)
    println(io, "$(typeof(z))($(z.population),")
    println(io, rpad("infections:",12," "), sprint(show, MIME("text/plain"), z.infections))
    print(io,   rpad("removals:",12," "), sprint(show, MIME("text/plain"), z.removals))
    isempty(z.cremovals) ? nothing : print(io, rpad("\ncremovals:",12," "),sprint(show, MIME("text/plain"), z.cremovals))
    print(io, ")")
end

"""
### Example
```jldoctest
julia> population = 3
3
julia> infections = [I(0.7,1,2), P(0.5,1,2)] 
OperativeInfection[ℐ₀.₇₀¹ᑉ²,𝒫₀.₅₀¹ᑉ²]
julia> removals   = [R(0.1, 2), R(0.2, 3)]
Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]

julia> print(Innovation(population, infections, removals, C[]))
Innovation(3,
  OperativeInfection[PInfection(0.5, 1, 2), Infection(0.7, 1, 2)],
  Removal[Removal(0.1, 2), Removal(0.2, 3)])
```
"""
function Base.show(io::IO, z::AbstractInnovation)
    if isempty(z.cremovals)
        printfmt(io, fexpr4b,
                    typeof(z), z.population, z.infections, z.removals)
    else
        printfmt(io, fexpr5,
                    typeof(z), z.population, z.infections, z.removals, z.cremovals)
    end
end


"""
Implements `show` for [`SIR`](@ref) using subscript and 2 decimal places for time.

### Example
```jldoctest; setup = :(using EpidemicsCFTP)
julia> SIR(0.4, 1, 2, 3)
SIR₀.₄₀(1:2:3)
julia> SIR(-Inf, 1, 2, 3)
SIR[-∞](1:2:3)
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::SIR)
    printfmt(io, fexpr4c, timespec(z.t), z.s, z.i, z.r)
end


"""   
Implements `show` for [`AbstractEvolution`](@ref) as three rows of lists of incidents
-- or two rows if no [`CRemoval`](@ref)s -- together with further calculations. 
We illustrate both these versions here.

### Example
```jldoctest
julia> initial    = SIR(0.0, 2,1,0)
SIR₀.₀₀(2:1:0)
julia> population = initial.n
3
julia> infections = [I(0.7,1,2), P(0.5,1,2)]
OperativeInfection[ℐ₀.₇₀¹ᑉ²,𝒫₀.₅₀¹ᑉ²]
julia> removals   = [R(0.1, 2), R(0.2, 3)]
Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
julia> cremovals = [C(0.6, 2)]
CRemoval[𝒞₀.₆₀²]
julia> innovation = Innovation(population, infections, removals, C[])
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³])

julia> Evolution(initial, innovation) 
Evolution(SIR₀.₀₀(2:1:0),
infections: OperativeInfection[𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
chronology: AbstractIncident[ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₅₀(1:2:0)]
history:    AbstractIncident[𝒫₀.₅₀¹ᑉ²])

julia> innovation = Innovation(population, infections, removals, cremovals)
Innovation(3,
infections: OperativeInfection[𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₆₀²])

julia> Evolution(initial, innovation)
Evolution(SIR₀.₀₀(2:1:0),
infections: OperativeInfection[𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²]
removals:   Removal[ℛ₀.₁₀²,ℛ₀.₂₀³]
cremovals:  CRemoval[𝒞₀.₆₀²]
chronology: AbstractIncident[ℛ₀.₁₀²,ℛ₀.₂₀³,𝒫₀.₅₀¹ᑉ²,𝒞₀.₆₀²,ℐ₀.₇₀¹ᑉ²]
trajectory: SIR[SIR₀.₀₀(2:1:0),SIR₀.₅₀(1:2:0),SIR₀.₆₀(1:1:1)]
history:    AbstractIncident[𝒫₀.₅₀¹ᑉ²,𝒞₀.₆₀²]) 
```
"""
function Base.show(io::IO, ::MIME"text/plain", z::AbstractEvolution) 
    println(io, "$(typeof(z))(", sprint(show, MIME("text/plain"), z.initial), ",")
    println(io, rpad("infections:",12," "), sprint(show, MIME("text/plain"), z.infections))
    println(io, rpad("removals:",12," "), sprint(show, MIME("text/plain"), z.removals))
    isempty(z.cremovals) ? nothing : println(io, rpad("cremovals:",12," "), sprint(show, MIME("text/plain"), z.cremovals))
    println(io, rpad("chronology:",12," "), sprint(show, MIME("text/plain"), z.chronology))
    println(io, rpad("trajectory:",12," "), sprint(show, MIME("text/plain"), z.trajectory))
    print(io,   rpad("history:",12," "), sprint(show, MIME("text/plain"), z.history))
    print(io,   ")")
end

"""
Implements `show` for vector of [`AbstractTimedOccurrence`](@ref)
incidents with line-breaking.

### Example
```jldoctest
julia> infections = repeat([I(0.7,1,2), P(0.5,1,2)], 6)
OperativeInfection[ℐ₀.₇₀¹ᑉ²,𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²,𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²,𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²,
    𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²,𝒫₀.₅₀¹ᑉ²,ℐ₀.₇₀¹ᑉ²,𝒫₀.₅₀¹ᑉ²]
```
"""
function Base.show(io::IO, ::MIME"text/plain", xv::Vector{<:AbstractTimedOccurrence}; 
                    width::Int=75, tab::String=' '^4)
    T = eltype(xv)
    if isempty(xv)
        print(io, "$T[]")
    else
        parts = [sprint(show, MIME("text/plain"), a) for a ∈ xv]
        parts[1] = "$T[" * parts[1]
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
    end
end
