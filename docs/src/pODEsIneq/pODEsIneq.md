# **DynamicBoundspODEsIneq.jl**: Continuous-time relaxations/bounds of nonlinear parametric differential equations



## Storage for the local problem solution
```@docs
LocalProblemStorage
```

## Callback functions used in constructing the continuous time differential inequalities.

```@docs
DifferentialInequalityCond
DifferentialInequalityAffect
DifferentialInequalityAffectNeg
DifferentialInequalityf{Z, F}
```

## Integrator used for constructing continuous time differential inequality bounds/relaxations.
```@docs
DifferentialInequality
```
