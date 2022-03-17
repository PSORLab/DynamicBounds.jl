#!/usr/bin/env julia

using Test, DynamicBounds
const DEqR = DynamicBounds

@testset "Integrator Attributes Interface" begin

    struct UndefinedIntegrator <: DEqR.AbstractDERelaxIntegrator end
    struct UndefinedProblem <: DEqR.AbstractDERelaxProblem end

    mutable struct TestIntegrator <: DEqR.AbstractODERelaxIntegrator
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

    DEqR.set!(t::TestIntegrator, a::DEqR.Gradient, value) = (t.temp = value)
    DEqR.set!(t::TestIntegrator, a::DEqR.Subgradient, value) = (t.temp = value)
    DEqR.set!(t::TestIntegrator, a::DEqR.Bound, value) = (t.temp = value)
    DEqR.set!(t::TestIntegrator, a::DEqR.Relaxation, value) = (t.temp = value)
    DEqR.set!(t::TestIntegrator, a::DEqR.TerminationStatus, value) = (t.temp = value)
    DEqR.set!(t::TestIntegrator, a::DEqR.Value, value) = (t.temp = value)

    undefined_integrator = UndefinedIntegrator()
    @test !DEqR.supports(undefined_integrator, DEqR.IntegratorName())
    @test !DEqR.supports(undefined_integrator, DEqR.Gradient{DEqR.Lower}(1.0))
    @test !DEqR.supports(undefined_integrator, DEqR.Subgradient{DEqR.Lower}(1.0))
    @test !DEqR.supports(undefined_integrator, DEqR.Bound{DEqR.Lower}(1.0))
    @test !DEqR.supports(undefined_integrator, DEqR.Relaxation{DEqR.Lower}(1.0))
    @test !DEqR.supports(undefined_integrator, DEqR.IsNumeric())
    @test !DEqR.supports(undefined_integrator, DEqR.IsSolutionSet())
    @test !DEqR.supports(undefined_integrator, DEqR.TerminationStatus())
    @test !DEqR.supports(undefined_integrator, DEqR.Value())

    test_integrator = TestIntegrator(1.0)
    @test @inferred DEqR.supports(test_integrator, DEqR.IntegratorName())
    @test @inferred DEqR.supports(test_integrator, DEqR.Gradient{DEqR.Lower}(1.0))
    @test @inferred DEqR.supports(test_integrator, DEqR.Subgradient{DEqR.Lower}(1.0))
    @test @inferred DEqR.supports(test_integrator, DEqR.Bound{DEqR.Lower}(1.0))
    @test @inferred DEqR.supports(test_integrator, DEqR.Relaxation{DEqR.Lower}(1.0))
    @test @inferred DEqR.supports(test_integrator, DEqR.IsNumeric())
    @test @inferred DEqR.supports(test_integrator, DEqR.IsSolutionSet())
    @test @inferred DEqR.supports(test_integrator, DEqR.TerminationStatus())
    @test @inferred DEqR.supports(test_integrator, DEqR.Value())

    @test_nowarn @inferred DEqR.set!(test_integrator, DEqR.Gradient{DEqR.Lower}(1.1), 1.2)
    val = @inferred DEqR.get(test_integrator, DEqR.Gradient{DEqR.Lower}(1.1))
    @test val === 1.2
    @test_nowarn @inferred DEqR.set!(test_integrator, DEqR.Subgradient{DEqR.Lower}(1.1), 1.3)
    val = @inferred DEqR.get(test_integrator, DEqR.Subgradient{DEqR.Lower}(1.1))
    @test val === 1.3
    @test_nowarn @inferred DEqR.set!(test_integrator, DEqR.Bound{DEqR.Lower}(1.1), 1.4)
    val = @inferred DEqR.get(test_integrator, DEqR.Bound{DEqR.Lower}(1.1))
    @test val === 1.4
    @test_nowarn @inferred DEqR.set!(test_integrator, DEqR.Relaxation{DEqR.Lower}(1.1), 1.5)
    val = @inferred DEqR.get(test_integrator, DEqR.Relaxation{DEqR.Lower}(1.1))
    @test val === 1.5
    @test_nowarn DEqR.set!(test_integrator, DEqR.Value(), 1.53)
    val = @inferred DEqR.get(test_integrator, DEqR.Value())
    @test val === 1.53

    sval = @inferred DEqR.get(test_integrator, DEqR.IntegratorName())
    @test sval === "TestIntegrator"
    @test @inferred DEqR.get(test_integrator, DEqR.IsNumeric())
    @test @inferred DEqR.get(test_integrator, DEqR.IsSolutionSet())

    @test_nowarn @inferred DEqR.set!(test_integrator, DEqR.TerminationStatus(), 1.9)
    val = @inferred DEqR.get(test_integrator, DEqR.TerminationStatus())
    @test val === 1.9

    @test_throws ArgumentError DEqR.get(UndefinedIntegrator(), DEqR.IntegratorName())
end

@testset "Test DifferentialInequality Relaxation" begin

    x0(p) = [34.0; 20.0; 0.0; 0.0; 16.0; 0.0]
    function f!(du, u, p, t)
        du[1] = -p[1]*u[1]*u[2] + p[2]*u[3] + p[6]*u[6]
        du[2] = -p[1]*u[1]*u[2] + p[2]*u[3] + p[3]*u[3]
        du[3] =  p[1]*u[1]*u[2] - p[2]*u[3] - p[3]*u[3]
        du[4] =  p[3]*u[3] - p[4]*u[4]*u[5] + p[5]*u[6]
        du[5] = -p[4]*u[4]*u[5] + p[5]*u[6] + p[6]*u[6]
        du[6] =  p[4]*u[4]*u[5] - p[5]*u[6] - p[6]*u[6]
        return
    end


    tspan = (0.0,18.0e-5*50)
    pL = [0.1; 0.033; 16.0; 5.0; 0.5; 0.3]
    pU = 10.0*pL

    prob = ODERelaxProb(f!, tspan, x0, pL, pU)

    A = [0.0 -1.0 -1.0  0.0  0.0  0.0;
         0.0  0.0  0.0  0.0 -1.0 -1.0;
         1.0 -1.0 0.0 1.0 -1.0 0.0]
    b = [-20.0; -16.0; -2.0]
    set!(prob, PolyhedralConstraint(A, b))

    xL = zeros(6)
    xU = [34.0; 20.0; 20.0; 34.0; 16.0; 16.0]
    set!(prob, ConstantStateBounds(xL,xU))

    integrator = DifferentialInequality(prob, calculate_relax = true,
                                        calculate_subgradient = true)

    relax!(integrator)

    @test isapprox(integrator.relax_lo[6,77], 0.0169958, atol = 1E-5)
    @test isapprox(integrator.relax_hi[6,77], 8.08922, atol = 1E-3)
    @test isapprox(integrator.relax_cv[6,77], 0.0169958, atol = 1E-5)
    @test isapprox(integrator.relax_cc[6,77], 4.15395, atol = 1E-3)
    @test isapprox(integrator.relax_cv_grad[6,77][6], -0.00767, atol = 1E-5)
    @test isapprox(integrator.relax_cc_grad[6,77][5], 0.002858, atol = 1E-5)
end

@testset "pODE Problem" begin

    x0_ex1(p) = [0.5; 0.4]

    function f_ex1(du,u,p,t)
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

    ode_prob1 = @test_nowarn DEqR.ODERelaxProb(f_ex1, tspan, x0_ex1, pL, pU)

    out = zeros(Float64, 2)
    jout = zeros(Float64, 2, 2)
    @test_nowarn @inferred ode_prob1.f(out, xeval, p, 1.5)
    @test out[1] == 1.4
    @test isapprox(out[2],  2.4)

    @test DEqR.supports(ode_prob1, DEqR.HasStateBounds())
    @test DEqR.supports(ode_prob1, DEqR.HasConstantStateBounds())
    @test DEqR.supports(ode_prob1, DEqR.HasVariableStateBounds())
    @test DEqR.supports(ode_prob1, DEqR.HasUserJacobian())

    flag = @test_nowarn @inferred DEqR.get(ode_prob1, DEqR.HasStateBounds())
    @test !flag
    flag = @test_nowarn @inferred DEqR.get(ode_prob1, DEqR.HasConstantStateBounds())
    @test !flag
    flag = @test_nowarn @inferred DEqR.get(ode_prob1, DEqR.HasVariableStateBounds())
    @test !flag
end

@testset "pODEs Library Utilities" begin
    prob = fetch_instance("pODEs", "Sahlodin2011b")
    @test prob.id == :Sahlodin2011b
    @test prob.desc == "Lotka-Volterra, np = 1"
    @test prob.source == "Sahlodin2011"
    @test prob.url == "https://www.sciencedirect.com/science/article/abs/pii/S0168927411000316"
end