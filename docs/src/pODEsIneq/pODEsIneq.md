# **DynamicBoundspODEsIneq.jl**: Continuous-time relaxations/bounds of nonlinear parameteric differential equations


## Storage for the local problem solution
```@docs
LocalProblemStorage{PRB, N}
```

## Callback functions used in constructing the continuous time differential inequalities.

```@docs
DifferentialInequalityCond
DifferentialInequalityAffect
DifferentialInequalityAffectNeg
DifferentialInequalityf{Z, F}
DifferentialInequalityf(f!, Z, nx, np, P, relax, subgrad, polyhedral_constraint, Xapriori)
```

## Integrator used for constructing continuous time differential inequality bounds/relaxations.
```@docs
DifferentialInequality
DifferentialInequality(d::ODERelaxProb; kwargs...)
```
