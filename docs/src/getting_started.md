# Getting Started

The including integrators used by constructing a relaxation problem.
Then by adding attributes to the relaxation problem and building
the integrator from the relaxation problem. The integrator may then
be modified by using the base API. Lastly, the relax!/integrate!
are called to compute information about the trajectories and this
information is retrieved using API functions.

## Setting up a relaxation problem

We begin by constructing a relaxation problem. Currently, the
`ODERelaxProb` is used for all parametric ODEs but specialized
variants of this will become available in the future. This
manner of relaxation problem is specified using the right-hand
side function `f!` (evaluated in place) along with a function
of `p` defining the initial conditions. A time span and box
constraints on `p` are also expected.

```julia
using DynamicBounds

function f!(dx, x, p, t)
    dx[1] = -p[1]*x[1]*x[2] + p[2]*x[3] + p[6]*x[6]
    dx[2] = -p[1]*x[1]*x[2] + p[2]*x[3] + p[3]*x[3]
    dx[3] =  p[1]*x[1]*x[2] - p[2]*x[3] - p[3]*x[3]
    dx[4] =  p[3]*x[3] - p[4]*x[4]*x[5] + p[5]*x[6]
    dx[5] = -p[4]*x[4]*x[5] + p[5]*x[6] + p[6]*x[6]
    dx[6] =  p[4]*x[4]*x[5] - p[5]*x[6] - p[6]*x[6]
    return
end
x0(p) = [34.0, 20.0, 0.0, 0.0, 16.0, 0.0]

tspan = (0.0, 18.0e-5*250)
pL = [0.1; 0.033; 16.0; 5.0; 0.5; 0.3]
pU = 10.0*pL

ode_prob = ODERelaxProb(f!, x0, tspan, pL, pU)
```

We can often further refine bounds/relaxation on the state variables
by making use of invariants and apriori bounds/relaxations. We'll
add a polyhedral invariant and apriori bounds state bounds.

```julia
M = [0.0 -1.0 -1.0  0.0  0.0  0.0;
     0.0  0.0  0.0  0.0 -1.0 -1.0;
     1.0 -1.0  0.0  1.0 -1.0  0.0]
b = [-20.0; -16.0; -2.0]
polyhedral_invariant = PolyhedralConstraint(M, :==, b)
set!(ode_prob, polyhedral_invariant)

u_lo = zeros(6)
u_hi = [34.0; 20.0; 20.0; 34.0; 16.0; 16.0]
set!(prob, ConstantBounds(u_lo, u_hi))
```

We now can specify the points at which we want to retrieve information
about state variables by adding a `QueriedSupport` attribute to the problem

```julia
set!(prob, QueriedSupport(range(tspan[1], tspan[2], length = 50)))
```

## Creating an integrator from the problem
The integrator is built from the relaxation problem along with keyword variables.

```julia
integrator = DifferentialInequality(ode_prob, calculate_relax = true,
                                              calculate_subgradient = false)
```

Provided that we're interested in computing relaxations as well as constant
bounds (w.r.t `p`) we'll need to specify parameter values within the box constraints.

```julia
setall!(integrator, ParameterValue(), p)
```

Relaxation problems also support the `ParameterValue` attributes. However, it's often
preferable to set the value in the integrator to avoid rebuilding the integrator each
time.

## Computing relaxations and trajectories

We now compute the relevant information about the state variables
and the solution of the pODEs.

```julia
relax!(integrator)      # compute relaxations
integrate!(integrator)  # compute trajectories
```

## Querying the integrator/problem for information

We can now query functions using the `get` API function.

```julia
val = get(integrator, Value(3))
lo = get(integrator, Bound{Lower}(3))
hi = get(integrator, Bound{Upper}(3))
cv = get(integrator, Relaxation{Lower}(3))
cc = get(integrator, Relaxation{Upper}(3))
```

## Use the sample problem library

```julia
DE_keys = keys(LibRelaxODE.STANDARD_LIBRARY)
for i = 1:length(keys)
    prob = LibRelaxODE.STANDARD_LIBRARY(DE_keys[i])
    integrator = DifferentialInequality(prob)
    relax!(integrator)
end
```
