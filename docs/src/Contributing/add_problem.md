# How to Add a Problem Type

## 1. Define the problem type (and possibly an abstract supertype)
Each problem type should be an subtype of the `AbstractDERelaxProblem` or an
abstract subtype of `AbstractDERelaxProblem`. At a minimum the following,
attributes should be supported by each problem type.

```julia
DynamicBoundsBase.StateNumber
DynamicBoundsBase.ParameterNumber
DynamicBoundsBase.SupportNumber
DynamicBoundsBase.ConstantParameterValue
```

## 2. Define set!/get functions

Additional set!/get functions should be added to support any optional information pertinent to the problem type.

## 3. Define a default local integrator algorithm.
It's recommended that a general `integrate!` function should be defined for
each problem type. This eliminates the need to associate an local integration
algorithm with each algorithm used to compute relaxations and bounds of
systems of differential equations.
