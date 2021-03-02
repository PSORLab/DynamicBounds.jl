# How to Add a Problem Type

## 1. Define the problem type (and possibly an abstract supertype)
Each problem type should be an subtype of the `AbstractDERelaxProblem` or an
abstract subtype of `AbstractDERelaxProblem`. At a minimum the following,
attributes should be supported by each problem type.

## 2. Define set!/get functions

## 3. Define a default local integrator algorithm.
It's recommended that a general `integrate!` function should be
