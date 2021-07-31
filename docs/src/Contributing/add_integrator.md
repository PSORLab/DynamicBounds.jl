# How to Add an Integrator

In order to add a custom integrator for a novel relaxation method, following the procedure outlined below. 

## 1. Define the integrator type (and possibly an abstract supertype)
An integrator structure is defined which holds all relevant information relating to problem inputs and relaxation outputs.
This structure should be a subtype of the integrator type assocaited with the appropriate relaxation problem (e.g. `<: INTEGRATOR_TYPE <: AbstractDERelaxIntegrator`).


```julia
mutable struct NewIntegrator <: INTEGRATOR_TYPE ... end
```

A constructor should also be defined which builds the integrator for each supported problem type (`PROBLEM_TYPE`). 

```julia
function NewIntegrator(prob::PROBLEM_TYPE) ... end
```

## 2. Define set!/support/get functions

At a minimum the following methods should be defined for each integrator in order to allow users to 
input and query information. Each integrator should define the following functions at a minimum:

```julia
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.Bound{Lower})
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.Bound{Upper})
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.IsNumeric)
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.IsSolutionSet)
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.TerminationStatus)
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.Value)
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.ParameterBound{Lower})
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.ParameterBound{Upper})
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.ParameterValue)
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.SupportSet)
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.ParameterNumber)
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.StateNumber)
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.SupportNumber)
DynamicBoundsBase.supports(td::NewIntegrator, t::DynamicBoundsBase.LocalSensitivityOn)
```

```julia
DynamicBoundsBase.set!(d::NewIntegrator, t::DynamicBoundsBase.ParameterBound{Lower}, x)
DynamicBoundsBase.set!(d::NewIntegrator, t::DynamicBoundsBase.ParameterBound{Upper}, x)
DynamicBoundsBase.set!(d::NewIntegrator, t::DynamicBoundsBase.ParameterValue, x)
DynamicBoundsBase.set!(d::NewIntegrator, t::DynamicBoundsBase.ConstantParameterValue, x)
DynamicBoundsBase.set!(d::NewIntegrator, t::DynamicBoundsBase.LocalSensitivityOn, x)
```

```julia
DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.ParameterNumber)
DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.SupportSet)
DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.ParameterBound{Lower})
DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.ParameterBound{Upper})

DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.Bound{Lower})
DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.Bound{Upper})
DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.Subgradient{Lower})
DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.Subgradient{Upper})

DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.Value)
DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.Gradient{Nominal})

DynamicBoundsBase.get(d::DifferentialInequality, t::DynamicBoundsBase.IsNumeric)
DynamicBoundsBase.get(d::DifferentialInequality, t::DynamicBoundsBase.IsSolutionSet)
DynamicBoundsBase.get(d::DifferentialInequality, t::DynamicBoundsBase.TerminationStatus)
```

Additionally, integrators that support computing relaxations in addition to normal bounds should implement the following methods:

```julia
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.Relaxation{Lower})
DynamicBoundsBase.supports(d::NewIntegrator, t::DynamicBoundsBase.Relaxation{Upper})
DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.Relaxation{Lower})
DynamicBoundsBase.get(d::NewIntegrator, t::DynamicBoundsBase.Relaxation{Upper})
```

## 3. Define a relaxation algorithm

A method, `relax!` should be defined to compute bounds/relaxation wherein information pertaining to the bounds/relaxations is stored to `d::NewIntegrator`.

```julia 
function relax!(d::NewIntegrator) end
```

## 4. (Optional) Define an integrator specific local integration scheme

This is primarily important when defining relaxation and boundsing methods for 
numerical solution of a differential system wherein truncuation error from mismatching relaxation and integration methods
is a concern. For integrators associated new problem types, it is encourage to include a `integrate!` method for the associated abstract type. 

```julia 
function integrate!(d::NewIntegrator) end
```
