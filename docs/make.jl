push!(LOAD_PATH,"../src/")

using Documenter, DynamicBounds, DynamicBoundsBase, DynamicBoundspODEsIneq, DynamicBoundspODEsDiscrete

import DynamicBoundsBase: AbstractPathConstraint, Bound, Relaxation, Gradient, Subgradient, get,
                          ODERelaxProb, getall, UnsupportedError, NotAllowedError, UnsupportedRelaxAttribute,
                          SetRelaxAttributeNotAllowed, AbstractODERelaxProblem

import DynamicBoundspODEsIneq: LocalProblemStorage, DifferentialInequalityCond, DifferentialInequalityAffect,
                               DifferentialInequalityAffectNeg, DifferentialInequalityf, DifferentialInequality

import DynamicBoundspODEsDiscrete: jetcoeffs!, TaylorFunctor!, JacTaylorFunctor!, jacobian_taylor_coeffs!,
                                   set_JxJp!, LohnersFunctor, HermiteObreschkoffFunctor, QRDenseStorage,
                                   calculateQ!, calculateQinv!, μ!, ρ!, AbstractStateContractorName,
                                   reinitialize, qr_stack, StepParams, StepResult, ExistStorage,
                                   ContractorStorage, reinitialize!, existence_uniqueness!, improvement_condition,
                                   single_step!, set_xX!, state_contractor_steps, state_contractor_γ,
                                   state_contractor_k, excess_error, set_Δ!, compute_X0!, set_P!, excess_error,
                                   contains, calc_alpha, mul_split!

makedocs(modules = [DynamicBounds, DynamicBoundsBase, DynamicBoundspODEsIneq, DynamicBoundspODEsDiscrete],
         doctest = false,
         format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true",
                                  collapselevel = 1,),
         authors = "Matthew Wilhelm",
         sitename = "DynamicBounds.jl: Nonlinear Interval Bounds and State Relaxations of Differential Equations",
         pages = ["Introduction" => "index.md",
                  "Getting Started" => "getting_started.md",
                  "DynamicsBoundsBase, An extendable abstraction layer" => "Base/Base.md",
                  "Discrete-Time Differential Relaxations" => "pODEsDiscrete/pODEsDiscrete.md",
                  "Continuous-Time Differential Relaxations" => "pODEsIneq/pODEsIneq.md",
                  "Contributing to DynamicBounds" => "contributing.md",
                  "References" => "ref.md"]
)
@info "Deploying documentation..."
deploydocs(repo = "github.com/PSORLab/DynamicBounds.jl.git",
           push_preview  = true)
