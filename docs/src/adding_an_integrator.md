# How to Add an Integrator

## 1. Define the integrator type (and possibly an abstract supertype)


## 2. Define set!/get functions

Each integrator should define the following functions at a minimum:

set!(m::NewIntegrator, )
set!(m::NewIntegrator, )
set!(m::NewIntegrator, )

## 3. Define a relaxation algorithm

## 4. (Optional) Define an integrator specific local integration scheme

This is primarily important when defining relaxations and bounds of a
numerical solution of a differential system...
