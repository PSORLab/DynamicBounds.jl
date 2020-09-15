# **DynamicBoundspODEsDiscrete.jl**: Discerete-time relaxations/bounds of nonlinear parametric differential equations


## Integrator used for constructing continuous time differential inequality bounds/relaxations.
```@docs
DiscretizeRelax
```

## Options for discretize-and-relaxation style calculations
```@docs
LohnerContractor
HermiteObreschkoff
```

## Utilities

### Computation of Taylor Functions and Jacobians
```@docs
jetcoeffs!
TaylorFunctor!
JacTaylorFunctor!
jacobian_taylor_coeffs!
set_JxJp!
LohnersFunctor
```

### Storage and Access functions for Preconditioners
```@docs
qr_stack(nx::Int, steps::Int)
QRDenseStorage
QRDenseStorage(nx::Int)
calculateQ!
calculateQinv!
reinitialize!::Tuple{DataStructures.CircularBuffer{QRDenseStorage}}
mul_split!
```

### Existence and Uniqueness Test Utility Functions
```@docs
improvement_condition
contains
excess_error
ExistStorage{F,K,S,T}
```

### Utilities for overall discretize-and-relaxation scheme
```@docs
StepParams
StepResult{S}
ContractorStorage{S}
single_step!
affine_contract!
set_xX!
set_P!
compute_X0!
set_Δ!
```
