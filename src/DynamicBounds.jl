module DynamicBounds

using DocStringExtensions

include("reexport_using.jl")

@reexport using DynamicBoundsBase: HasStateBounds, HasConstantStateBounds, HasVariableStateBounds,
       HasUserJacobian, ConstantStateBounds, VariableStateBounds,
       PolyhedralConstraint, AbstractDERelaxProblem, AbstractRelaxProblemAttribute,
       Nominal, Lower, Upper, Undefined, IntegratorName, Value, Gradient,
       Subgradient, Bound, Relaxation,IsNumeric, IsSolutionSet, TerminationStatus,
       ParameterValue, ParameterBound, SupportSet, TerminationStatusCode, relax!,
       integrate!, make, AbstractDERelaxIntegator, AbstractODERelaxIntegator,
       set!, setall!,getall!, make, supports,
       ODERelaxProb
@reexport using DynamicBoundspODEsIneq

import DynamicBoundsBase

export get
function get(integrator::DynamicBoundsBase.AbstractDERelaxIntegator, attr::DynamicBoundsBase.AbstractIntegatorAttribute, idxs::Vector)
    DynamicBoundsBase.get(integrator, attr, idxs)
end
function get(problem::DynamicBoundsBase.AbstractDERelaxProblem, attr::DynamicBoundsBase.AbstractRelaxProblemAttribute, idxs::Vector)
    DynamicBoundsBase.get(problem, attr, idxs)
end
function get(m::DynamicBoundsBase.AbstractDERelaxIntegator, attr::DynamicBoundsBase.AbstractIntegatorAttribute, args...)
    DynamicBoundsBase.get(m, attr, args...)
end
function get(m::DynamicBoundsBase.AbstractDERelaxProblem, attr::DynamicBoundsBase.AbstractRelaxProblemAttribute, args...)
    DynamicBoundsBase.get(m, attr, args...)
end
#=
using FunctionWrappers: FunctionWrapper
using OrdinaryDiffEq: OrdinaryDiffEqAlgorithm
using DifferentialEquations: solve, ImplicitEuler, Trapezoid, ABDF2

=#
##include("integrators/Wilhelm2019.jl")

end # module
