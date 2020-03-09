
mutable struct IntegratorStates
    first_pnt_eval::Bool
    new_decision_box::Bool
    new_decision_pnt::Bool
    set_lower_state::Bool
    set_upper_state::Bool
    termination_status::TerminationStatusCode
end
IntegratorStates() =  IntegratorStates(false, true, true, false, false, RELAXATION_NOT_CALLED)

struct RelaxDualTag end

function seed_duals(x::AbstractArray{V}, ::Chunk{N} = Chunk(x)) where {V,N}
  seeds = construct_seeds(Partials{N,V})
  duals = [Dual{RelaxDualTag}(x[i],seeds[i]) for i in eachindex(x)]
end

#=
PARAMETRIC INTERVAL CONTRACTOR METHODS FOR WILHELM 2019
=#

"""
    $(FUNCTIONNAME)

Returns true if X1 and X2 are equal to within tolerance atol in all dimensions.
"""
function is_equal(X1::S, X2::Vector{Interval{Float64}}, atol::Float64, nx::Int) where S
    out::Bool = true
    @inbounds for i=1:nx
        if (abs(X1[i].lo - X2[i].lo) >= atol ||
            abs(X1[i].hi - X2[i].hi) >= atol )
            out = false
            break
        end
    end
    return out
end

"""
$(FUNCTIONNAME)

Returns true if X is strictly in Y (X.lo>Y.lo && X.hi<Y.hi).
"""
function strict_x_in_y(X::Interval{Float64}, Y::Interval{Float64})
  (X.lo <= Y.lo) && return false
  (X.hi >= Y.hi) && return false
  return true
end

"""
$(FUNCTIONNAME)
"""
function inclusion_test(inclusion_flag::Bool, inclusion_vector::Vector{Bool}, nx::Int)
    if inclusion_flag == false
        @inbounds for i=1:nx
            if inclusion_vector[i]
                inclusion_flag = true
                continue
            else
                inclusion_flag = false
                break
            end
        end
    end
    return inclusion_flag
end

"""
$(FUNCTIONNAME)

Subfunction to generate output for extended division.
"""
function extended_divide(A::Interval{Float64})
    if (A.lo == -0.0) && (A.hi == 0.0)
        B::Interval{Float64} = Interval{Float64}(-Inf,Inf)
        C::Interval{Float64} = B
        return 0,B,C
    elseif (A.lo == 0.0)
        B = Interval{Float64}(1.0/A.hi,Inf)
        C = Interval{Float64}(Inf,Inf)
        return 1,B,C
    elseif (A.hi == 0.0)
        B = Interval{Float64}(-Inf,1.0/A.lo)
        C = Interval{Float64}(-Inf,-Inf)
        return 2,B,C
    else
        B = Interval{Float64}(-Inf,1.0/A.lo)
        C = Interval{Float64}(1.0/A.hi,Inf)
        return 3,B,C
    end
end

"""
$(FUNCTIONNAME)

Generates output boxes for extended division and flag.
"""
function extended_process(N::Interval{Float64}, X::Interval{Float64},
                          Mii::Interval{Float64}, SB::Interval{Float64},
                          rtol::Float64)

    Ntemp = Interval{Float64}(N.lo, N.hi)
    M = SB + Interval{Float64}(-rtol, rtol)
    if (M.lo <= 0) && (M.hi >= 0)
        return 0, Interval{Float64}(-Inf,Inf), Ntemp
    end

    k, IML, IMR = extended_divide(Mii)
    if (k === 1)
        NL = 0.5*(X.lo+X.hi) - M*IML
        return 0, NL, Ntemp
    elseif (k === 2)
        NR = 0.5*(X.lo+X.hi) - M*IMR
        return 0, NR, Ntemp
    elseif (k === 3)
        NR = 0.5*(X.lo+X.hi) - M*IMR
        NL = 0.5*(X.lo+X.hi) - M*IML
        if ~isdisjoint(NL,X) && isdisjoint(NR,X)
            return 0, NL, Ntemp
        elseif ~isdisjoint(NR,X) && isdisjoint(NL,X)
            return 0, NR, Ntemp
        elseif ~isdisjoint(NL,X) && ~isdisjoint(NR,X)
            N = NL
            Ntemp = NR
            return 1, NL, NR
        else
            return -1, N, Ntemp
        end
    end
    return 0, N, Ntemp
end

"""
$(TYPEDEF)
"""
abstract type AbstractIntervalCallback end

"""
$(TYPEDEF)
"""
struct PICallback{FH,FJ} <:  AbstractIntervalCallback
    h!::FH
    hj!::FJ
    H::Vector{Interval{Float64}}
    J::Array{Interval{Float64},2}
    xmid::Vector{Float64}
    X::Vector{Interval{Float64}}
    P::Vector{Interval{Float64}}
    nx::Int
end
function PICallback(h!::FH, hj!::FJ, P::Vector{Interval{Float64}}, nx::Int) where {FH,FJ}
    H = zeros(Interval{Float64}, nx)
    J = zeros(Interval{Float64}, nx, nx)
    xmid = zeros(Float64, nx)
    X = zeros(Interval{Float64}, nx)
    return PICallback{FH,FJ}(h!, hj!, H, J, xmid, X, P, nx)
end

function (d::PICallback{FH,FJ})() where {FH,FJ}
    fill!(d.H, Interval{Float64}(0.0,0.0))
    fill!(d.J, Interval{Float64}(0.0,0.0))
    @inbounds for i in 1:d.nx
        d.xmid[i] = 0.5*(d.X[i].lo + d.X[i].hi)
    end
    d.h!(d.H, d.xmid, d.P)
    d.hj!(d.J, d.X, d.P)
    return
end

"""
$(TYPEDEF)
"""
function precondition!(d::DenseMidInv, H::Vector{Interval{Float64}}, J::Array{Interval{Float64},2})
    for i in eachindex(J)
        @inbounds d.Y[i] = 0.5*(J[i].lo + J[i].hi)
    end
    F = lu!(d.Y)
    H .= F\H
    J .= F\J
    return
end

"""
$(TYPEDEF)
"""
abstract type AbstractContractor end

"""
$(TYPEDEF)
"""
struct NewtonInterval <: AbstractContractor
    N::Vector{Interval{Float64}}
    Ntemp::Vector{Interval{Float64}}
    X::Vector{Interval{Float64}}
    Xdiv::Vector{Interval{Float64}}
    inclusion::Vector{Bool}
    lower_inclusion::Vector{Bool}
    upper_inclusion::Vector{Bool}
    kmax::Int
    rtol::Float64
    etol::Float64
end
function NewtonInterval(nx::Int; kmax::Int = 5, rtol::Float64 = 1E-6, etol::Float64 = 1E-6)
    N = zeros(Interval{Float64}, nx)
    Ntemp = zeros(Interval{Float64}, nx)
    X = zeros(Interval{Float64}, nx)
    Xdiv = zeros(Interval{Float64}, nx)
    inclusion = fill(false, (nx,))
    lower_inclusion = fill(false, (nx,))
    upper_inclusion = fill(false, (nx,))
    return NewtonInterval(N, Ntemp, X, Xdiv, inclusion, lower_inclusion,
                          upper_inclusion, kmax, rtol, etol)
end
function (d::NewtonInterval)(callback::PICallback{FH,FJ}) where {FH,FJ}

    ext_division_flag::Bool = false
    exclusion_flag::Bool = false

    @inbounds for i=1:callback.nx
        S1 = zero(Interval{Float64})
        S2 = zero(Interval{Float64})
        @inbounds for j=1:callback.nx
            if (j < i)
                S1 += callback.J[i,j]*(d.X[j] - 0.5*(d.X[j].lo + d.X[j].hi))
            elseif (j > i)
                S2 += callback.J[i,j]*(d.X[j] - 0.5*(d.X[j].lo + d.X[j].hi))
            end
        end
        @inbounds if callback.J[i,i].lo*callback.J[i,i].hi > 0.0
            @inbounds d.N[i] = 0.5*(d.X[i].lo + d.X[i].hi) - (callback.H[i]+S1+S2)/callback.J[i,i]
        else
            @. d.Ntemp = d.N
            eD, d.N[i], d.Ntemp[i] = extended_process(d.N[i], d.X[i], callback.J[i,i],
                                                    S1+S2+callback.H[i], d.rtol)
            if eD == 1
                ext_division_flag = true
                @. d.Xdiv = d.X
                d.Xdiv[i] = d.Ntemp[i] ∩ d.X[i]
                d.X[i] = d.N[i] ∩ d.X[i]
                return ext_division_flag, exclusion_flag
            end
        end
        @inbounds if strict_x_in_y(d.N[i], d.X[i])
            d.inclusion[i] = true
            d.lower_inclusion[i] = true
            d.upper_inclusion[i] = true
        else
            d.inclusion[i] = false
            d.lower_inclusion[i] = false
            d.upper_inclusion[i] = false
            if (d.N[i].lo > d.X[i].lo)
                d.lower_inclusion[i] = true
            elseif (d.N[i].hi < d.X[i].hi)
                d.upper_inclusion[i] = true
            end
        end
        @inbounds if ~isdisjoint(d.N[i], d.X[i])
            d.X[i] = d.N[i] ∩ d.X[i]
        else
            return ext_division_flag, exclusion_flag
        end
    end
    return ext_division_flag, exclusion_flag
end

function parametric_interval_contractor(callback!::PICallback{FH,FJ}, precond!::P,
                                        contractor::S) where {FH,
                                                              FJ,
                                                              P,
                                                              S <: AbstractContractor}
    exclusion_flag = false
    inclusion_flag = false
    ext_division_flag = false
    ext_division_num = 0

    for i in eachindex(contractor.X)
        @inbounds contractor.inclusion[i] = false
        @inbounds contractor.lower_inclusion[i] = false
        @inbounds contractor.upper_inclusion[i] = false
        @inbounds contractor.X[i] = callback!.X[i]
    end

    for i=1:contractor.kmax
        callback!()::Nothing
        precondition!(precond!, callback!.H, callback!.J)::Nothing
        exclusion_flag, ext_division_flag = contractor(callback!)::Tuple{Bool,Bool}
        (exclusion_flag || ext_division_flag) && break
        inclusion_flag = inclusion_test(inclusion_flag, contractor.inclusion,
                                        callback!.nx)
        for j in eachindex(callback!.X)
            @inbounds callback!.X[j] = contractor.X[j]
        end
    end

    return exclusion_flag, inclusion_flag, ext_division_flag
end

mutable struct LocalProblemStorage{PRB, N}
    pode_problem
    pode_x::ElasticArray{Float64,2}
    pode_dxdp::Vector{ElasticArray{Float64,2}}
    x0local::Vector{Float64}
    pduals::Vector{Dual{RelaxDualTag,Float64,N}}
    x0duals::Vector{Dual{RelaxDualTag,Float64,N}}
    integator
    user_t::Vector{Float64}
    integrator_t::Vector{Float64}
    abstol::Float64
    reltol::Float64
end
problem_type(x::LocalProblemStorage{N}) where {N} = typeof(pode_problem)

function LocalProblemStorage(d::ODERelaxProb, integator, user_t::Vector{Float64})
    np = length(d.p)
    pode_problem = ODEForwardSensitivityProblem(d.f, zeros(Float64, d.nx), d.tspan, d.p)
    pode_x = zeros(Float64, d.nx, length(d.tsupports))
    pode_dxdp = Array{Float64,2}[zeros(Float64, d.nx, length(d.tsupports)) for i=1:np]
    pduals = seed_duals(d.p)
    sing_seed = single_seed(Partials{np, Float64}, Val(1))
    x0duals = fill(Dual{RelaxDualTag}(0.0, sing_seed), (d.nx,))
    x0local = zeros((np+1)*d.nx)
    local_problem_storage = LocalProblemStorage{typeof(pode_problem), np}(pode_problem, pode_x, pode_dxdp,
                                                    x0local, pduals, x0duals, integator, user_t, Float64[],
                                                    1E-9, 1E-8)
    return local_problem_storage
end
