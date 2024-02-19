# Exceptions
## Generic exception for `BadIncident`
Here is the generic exception used 
to flag bad incidents in the course of the
perfect simulation code.

```@docs
BadIncident
```

### Particular cases of `BadIncident`
Here are exceptions for some specific cases.
```@docs
MissedCRemoval
EmployedRemoval
```

## Generic exception for `BadLFE`
```@docs
BadLFE
```
### Particular cases of `BadLFE`
Here are exceptions for some specific cases.
```@docs
EmptyLFE
NonMinimalLFE
```


## Generic exception for `BadNFZ3`
```@docs
BadNFZ3
```
### Particular case of `BadNFZ2`
Here is an exception for a specific case.
```@docs
ExpungedInfectionGivesValidTrajectory
```

## Methods for displaying exceptions
```@docs
Base.show(::IO, ::BadIncident)
Base.show(::IO, ::MissedCRemoval)
Base.show(::IO, ::EmployedRemoval)
Base.show(::IO, ::BadLFE)
Base.show(::IO, ::BadNFZ3)
```
