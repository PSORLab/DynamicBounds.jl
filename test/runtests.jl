#!/usr/bin/env julia

using Test, DynamicBounds, DiffEqBase, McCormick

const DEqR = DynamicBounds
const TSC = DEqR.TerminationStatusCode
#=
Creates a test integrators to separate unit testing in the abstraction layer
from any upstream integrator issues.
=#
@testset "Integrator Attributes Interface" begin

    struct UndefinedIntegrator <: DEqR.AbstractDERelaxIntegator end
    struct UndefinedProblem <: DEqR.AbstractDERelaxProblem end

    mutable struct TestIntegrator <: DEqR.AbstractODERelaxIntegator
        temp::Float64
    end

    DEqR.supports(::TestIntegrator, ::DEqR.IntegratorName) = true
    DEqR.supports(::TestIntegrator, ::DEqR.Gradient) = true
    DEqR.supports(::TestIntegrator, ::DEqR.Subgradient) = true
    DEqR.supports(::TestIntegrator, ::DEqR.Bound) = true
    DEqR.supports(::TestIntegrator, ::DEqR.Relaxation) = true
    DEqR.supports(::TestIntegrator, ::DEqR.IsNumeric) = true
    DEqR.supports(::TestIntegrator, ::DEqR.IsSolutionSet) = true
    DEqR.supports(::TestIntegrator, ::DEqR.TerminationStatus) = true
    DEqR.supports(::TestIntegrator, ::DEqR.Value) = true

    DEqR.get(t::TestIntegrator, a::DEqR.IntegratorName) = "TestIntegrator"
    DEqR.get(t::TestIntegrator, a::DEqR.Gradient) = t.temp
    DEqR.get(t::TestIntegrator, a::DEqR.Subgradient) = t.temp
    DEqR.get(t::TestIntegrator, a::DEqR.Bound) = t.temp
    DEqR.get(t::TestIntegrator, a::DEqR.Relaxation) = t.temp
    DEqR.get(t::TestIntegrator, a::DEqR.IsNumeric) = true
    DEqR.get(t::TestIntegrator, a::DEqR.IsSolutionSet) = true
    DEqR.get(t::TestIntegrator, a::DEqR.TerminationStatus) = t.temp
    DEqR.get(t::TestIntegrator, a::DEqR.Value) = t.temp

    DEqR.set(t::TestIntegrator, a::DEqR.Gradient, value) = (t.temp = value)
    DEqR.set(t::TestIntegrator, a::DEqR.Subgradient, value) = (t.temp = value)
    DEqR.set(t::TestIntegrator, a::DEqR.Bound, value) = (t.temp = value)
    DEqR.set(t::TestIntegrator, a::DEqR.Relaxation, value) = (t.temp = value)
    DEqR.set(t::TestIntegrator, a::DEqR.TerminationStatus, value) = (t.temp = value)
    DEqR.set(t::TestIntegrator, a::DEqR.Value, value) = (t.temp = value)

    undefined_integrator = UndefinedIntegrator()
    @test !DEqR.supports(undefined_integrator, DEqR.IntegratorName())
    @test !DEqR.supports(undefined_integrator, DEqR.Gradient{DEqR.LOWER}(1.0))
    @test !DEqR.supports(undefined_integrator, DEqR.Subgradient{DEqR.LOWER}(1.0))
    @test !DEqR.supports(undefined_integrator, DEqR.Bound{DEqR.LOWER}(1.0))
    @test !DEqR.supports(undefined_integrator, DEqR.Relaxation{DEqR.LOWER}(1.0))
    @test !DEqR.supports(undefined_integrator, DEqR.IsNumeric())
    @test !DEqR.supports(undefined_integrator, DEqR.IsSolutionSet())
    @test !DEqR.supports(undefined_integrator, DEqR.TerminationStatus())
    @test !DEqR.supports(undefined_integrator, DEqR.Value())

    test_integrator = TestIntegrator(1.0)
    @test @inferred DEqR.supports(test_integrator, DEqR.IntegratorName())
    @test @inferred DEqR.supports(test_integrator, DEqR.Gradient{DEqR.LOWER}(1.0))
    @test @inferred DEqR.supports(test_integrator, DEqR.Subgradient{DEqR.LOWER}(1.0))
    @test @inferred DEqR.supports(test_integrator, DEqR.Bound{DEqR.LOWER}(1.0))
    @test @inferred DEqR.supports(test_integrator, DEqR.Relaxation{DEqR.LOWER}(1.0))
    @test @inferred DEqR.supports(test_integrator, DEqR.IsNumeric())
    @test @inferred DEqR.supports(test_integrator, DEqR.IsSolutionSet())
    @test @inferred DEqR.supports(test_integrator, DEqR.TerminationStatus())
    @test @inferred DEqR.supports(test_integrator, DEqR.Value())

    @test_nowarn @inferred DEqR.set(test_integrator, DEqR.Gradient{DEqR.LOWER}(1.1), 1.2)
    val = @inferred DEqR.get(test_integrator, DEqR.Gradient{DEqR.LOWER}(1.1))
    @test val === 1.2
    @test_nowarn @inferred DEqR.set(test_integrator, DEqR.Subgradient{DEqR.LOWER}(1.1), 1.3)
    val = @inferred DEqR.get(test_integrator, DEqR.Subgradient{DEqR.LOWER}(1.1))
    @test val === 1.3
    @test_nowarn @inferred DEqR.set(test_integrator, DEqR.Bound{DEqR.LOWER}(1.1), 1.4)
    val = @inferred DEqR.get(test_integrator, DEqR.Bound{DEqR.LOWER}(1.1))
    @test val === 1.4
    @test_nowarn @inferred DEqR.set(test_integrator, DEqR.Relaxation{DEqR.LOWER}(1.1), 1.5)
    val = @inferred DEqR.get(test_integrator, DEqR.Relaxation{DEqR.LOWER}(1.1))
    @test val === 1.5
    @test_nowarn DEqR.set(test_integrator, DEqR.Value(), 1.53)
    val = @inferred DEqR.get(test_integrator, DEqR.Value())
    @test val === 1.53

    sval = @inferred DEqR.get(test_integrator, DEqR.IntegratorName())
    @test sval === "TestIntegrator"
    @test @inferred DEqR.get(test_integrator, DEqR.IsNumeric())
    @test @inferred DEqR.get(test_integrator, DEqR.IsSolutionSet())

    @test_nowarn @inferred DEqR.set(test_integrator, DEqR.TerminationStatus(), 1.9)
    val = @inferred DEqR.get(test_integrator, DEqR.TerminationStatus())
    @test val === 1.9

    @test_throws ArgumentError DEqR.get(UndefinedIntegrator(), DEqR.IntegratorName())
end

@testset "pODE Problem" begin

    x0(p) = [0.5; 0.4]
    xL(t) = t
    xU(t) = 3*t.^2

    function f(du,u,p,t)
        du[1] = u[1]*p[1]
        du[2] = u[2]*p[2]
        return
    end

    function user_jac(out,u,p,t)
        out[:,:] = [2.0 2.0; 2.0 2.0]
        return
    end

    xeval = [2.0; 3.0]
    p = [0.7; 0.8]
    pL = [0.5; 0.4]
    pU = [1.1; 1.0]
    xLc = [2.0; 3.1]
    xUc = [3.0; 4.1]
    tspan = (0.0,10.0)
    tsupports = [i for i in 0:0.25:10]

    ode_prob1 = @test_nowarn DEqR.ODERelaxProb(f, tspan, x0, pL, pU)
    ode_prob2 = @test_nowarn DEqR.ODERelaxProb(ODEFunction(f), (0.0,10.0), x0, pL, pU, xL = xLc, xU = xUc)
    ode_prob3 = @test_nowarn DEqR.ODERelaxProb(ODEFunction(f), (0.0,10.0), x0, pL, pU, jacobian = user_jac)

    out = zeros(Float64, 2)
    jout = zeros(Float64, 2, 2)
    @test_nowarn @inferred ode_prob1.f(out, xeval, p, 1.5)
    @test out[1] == 1.4
    @test isapprox(out[2],  2.4)

    @test ode_prob2.xL === xLc
    @test ode_prob2.xU === xUc

    @test DEqR.supports(ode_prob3, DEqR.HasStateBounds())
    @test DEqR.supports(ode_prob3, DEqR.HasConstantStateBounds())
    @test DEqR.supports(ode_prob3, DEqR.HasVariableStateBounds())
    @test DEqR.supports(ode_prob3, DEqR.HasUserJacobian())

    flag = @test_nowarn @inferred DEqR.get(ode_prob3, DEqR.HasStateBounds())
    @test !flag
    flag = @test_nowarn @inferred DEqR.get(ode_prob3, DEqR.HasConstantStateBounds())
    @test !flag
    flag = @test_nowarn @inferred DEqR.get(ode_prob3, DEqR.HasVariableStateBounds())
    @test !flag
    @test @inferred DEqR.get(ode_prob3, DEqR.HasUserJacobian())

    @test_throws AssertionError DEqR.ODERelaxProb(ODEFunction(f), (0.0,10.0),
                                                  x0, pL, pU,
                                                  xL = xLc,
                                                  xU = [1.0; 2.0; 3.0])
end

@testset "pODEs Library Utilities" begin
end

#=
@testset "Wilhelm2019" begin

    # Parametric Interval Subroutines test
    @test ~DEqR.strict_x_in_y(Interval{Float64}(-0.5,0.5), Interval{Float64}(-0.5,0.5))
    @test ~DEqR.strict_x_in_y(Interval{Float64}(-0.5,0.3), Interval{Float64}(-0.5,0.5))
    @test ~DEqR.strict_x_in_y(Interval{Float64}(-0.3,0.5), Interval{Float64}(-0.5,0.5))
    @test @inferred DEqR.strict_x_in_y(Interval{Float64}(-0.3,0.3), Interval{Float64}(-0.5,0.5))

    @test ~DEqR.is_equal(Interval{Float64}[Interval{Float64}(-2.0,2.2), Interval{Float64}(-3.0,3.0)],
                    Interval{Float64}[Interval{Float64}(-2.0,2.0), Interval{Float64}(-3.0,3.0)], 0.1, 2)
    @test @inferred DEqR.is_equal(Interval{Float64}[Interval{Float64}(-2.0,2.01), Interval{Float64}(-3.0,3.0)],
                             Interval{Float64}[Interval{Float64}(-2.0,2.0), Interval{Float64}(-3.0,3.0)], 0.1, 2)

    @test DEqR.inclusion_test(true, Bool[false,true], 2)
    @test ~DEqR.inclusion_test(false, Bool[false,true], 2)
    @test @inferred DEqR.inclusion_test(false, Bool[true,true], 2)

    # extended divide
    A1,B1,C1 = DEqR.extended_divide(Interval{Float64}(0.0))
    @test A1 === 0
    @test B1 === Interval{Float64}(-Inf,Inf)
    @test C1 === Interval{Float64}(-Inf,Inf)

    A1,B1,C1 = DEqR.extended_divide(Interval{Float64}(0.0, 2.0))
    @test A1 === 1
    @test B1 === Interval{Float64}(0.5, Inf)
    @test C1 === Interval{Float64}(Inf, Inf)

    A1,B1,C1 = DEqR.extended_divide(Interval{Float64}(-2.0, 0.0))
    @test A1 === 2
    @test B1 === Interval{Float64}(-Inf, -0.5)
    @test C1 === Interval{Float64}(-Inf, -Inf)

    A1,B1,C1 = DEqR.extended_divide(Interval{Float64}(-2.0, 2.0))
    @test A1 === 3
    @test B1 === Interval{Float64}(-Inf, -0.5)
    @test C1 === Interval{Float64}(0.5, Inf)

    setrounding(Interval, :accurate)

    function h!(out, z, p)
        out[1] = z[1]^2 + z[2]^2 + p[1]*z[1] + 4.0
        out[2] = z[1] + p[2]*z[2]
        return
    end
    function hj!(out, z, p::Vector{T}) where T
        out[1,1] = 2.0*z[1] + p[1]
        out[1,2] = 2.0*z[2]
        out[2,1] = one(T)
        out[2,2] = p[2]
        return
    end
    P = Interval{Float64}[Interval{Float64}(5.0, 7.0) for i=1:2]
    t = zeros(2)
    nx = 2
    callback! = DEqR.PICallback(h!,hj!,P,nx)
    callback!.X[:] = Interval{Float64}[Interval{Float64}(-1.5, 0.0),
                                       Interval{Float64}(0.0, 0.5)]
    newton = DEqR.NewtonInterval(2, kmax = 24)
    precond = DenseMidInv(2,2)
    DEqR.parametric_interval_contractor(callback!, precond, newton)

    @test isapprox(newton.X[1].lo, -1.04243, atol = 1E-4)
    @test isapprox(newton.X[1].hi, -0.492759, atol = 1E-4)
    @test isapprox(newton.X[2].lo, 0.0473789, atol = 1E-4)
    @test isapprox(newton.X[2].hi, 0.208486, atol = 1E-4)

    x0(p) = [p[1]; p[2]]

    function f!(du,u,p,t)
        du[1] = u[1]*p[1]
        du[2] = u[2]*p[2]
        return
    end

    function fj!(J,u,p,t)
        fill!(J, 0.0)
        J[1,1] = p[1]
        J[2,2] = p[2]
        return
    end

    xeval = [2.0; 3.0]
    p = [0.7; 0.8]
    pL = [0.5; 0.4]
    pU = [1.1; 1.0]
    xLc = [2.0 2.0;
           3.1 3.1]
    xLc = [3.0 3.0;
           4.1 4.1]
    tspan = (0.0, 10.0)
    tsupports = [i for i in 0:0.25:10]

    proby = ODERelaxProb(f!, tspan, tsupports, x0, p, pL, pU, 2, jacobian = fj!)
    wt19 = @test_nowarn DEqR.Wilhelm2019(proby, DEqR.AM2())
    pnew = [0.9; 0.8]
    @test_nowarn DEqR.setall!(wt19, DEqR.ParameterBound{DEqR.LOWER}(), [0.1, 0.2])
    @test_nowarn DEqR.setall!(wt19, DEqR.ParameterBound{DEqR.UPPER}(), [0.3, 0.4])
    @test wt19.pL[1] == 0.1
    @test wt19.pL[2] == 0.2
    @test wt19.pU[1] == 0.3
    @test wt19.pU[2] == 0.4
    @test wt19.integrator_states.new_decision_box = true
    DEqR.setall!(wt19, DEqR.ParameterValue(), pnew)
    @test wt19.p[1] == 0.9
    @test wt19.p[2] == 0.8
    @test wt19.integrator_states.new_decision_pnt = true

    @test DEqR.supports(wt19, DEqR.IntegratorName())
    @test DEqR.supports(wt19, DEqR.Gradient())
    @test DEqR.supports(wt19, DEqR.Subgradient())
    @test DEqR.supports(wt19, DEqR.Bound())
    @test DEqR.supports(wt19, DEqR.Relaxation())
    @test DEqR.supports(wt19, DEqR.IsNumeric())
    @test DEqR.supports(wt19, DEqR.IsSolutionSet())
    @test DEqR.supports(wt19, DEqR.TerminationStatus())
    @test DEqR.supports(wt19, DEqR.Value())
    @test DEqR.supports(wt19, DEqR.ParameterValue())

    @test DEqR.get(wt19, DEqR.IntegratorName()) === "Wilhelm 2019 Integrator"
    @test DEqR.get(wt19, DEqR.IsNumeric())
    @test ~DEqR.get(wt19, DEqR.IsSolutionSet())
    @test DEqR.get(wt19, DEqR.TerminationStatus()) === DEqR.RELAXATION_NOT_CALLED
    @test_nowarn DEqR.integrate!(wt19)
    uout = zeros(2,41)
    Jout = [zeros(2,41),zeros(2,41)]
    @test_nowarn DEqR.getall!(uout, wt19, DEqR.Value())
    @test_nowarn DEqR.getall!(Jout, wt19, DEqR.Gradient{DEqR.NOMINAL}())
    @test isapprox(uout[1,3], 1.41418, atol=1E-4)
    @test isapprox(uout[1,4], 1.77271, atol=1E-4)
    @test isapprox(Jout[1][1,2], 1.53917, atol=1E-4)
    @test isapprox(Jout[2][2,3], 2.09738917421, atol=1E-4)

    probnext = ODERelaxProb(f!, tspan, tsupports, x0, p, pL, pU, 2, jacobian = fj!)
    wt19a = DEqR.Wilhelm2019(probnext, DEqR.AM2())
    xLbnd = zeros(2,41) .+ -0.1
    xUbnd = zeros(2,41) .+ 1.0
    wt19a.xL = zeros(2,41)
    wt19a.xU = zeros(2,41)

    DEqR.setall!(wt19a, DEqR.Bound{DEqR.LOWER}(), xLbnd)
    DEqR.setall!(wt19a, DEqR.Bound{DEqR.UPPER}(), xUbnd)
    @test wt19a.xL[1] == -0.1
    @test wt19a.xU[1] == 1.0

    tempxL = zeros(2,41)
    tempxU = zeros(2,41)
    DEqR.getall!(tempxL, wt19a, DEqR.Bound{DEqR.LOWER}())
    DEqR.getall!(tempxU, wt19a, DEqR.Bound{DEqR.UPPER}())
    @test tempxL[1] == -0.1
    @test tempxU[1] == 1.0

    x0q(p) = [9.0]

    function fq!(du,u,p,t)
        du[1] = -u[1]^2 + p[1]
        return
    end

    function fqj!(J,u,p,t)
        fill!(J, 0.0)
        J[1,1] = -2.0*u[1]
        return
    end

    pq = [0.0]
    pLq = [-1.0]
    pUq = [1.0]

    tspanq = (0.0, 1.00)
    tsupportsq = [i for i in tspan[1]:0.1:tspan[2]]
    nq = length(tsupports)-1

    probyq = ODERelaxProb(fq!, tspanq, tsupports, x0q, pq, pLq, pUq, 1, jacobian = fqj!)
    wt19q = DEqR.Wilhelm2019(probyq, DEqR.BDF2())

    xLbndq = zeros(1,nq) .+ 0.1
    xUbndq = zeros(1,nq) .+ 9.0
    wt19q.xL = zeros(1,nq)
    wt19q.xU = zeros(1,nq)

    @test_nowarn DEqR.setall!(wt19q, DEqR.Bound{DEqR.LOWER}(), xLbndq)
    @test_nowarn DEqR.setall!(wt19q, DEqR.Bound{DEqR.UPPER}(), xUbndq)

    outbL = zeros(1,nq)
    outbU = zeros(1,nq)
    @test_nowarn DEqR.getall!(outbL, wt19q, DEqR.Bound{DEqR.LOWER}())
    @test_nowarn DEqR.getall!(outbU, wt19q, DEqR.Bound{DEqR.UPPER}())
    @test outbL == xLbndq
    @test outbU == xUbndq

    wt19q.evaluate_interval = false
    wt19q.integrator_states.new_decision_pnt = true
    @test_nowarn DEqR.relax!(wt19q)

    outrL = zeros(Float64,1,10)
    outrU = zeros(Float64,1,10)
    DEqR.getall!(outrL, wt19q, DEqR.Relaxation{DEqR.LOWER}())
    DEqR.getall!(outrU, wt19q, DEqR.Relaxation{DEqR.UPPER}())
    @test outrL[1,10] == 0.1
    @test isapprox(outrU[1,10], 2.760835055491985, atol=1E-4)

    outsL = [zeros(Float64,1,10)]
    outsU = [zeros(Float64,1,10)]
    DEqR.getall!(outsL, wt19q, DEqR.Subgradient{DEqR.LOWER}())
    DEqR.getall!(outsU, wt19q, DEqR.Subgradient{DEqR.UPPER}())
    @test outsL[1][1,10] == 0.0
    @test isapprox(outsU[1][1,7], 0.014010965280173267, atol=1E-4)

    outgL = [zeros(Float64,1,10)]
    outgU = [zeros(Float64,1,10)]
    @test_throws ErrorException DEqR.getall!(outgL, wt19q, DEqR.Gradient{DEqR.LOWER}())
    @test_throws ErrorException DEqR.getall!(outgU, wt19q, DEqR.Gradient{DEqR.UPPER}())
end
=#

@testset "Scott2013" begin
end
