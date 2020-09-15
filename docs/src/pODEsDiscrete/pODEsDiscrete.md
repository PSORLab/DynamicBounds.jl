# **DynamicBoundspODEsDiscrete.jl**: Discrete-time relaxations/bounds of nonlinear parametric differential equations

This package contains a number of algorithms that computes relaxations via a series
of sequential steps. The main integrator exported is the `DiscretizeRelax` integrator.
This computes bounds or relaxations (and (sub)gradients thereof) using a two-step routine: 1) a first step determining a step-size such that the solution of the pODEs is proven to
exist over the entire step [tj-1, tj] and 2) a secondary contractor method which refines the bounds/relaxations at time tj. This integrator is initialize in the standard fashion. See the next two sections for keyword arguments and valid state contractors.

## Integrator used for constructing continuous time differential inequality bounds/relaxations.
```@docs
DiscretizeRelax
```

## Contractor options for discretize-and-relaxation style calculations
```@docs
AbstractStateContractorName
LohnerContractor{K}
HermiteObreschkoff
```

### Computation of Taylor Functions and Jacobians
```@docs
jetcoeffs!
TaylorFunctor!
JacTaylorFunctor!
jacobian_taylor_coeffs!
set_JxJp!
LohnersFunctor
HermiteObreschkoffFunctor
```

### Storage and Access functions for Preconditioners
```@docs
qr_stack(nx::Int, steps::Int)
QRDenseStorage
QRDenseStorage(nx::Int)
calculateQ!
calculateQinv!
mul_split!
```

### Existence and Uniqueness Test Utility Functions
```@docs
improvement_condition
contains
excess_error
calc_alpha
ExistStorage{F,K,S,T}
state_contractor_k
state_contractor_γ
state_contractor_steps
```

### Utilities for overall discretize-and-relaxation scheme
```@docs
StepParams
StepResult{S}
ContractorStorage{S}
single_step!
set_xX!
set_P!(d::DiscretizeRelax)
compute_X0!(d::DiscretizeRelax)
set_Δ!
```
