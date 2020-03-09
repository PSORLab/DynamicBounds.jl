"""
    $(FUNCTIONNAME)
"""
abstract type Wilhelm2019Type end
const W19T = Wilhelm2019Type

"""
    $(FUNCTIONNAME)
"""
struct ImpEuler <: W19T end

"""
    $(FUNCTIONNAME)
"""
struct AM2 <: W19T end

"""
    $(FUNCTIONNAME)
"""
struct BDF2 <: W19T end

local_integrator(wt::ImpEuler) = ImplicitEuler(autodiff = false)
local_integrator(wt::AM2) = Trapezoid(autodiff = false)
local_integrator(wt::BDF2) = ABDF2(autodiff = false)

"""
    $(FUNCTIONNAME)
"""
mutable struct CallbackH{V,F,T<:W19T} <: Function
    temp::Vector{V}
    xold1::Vector{V}
    xold2::Vector{V}
    h!::F
    t2::Float64
    t1::Float64
end
function CallbackH{V,F,T}(nx::Int,h!::F) where {V,F,T<:W19T}
    return CallbackH{V,F,T}(zeros(V,nx), zeros(V,nx), zeros(V,nx), h!,0.0,0.0)
end

function (cb::CallbackH{V,F,ImpEuler})(out, x, p) where {V,F}
    cb.h!(out, x, p, cb.t2)
    delT = cb.t2 - cb.t1
    for j in eachindex(out)
        @inbounds out[j] = out[j]*delT - x[j] + cb.xold1[j]
    end
    return
end

function (cb::CallbackH{V,F,AM2})(out, x, p::Vector{V}) where {V,F}
    cb.h!(out, x, p, cb.t2)
    cb.h!(cb.temp, cb.xold1, p, cb.t1)
    halfdelT = 0.5*(cb.t2 - cb.t1)
    for j in eachindex(out)
        @inbounds out[j] = halfdelT*(out[j] + cb.temp[j]) - x[j] + cb.xold1[j]
    end
    return
end
function (cb::CallbackH{V,F,BDF2})(out, x, p::Vector{V}) where {V,F}
    cb.h!(out, x, p, cb.t2)
    twothirddelT = 2.0*(cb.t2 - cb.t1)/3.0
    for j in eachindex(out)
        @inbounds out[j] = twothirddelT*out[j] - x[j] + (4.0/3.0)*cb.xold1[j] - (1.0/3.0)*cb.xold2[j]
    end
    return
end

"""
    $(FUNCTIONNAME)
"""
mutable struct CallbackHJ{F, T <: W19T} <: Function
    hj!::F
    tf::Float64
    delT::Float64
end
CallbackHJ{F,T}(hj!::F) where {F, T <: W19T} = CallbackHJ{F,T}(hj!,0.0,0.0)

function (cb::CallbackHJ{F, ImpEuler})(out, x, p) where F
    cb.hj!(out, x, p, cb.tf)
    for j in eachindex(out)
        @inbounds out[j] *= cb.delT
    end
    for j in diagind(out)
        @inbounds out[j] -= 1.0
    end
    return
end
function (cb::CallbackHJ{F, AM2})(out, x, p) where F
    cb.hj!(out, x, p, cb.tf)
    for j in eachindex(out)
        @inbounds out[j] *= 0.5*cb.delT
    end
    for j in diagind(out)
        @inbounds out[j] -= 1.0
    end
    return
end
function (cb::CallbackHJ{F, BDF2})(out, x, p) where F
    cb.hj!(out, x, p, cb.tf)
    for j in eachindex(out)
        @inbounds out[j] *= 2.0*cb.delT/3.0
    end
    for j in diagind(out)
        @inbounds out[j] -= 1.0
    end
    return
end

"""
$(TYPEDEF)

$(TYPEDFIELDS)
"""
mutable struct Wilhelm2019{T <: W19T, ICB1 <: PICallback, ICB2 <: PICallback,
                           PRE, CTR <: AbstractContractor,
                           IC <: Function, F, Z, J, PRB, N, C, AMAT} <: AbstractODERelaxIntegator

    # problem specifications
    integrator_type::T
    time::Vector{Float64}
    steps::Int
    p::Vector{Float64}
    pL::Vector{Float64}
    pU::Vector{Float64}
    nx::Int
    np::Int
    xL::Array{Float64,2}
    xU::Array{Float64,2}

    # state of integrator flags
    integrator_states::IntegratorStates
    evaluate_interval::Bool
    evaluate_state::Bool
    differentiable_flag::Bool

    # storage used for parametric interval methods
    P::Vector{Interval{Float64}}
    X::Array{Interval{Float64},2}
    X0P::Vector{Interval{Float64}}
    pi_callback1::ICB1
    pi_callback2::ICB2
    pi_precond!::PRE
    pi_contractor::CTR
    inclusion_flag::Bool
    exclusion_flag::Bool
    extended_division_flag::Bool

    # callback functions used for MC methods
    ic::IC
    h1::CallbackH{Z,F,ImpEuler}
    h2::CallbackH{Z,F,T}
    hj1::CallbackHJ{J,ImpEuler}
    hj2::CallbackHJ{J,T}
    mccallback1::MCCallback
    mccallback2::MCCallback

    # storage used for MC methods
    IC_relax::Vector{Z}
    state_relax::Array{Z,2}
    var_relax::Vector{Z}
    param::Vector{Vector{Vector{Z}}}
    kmax::Int

    # local evaluation information
    local_problem_storage::LocalProblemStorage{N}
end

function Wilhelm2019(d::ODERelaxProb, t::T) where {T <: W19T}

    h! = d.f
    hj! = d.fj!
    time = d.tsupports
    steps = length(time) - 1
    p = d.p
    pL = d.pL
    pU = d.pU
    nx = d.nx
    np = length(p)
    xL = (d.xL === nothing) ? zeros(nx,steps) : d.xL
    xU = (d.xU === nothing) ? zeros(nx,steps) : d.xU

    P = Interval{Float64}.(pL, pU)
    X = zeros(Interval{Float64}, nx, steps)
    X0P = zeros(Interval{Float64}, nx)
    pi_precond! = DenseMidInv(zeros(Float64,nx,nx), zeros(Interval{Float64},1), nx, np)
    pi_contractor = NewtonInterval(nx)
    inclusion_flag = false
    exclusion_flag = false
    extended_division_flag = false
    Z = MC{np,NS}

    ic = d.x0
    h1 = CallbackH{Z,typeof(h!),ImpEuler}(nx, h!)
    h2 = CallbackH{Z,typeof(h!),T}(nx, h!)
    hj1 = CallbackHJ{typeof(hj!),ImpEuler}(hj!)
    hj2 = CallbackHJ{typeof(hj!),T}(hj!)

    h1intv! = CallbackH{Interval{Float64},typeof(h!),ImpEuler}(nx, h!)
    h2intv! = CallbackH{Interval{Float64},typeof(h!),T}(nx, h!)
    hj1intv! = CallbackHJ{typeof(hj!),ImpEuler}(hj!)
    hj2intv! = CallbackHJ{typeof(hj!),T}(hj!)

    pi_callback1 = PICallback(h1intv!, hj1intv!, P, nx)
    pi_callback2 = PICallback(h2intv!, hj2intv!, P, nx)

    mc_callback1 = MCCallback(h1, hj1, nx, np)
    mc_callback2 = MCCallback(h2, hj2, nx, np)

    # storage used for MC methods
    kmax = 2
    IC_relax = zeros(Z,nx)
    state_relax = zeros(Z, nx, steps)
    param = Vector{Vector{Z}}[[zeros(Z,nx) for j in 1:kmax] for i in 1:steps]
    var_relax = zeros(Z,np)

    local_problem_storage = LocalProblemStorage(d)
    abc = problem_type(local_problem_storage)
    return Wilhelm2019{T, typeof(pi_callback1), typeof(pi_callback2),
                       typeof(pi_precond!), typeof(pi_contractor),
                       typeof(ic), typeof(h!), Z, typeof(hj!), problem_type(local_problem_storage),
                       np, NewtonGS, Array{Float64,2}}(t, time, steps, p, pL, pU, nx, np, xL, xU,
                       IntegratorStates(), false, false, false,
                       P, X, X0P, pi_callback1, pi_callback2, pi_precond!,
                       pi_contractor, inclusion_flag, exclusion_flag,
                       extended_division_flag, ic, h1, h2, hj1, hj2,
                       mc_callback1, mc_callback2, IC_relax, state_relax,
                       var_relax, param, kmax, local_problem_storage)
end

function relax!(d::Wilhelm2019)

    # load state relaxation bounds at support values
    if d.integrator_states.set_lower_state || d.integrator_states.set_upper_state
        @. d.X = Interval{Float64}(d.xL, d.xU)
    end

    # if P has been updated perform an parametric interval contraction,
    # if evaluate_interval_only is false then generate the reference point
    # for the relaxations and compute a relaxation value (and subgradients)
    # at the reference point
    if d.integrator_states.new_decision_box

        # evaluate initial condition
        d.X0P .= d.ic(d.P)

        # loads CallbackH and CallbackHJ function with correct time and prior x values
        @inbounds for j=1:d.nx
            d.pi_callback1.X[j] = d.X[j,1]
        end
        d.pi_callback1.h!.xold1 .= d.X0P
        d.pi_callback1.h!.t1 = 0.0
        d.pi_callback1.h!.t2 = d.time[2]
        d.pi_callback1.hj!.tf = d.time[2]
        d.pi_callback1.hj!.delT = d.time[2]
        d.pi_callback1.P .= d.P
        d.pi_callback2.P .= d.P

        # run interval contractor on first step
        excl, incl, extd = parametric_interval_contractor(d.pi_callback1,
                                                          d.pi_precond!,
                                                          d.pi_contractor)

        # break if solution is provden not to exist in (X,P)
        if excl
            d.integrator_states.termination_status = EMPTY
            return
        end

        # save logical flags
        d.exclusion_flag = excl
        d.inclusion_flag = incl
        d.extended_division_flag = extd

        # store interval values to storage array in d
        @inbounds for j=1:d.nx
            d.X[j,1] = d.pi_contractor.X[j]
        end

        for i in 2:d.steps
            # loads CallbackH and CallbackHJ function with correct time and prior x values
            @inbounds for j=1:d.nx
                d.pi_callback2.X[j] = d.X[j,i]
                d.pi_callback2.h!.xold1[j] = d.X[j,i-1]
                if i == 2
                    d.pi_callback2.h!.xold2[j] = d.X0P[j]
                else
                    d.pi_callback2.h!.xold2[j] = d.X[j,i-2]
                end
            end
            @inbounds d.pi_callback2.h!.t1 = d.time[i]
            @inbounds d.pi_callback2.h!.t2 = d.time[i+1]
            @inbounds d.pi_callback2.hj!.delT = d.time[i+1] - d.time[i]
            @inbounds d.pi_callback2.hj!.tf = d.time[i+1]

            # run interval contractor on ith step
            excl, incl, extd = parametric_interval_contractor(d.pi_callback2,
                                                              d.pi_precond!,
                                                              d.pi_contractor)

            # break if solution is provden not to exist in (X,P)
            if excl
                d.integrator_states.termination_status = EMPTY
                return
            end

            # save logical flags
            d.exclusion_flag = excl
            d.inclusion_flag = incl
            d.extended_division_flag = extd

            # store interval values to storage array in d
            @inbounds for j=1:d.nx
                d.X[j,i] = d.pi_contractor.X[j]
            end
        end

        # generate reference point relaxations
        if ~d.evaluate_interval
            # load MC mccallback function for implicit routine
            @inbounds for j=1:d.np
                d.mccallback1.P[j] = d.P[j]
                d.mccallback1.p_mc[j] = MC{d.np,NS}(d.p[j], d.P[j], j)
                d.mccallback1.pref_mc[j] = d.mccallback1.p_mc[j]
                d.mccallback2.P[j] = d.P[j]
                d.mccallback2.p_mc[j] = d.mccallback1.p_mc[j]
                d.mccallback2.pref_mc[j] = d.mccallback1.pref_mc[j]
            end
            @inbounds for j=1:d.nx
                d.mccallback1.X[j] = d.X[j,1]
            end

            # evaluate initial condition
            d.IC_relax .= d.ic(d.mccallback1.pref_mc)

            # loads CallbackH and CallbackHJ function with correct time and prior x values
            d.mccallback1.h!.t1 = 0.0
            d.mccallback1.h!.t2 = d.time[2]
            d.mccallback1.h!.xold1 .= d.IC_relax
            d.mccallback1.hj!.tf = d.time[2]
            d.mccallback1.hj!.delT = d.time[2]

            # generate and save reference point relaxations
            gen_expansion_params!(d.mccallback1)
            for q=1:d.kmax
                for j=1:d.nx
                    @inbounds d.param[1][q][j] = d.mccallback1.param[q][j]
                end
            end

            # generate and save relaxation at reference point
            implicit_relax_h!(d.mccallback1)
            @inbounds for j=1:d.nx
                d.state_relax[j,1] = d.mccallback1.x_mc[j]
            end

            for i=2:d.steps
                # loads MCcallback, CallbackH and CallbackHJ function with correct time and prior x values
                @inbounds for j=1:d.nx
                    d.mccallback2.X[j] = d.X[i,j]
                    d.mccallback2.h!.xold1[j] = d.state_relax[j,i-1]
                    if i == 2
                        d.mccallback2.h!.xold2[j] = d.IC_relax[j]
                    else
                        d.mccallback2.h!.xold2[j] = d.state_relax[j,i-2]
                    end
                end
                @inbounds d.mccallback2.h!.t1 = d.time[i]
                @inbounds d.mccallback2.h!.t2 = d.time[i+1]
                @inbounds d.mccallback2.hj!.tf = d.time[i+1]
                @inbounds d.mccallback2.hj!.delT = d.time[i+1] - d.time[i]

                # generate and save reference point relaxations
                gen_expansion_params!(d.mccallback2)
                for q=1:d.kmax
                    for j=1:d.nx
                        @inbounds d.param[i][q][j] = d.mccallback2.param[q][j]
                    end
                end

                # generate and save relaxation at reference point
                implicit_relax_h!(d.mccallback2)
                @inbounds for j=1:d.nx
                    d.state_relax[j+d.nx*(i-1)] = d.mccallback2.x_mc[j]
                end
            end
        end
    end

    # generate other point relaxations
    if d.integrator_states.new_decision_pnt && ~d.evaluate_interval

        # update relaxation of p on P
        @inbounds for j=1:d.np
            d.var_relax[j] = MC{d.np,NS}(d.p[j], d.P[j], j)
            d.mccallback1.p_mc[j] = d.var_relax[j]
            d.mccallback2.p_mc[j] = d.var_relax[j]
        end

        # compute initial condition
        d.IC_relax .= d.ic(d.var_relax)

        # loads MC callback, CallbackH and CallbackHJ function with correct time and prior x values
        @inbounds for j=1:d.nx
            d.mccallback1.X[j] = d.X[j,1]
        end
        d.mccallback1.h!.t1 = 0.0
        d.mccallback1.h!.t2 = d.time[2]
        d.mccallback1.h!.xold1 .= d.IC_relax
        d.mccallback1.hj!.tf = d.time[2]
        d.mccallback1.hj!.delT = d.time[2]
        for q=1:d.kmax
            for j=1:d.nx
                @inbounds d.mccallback1.param[q][j] = d.param[1][q][j]
            end
        end

        # computes relaxation
        implicit_relax_h!(d.mccallback1)
        @inbounds for j=1:d.nx
            d.state_relax[j] = d.mccallback1.x_mc[j]
        end
        for i=2:d.steps
            # loads MC callback, CallbackH and CallbackHJ function with correct time and prior x values
            @inbounds for j=1:d.nx
                d.mccallback2.X[j] = d.X[i,j]
                d.mccallback2.h!.xold1[j] = d.state_relax[j,i-1]
                if i == 2
                    d.mccallback2.h!.xold2[j] = d.IC_relax[j]
                else
                    d.mccallback2.h!.xold2[j] = d.state_relax[j,i-2]
                end
            end
            @inbounds d.mccallback2.h!.t1 = d.time[i]
            @inbounds d.mccallback2.h!.t2 = d.time[i+1]
            @inbounds d.mccallback2.hj!.tf = d.time[i+1]
            @inbounds d.mccallback2.hj!.delT = d.time[i+1] - d.time[i]
            for q=1:d.kmax
                for j=1:d.nx
                    @inbounds d.mccallback2.param[q][j] = d.param[i][q][j]
                end
            end

            # computes relaxation
            implicit_relax_h!(d.mccallback2)
            @inbounds for j=1:d.nx
                d.state_relax[j+d.nx*(i-1)] = d.mccallback2.x_mc[j]
            end
        end
    end

    # unpack interval bounds to integrator bounds
    if d.evaluate_interval
        for i in 1:d.nx
            for j in 1:d.steps
                @inbounds d.xL[i,j] = d.X[i,j].lo
                @inbounds d.xU[i,j] = d.X[i,j].hi
            end
        end
    else
        for i in 1:d.nx
            for j in 1:d.steps
                @inbounds d.xL[i,j] = d.state_relax[i,j].Intv.lo
                @inbounds d.xU[i,j] = d.state_relax[i,j].Intv.hi
            end
        end
    end

    # sets evaluation flags
    d.integrator_states.new_decision_box = false
    d.integrator_states.new_decision_pnt = false
    return
end

function integrate!(d::Wilhelm2019)
    d.local_problem_storage.pduals .= seed_duals(d.p)
    d.local_problem_storage.x0duals .= d.ic(d.local_problem_storage.pduals)
    @inbounds for i in 1:d.np
        d.local_problem_storage.x0local[i] = d.local_problem_storage.x0duals[i].value
        @inbounds for j in 1:d.nx
            d.local_problem_storage.x0local[(j+d.np+(i-1)*d.nx)] = d.local_problem_storage.x0duals[i].partials[j]
        end
    end
    d.local_problem_storage.pode_problem = remake(d.local_problem_storage.pode_problem, u0 = d.local_problem_storage.x0local, p = d.p)
    solution = solve(d.local_problem_storage.pode_problem, local_integrator(d.integrator_type), tstops = d.time, adaptive = false)
    d.local_problem_storage.pode_x[:,:], d.local_problem_storage.pode_dxdp[:] = extract_local_sensitivities(solution)
    return
end

supports(::Wilhelm2019, ::IntegratorName) = true
supports(::Wilhelm2019, ::Gradient) = true
supports(::Wilhelm2019, ::Subgradient) = true
supports(::Wilhelm2019, ::Bound) = true
supports(::Wilhelm2019, ::Relaxation) = true
supports(::Wilhelm2019, ::IsNumeric) = true
supports(::Wilhelm2019, ::IsSolutionSet) = true
supports(::Wilhelm2019, ::TerminationStatus) = true
supports(::Wilhelm2019, ::Value) = true
supports(::Wilhelm2019, ::ParameterValue) = true

get(t::Wilhelm2019, v::IntegratorName) = "Wilhelm 2019 Integrator"
get(t::Wilhelm2019, v::IsNumeric) = true
get(t::Wilhelm2019, v::IsSolutionSet) = false
get(t::Wilhelm2019, s::TerminationStatus) = t.integrator_states.termination_status

function getall!(out::Array{Float64,2}, t::Wilhelm2019, v::Value)
    out .= t.local_problem_storage.pode_x
    return
end

function getall!(out::Vector{Array{Float64,2}}, t::Wilhelm2019, g::Gradient{NOMINAL})
    for i in 1:t.np
        @inbounds for j in eachindex(out[i])
            out[i][j] = t.local_problem_storage.pode_dxdp[i][j]
        end
    end
    return
end

function getall!(out::Vector{Array{Float64,2}}, t::Wilhelm2019, g::Gradient{LOWER})
    if ~t.differentiable_flag
        error("Integrator does not generate differential relaxations. Set the
               differentiable_flag field to true and reintegrate.")
    end
    for i in 1:t.np
        if t.evaluate_interval
            fill!(out[i], 0.0)
        else
            @inbounds for j in eachindex(out[i])
                out[i][j] = t.state_relax[j].cv_grad[i]
            end
        end
    end
    return
end
function getall!(out::Vector{Array{Float64,2}}, t::Wilhelm2019, g::Gradient{UPPER})
    if ~t.differentiable_flag
        error("Integrator does not generate differential relaxations. Set the
               differentiable_flag field to true and reintegrate.")
    end
    for i in 1:t.np
        if t.evaluate_interval
            fill!(out[i], 0.0)
        else
            @inbounds for j in eachindex(out[i])
                out[i][j] = t.state_relax[j].cc_grad[i]
            end
        end
    end
    return
end

function getall!(out::Vector{Array{Float64,2}}, t::Wilhelm2019, g::Subgradient{LOWER})
    for i in 1:t.np
        if t.evaluate_interval
            fill!(out[i], 0.0)
        else
            @inbounds for j in eachindex(out[i])
                out[i][j] = t.state_relax[j].cv_grad[i]
            end
        end
    end
    return
end
function getall!(out::Vector{Array{Float64,2}}, t::Wilhelm2019, g::Subgradient{UPPER})
    for i in 1:t.np
        if t.evaluate_interval
            fill!(out[i], 0.0)
        else
            @inbounds for j in eachindex(out[i])
                out[i][j] = t.state_relax[j].cc_grad[i]
            end
        end
    end
    return
end

function getall!(out::Array{Float64,2}, t::Wilhelm2019, v::Bound{LOWER})
    out .= t.xL
    return
end

function getall!(out::Vector{Float64}, t::Wilhelm2019, v::Bound{LOWER})
    out[:] = t.xL[1,:]
    return
end

function getall!(out::Array{Float64,2}, t::Wilhelm2019, v::Bound{UPPER})
    out .= t.xU
    return
end

function getall!(out::Vector{Float64}, t::Wilhelm2019, v::Bound{UPPER})
    out[:] = t.xU[1,:]
    return
end

function getall!(out::Array{Float64,2}, t::Wilhelm2019, v::Relaxation{LOWER})
    if t.evaluate_interval
        @inbounds for i in eachindex(out)
            out[i] = t.X[i].lo
        end
    else
        @inbounds for i in eachindex(out)
            out[i] = t.state_relax[i].cv
        end
    end
    return
end
function getall!(out::Vector{Float64}, t::Wilhelm2019, v::Relaxation{LOWER})
    if t.evaluate_interval
        @inbounds for i in eachindex(out)
            out[i] = t.X[i].lo
        end
    else
        @inbounds for i in eachindex(out)
            out[i] = t.state_relax[i].cv
        end
    end
    return
end

function getall!(out::Array{Float64,2}, t::Wilhelm2019, v::Relaxation{UPPER})
    if t.evaluate_interval
        @inbounds for i in eachindex(out)
            out[i] = t.X[i].hi
        end
    else
        @inbounds for i in eachindex(out)
            out[i] = t.state_relax[i].cc
        end
    end
    return
end
function getall!(out::Vector{Float64}, t::Wilhelm2019, v::Relaxation{UPPER})
    if t.evaluate_interval
        @inbounds for i in eachindex(out)
            out[i] = t.X[i].hi
        end
    else
        @inbounds for i in eachindex(out)
            out[i] = t.state_relax[i].cc
        end
    end
    return
end

function setall!(t::Wilhelm2019, v::ParameterBound{LOWER}, value::Vector{Float64})
    t.integrator_states.new_decision_box = true
    @inbounds for i in 1:t.np
        t.pL[i] = value[i]
    end
    return
end

function setall!(t::Wilhelm2019, v::ParameterBound{UPPER}, value::Vector{Float64})
    t.integrator_states.new_decision_box = true
    @inbounds for i in 1:t.np
        t.pU[i] = value[i]
    end
    return
end

function setall!(t::Wilhelm2019, v::ParameterValue, value::Vector{Float64})
    t.integrator_states.new_decision_pnt = true
    @inbounds for i in 1:t.np
        t.p[i] = value[i]
    end
    return
end

function setall!(t::Wilhelm2019, v::Bound{LOWER}, values::Array{Float64,2})
    if t.integrator_states.new_decision_box
        t.integrator_states.set_lower_state = true
    end
    for i in 1:t.nx
        @inbounds for j in 1:t.steps
            t.xL[i,j] = values[i,j]
        end
    end
    return
end

function setall!(t::Wilhelm2019, v::Bound{LOWER}, values::Vector{Float64})
    if t.integrator_states.new_decision_box
        t.integrator_states.set_lower_state = true
    end
    @inbounds for i in 1:t.steps
        t.xL[1,i] = values[i]
    end
    return
end

function setall!(t::Wilhelm2019, v::Bound{UPPER}, values::Array{Float64,2})
    if t.integrator_states.new_decision_box
        t.integrator_states.set_upper_state = true
    end
    for i in 1:t.nx
        @inbounds for j in 1:t.steps
            t.xU[i,j] = values[i,j]
        end
    end
    return
end

function setall!(t::Wilhelm2019, v::Bound{UPPER}, values::Vector{Float64})
    if t.integrator_states.new_decision_box
        t.integrator_states.set_upper_state = true
    end
    @inbounds for i in 1:t.steps
        t.xU[1,i] = values[i]
    end
    return
end
