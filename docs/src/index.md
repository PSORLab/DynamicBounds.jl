# **DynamicBounds.jl**

## Authors
- [Matthew Wilhelm](https://psor.uconn.edu/person/matthew-wilhelm/), Department of Chemical and Biomolecular Engineering,  University of Connecticut (UCONN)

## Overview
**DynamicBounds.jl** is a package for computing relaxations and interval bounds of parametric state solutions of ordinary differential equations in the Julia language. By employing an interface to DifferentialEquations.jl, this package allows for the construction of well-posed mathematical problems in which the relaxations of parametric differential equations can be computed. Further, this allows for the association of such problems with a particular integration scheme for the evaluation of solution trajectories at user-specified parameter values. The use of a simple extensible API allows for the association of additional information with particular problem type, such as the incorporation of nonlinear and affine invariants. Moreover, this facilitates higher-order algorithms (e.g., global dynamic optimization) by allowing information to be queried in a standard manner from computed state bounds and relaxations.

## Installing DynamicBounds.jl
DynamicBounds.jl is registered Julia package. It can be installed using the Julia package manager.
From the Julia REPL, type ] to enter the Pkg REPL mode and run the following command

```julia
pkg> add DynamicBounds
```

## Subpackages:
- **DynamicBoundsBase.jl**: The backend package which provides an abstraction layer define attributes for problem types, integrators, and the handling of access functions (set!/get/setall!/getall!).
- **DynamicBoundspODEsIneq.jl**: An implementation of the continuous-time differential inequality algorithms for constructing interval state bounds and state relaxations of parametric ordinary differential equation systems (pODEs).
- **DynamicBoundspODEsDiscrete.jl**: An implementation of various discrete-time algorithms (Hermite-Obreschkoff, Lohner's Method, e.g.) for constructing interval state bounds and state relaxations of parametric ordinary differential equation systems (pODEs)

## Citing DynamicBounds.jl

A paper about the DynamicBounds.jl software package is currently under preparation. In the
meantime, please feel free to cite the conference presentation below:

```
@misc{Wilhelm2020,
  author = {Wilhelm, M.E.},
  title = {DynamicBounds.jl},
  year = {2020},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {https://github.com/PSORLab/DynamicBounds.jl}
}
```
