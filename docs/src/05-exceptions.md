# Exceptions
## Generic exception
Here is the generic exception used 
to flag bad incidents in the course of the
perfect simulation code.

```@docs
BadIncident
```

Here are exceptions for some specific cases.
```@docs
MissedCRemoval
EmployedRemoval
```



## Methods for displaying exceptions
```@docs
Base.show(io::IO, e::BadIncident)
```
