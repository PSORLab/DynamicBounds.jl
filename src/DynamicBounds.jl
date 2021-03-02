# Copyright (c) 2020: Matthew Wilhelm & Matthew Stuber.
# This work is licensed under the Creative Commons Attribution-NonCommercial-
# ShareAlike 4.0 International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative
# Commons, PO Box 1866, Mountain View, CA 94042, USA.
#############################################################################
# DynamicBounds.jl
# A package for compute bounds and relaxations of the solutions of
# parametric differential equations.
# See https://github.com/PSORLab/DynamicBoundsBase.jl
#############################################################################
# src/DynamicBounds.jl
# Main module code.
#############################################################################

module DynamicBounds

using DocStringExtensions

include("reexport_using.jl")

@reexport using DynamicBoundsBase: HasStateBounds, HasConstantStateBounds, HasVariableStateBounds,
       HasUserJacobian, ConstantStateBounds, VariableStateBounds,
       PolyhedralConstraint, AbstractDERelaxProblem, AbstractRelaxProblemAttribute,
       Nominal, Lower, Upper, Undefined, IntegratorName, Value, Gradient,
       Subgradient, Bound, Relaxation,IsNumeric, IsSolutionSet, TerminationStatus,
       ParameterValue, ParameterBound, SupportSet, TerminationStatusCode, relax!,
       integrate!, AbstractDERelaxIntegrator, AbstractODERelaxIntegrator,
       set!, setall!,getall!, supports, ODERelaxProb

@reexport using DynamicBoundspODEsIneq: DifferentialInequality, DifferentialInequalityCond,
                                        DifferentialInequalityAffect, DifferentialInequalityAffectNeg,
                                        DifferentialInequalityf

import DynamicBoundsBase
const DBB = DynamicBoundsBase

export get
function DBB.get(integrator::DBB.AbstractDERelaxIntegrator, attr::DBB.AbstractIntegratorAttribute, idxs::Vector)
    DBB.get(integrator, attr, idxs)
end
function DBB.get(problem::DBB.AbstractDERelaxProblem, attr::DBB.AbstractRelaxProblemAttribute, idxs::Vector)
    DBB.get(problem, attr, idxs)
end
function DBB.get(m::DBB.AbstractDERelaxIntegrator, attr::DBB.AbstractIntegratorAttribute, args...)
    DBB.get(m, attr, args...)
end
function DBB.get(m::DBB.AbstractDERelaxProblem, attr::DBB.AbstractRelaxProblemAttribute, args...)
    DBB.get(m, attr, args...)
end

end
