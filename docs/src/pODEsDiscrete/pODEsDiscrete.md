# **DynamicBoundspODEsDiscrete.jl**: Discerete-time relaxations/bounds of nonlinear parametric differential equations


## Integrator used for constructing continuous time differential inequality bounds/relaxations.
```@docs
DiscretizeRelax
```

## Options for discretize-and-relaxation style calculations
```@docs
AbstractStateContractorName
LohnerContractor{K}
HermiteObreschkoff
```

## Utilities

### Computation of Taylor Functions and Jacobians
```@docs
jetcoeffs!
TaylorFunctor!
μ!(out,xⱼ,x̂ⱼ,η)
ρ!(out,p,p̂ⱼ,η)
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
