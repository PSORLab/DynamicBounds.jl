# **DynamicBoundsBase.jl**: An extensible abstraction layer for DynamicBounds

A

## **Current supported problem types and constructors:**

```@docs
AbstractDERelaxProblem
ODERelaxProb{F,JX,JP,xType,K}
ODERelaxProb(f, tspan, x0, pL, pU; kwargs...)
```

## Problem attributes

```@docs
AbstractRelaxProblemAttribute
HasStateBounds
HasConstantStateBounds
HasVariableStateBounds
HasUserJacobian
AbstractPathConstraint
ConstantStateBounds
VariableStateBounds
PolyhedralConstraint
```

## Abstract Integrator Types
```@docs
AbstractDERelaxIntegrator
AbstractODERelaxIntegrator
```

Bound locations for use with attributes such as Relaxation, Bound, Gradient. For `Gradient{T<:AbstractBoundLoc}`, `T = Lower` indicates the gradient of the lower relaxation (that is the convex relaxation) should be returned, `T = Upper` indicates that the upper relaxation (the concave relaxation) should be returned, `T = Nominal` indicates that the gradient of the local evaluation of the relaxation should be returned at the present parameter value.

```@docs
AbstractBoundLoc
Lower
Upper
Nominal
Undefined
```

## Integrator attributes

```@docs
AbstractIntegratorAttribute
AbstractDynamicIndex
TimeIndex
IntegratorName
IsNumeric
IsSolutionSet
TerminationStatus
Value
SupportSet{T<:AbstractFloat}
ParameterValue
ParameterBound{T<:AbstractBoundLoc}
Bound{T<:AbstractBoundLoc}
Relaxation{T<:AbstractBoundLoc}
Gradient{T<:AbstractBoundLoc}
Subgradient{T<:AbstractBoundLoc}
```

The following constructors for integrator attributes are given below where `T<:AbstractBoundLoc`

```@docs
Gradient{T}(i::TimeIndex)
Gradient{T}(x::Float64)
Subgradient{T}(i::TimeIndex)
Subgradient{T}(x::Float64)
Bound{T}(i::TimeIndex)
Bound{T}(x::Float64)
Relaxation{T}(i::TimeIndex)
Relaxation{T}(x::Float64)
```

## Access and Interface Functions:
```@docs
supports
get
getall
getall!
set!
setall!
relax!
integrate!
```


## General utilities:

```@docs
  IntegratorStates
  UnsupportedError
  NotAllowedError
  UnsupportedRelaxAttribute{AttrType<:AnyDEAttribute}
  SetRelaxAttributeNotAllowed{AttrType<:AnyDEAttribute}
```
