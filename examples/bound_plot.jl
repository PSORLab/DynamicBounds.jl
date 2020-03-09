using DynamicBounds, Plots
pyplot()

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

function add_trajectory(plt, integrator, pL, pU)
    ratio = rand(6)
    pstar = pL.*ratio .+ pU.*(1.0 .- ratio)
    setall!(integrator, ParameterValue(), pstar)
    integrate!(integrator)
    plot!(plt, integrator.local_problem_storage.integrator_t,
    integrator.local_problem_storage.pode_x[1,:], label="", linecolor = :green,
    markershape = :+, markercolor = :green, linestyle = :dash, markersize = 2, lw=0.75)
    return plt
end

# Example from Improved relaxations for the parametric solutionsof ODEs using differential inequalities
function generate_plot()
    tspan = (0.0,18.0e-5*250)
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

    Scott2013(prob, calculate_relax = false, calculate_subgradient = false)
    integrator = Scott2013(prob, calculate_relax = false, calculate_subgradient = false)

    relax!(integrator)

    plt = plot(integrator.relax_t, integrator.relax_lo[1,:], label="Interval Bounds", linecolor = :darkblue, linestyle = :dash, lw=1.5, legend=:bottomleft)
    plot!(plt, integrator.relax_t, integrator.relax_hi[1,:], label="", linecolor = :darkblue, linestyle = :dash, lw=1.5)
    ylabel!("x[1] (M)")
    xlabel!("Time (seconds)")

    ratio = rand(6)
    pstar = pL.*ratio .+ pU.*(1.0 .- ratio)
    setall!(integrator, ParameterValue(), pstar)
    integrate!(integrator)
    plot!(plt, integrator.local_problem_storage.integrator_t,
    integrator.local_problem_storage.pode_x[1,:], label="Trajectories", linecolor = :green,
    markershape = :+, markercolor = :green, linestyle = :dash, markersize = 2, lw=0.75)

    for i in 1:39
        add_trajectory(plt, integrator, pL, pU)
    end
    plt
end

plt = generate_plot()
Plots.eps(plt, "C:\\Users\\wilhe\\Desktop\\Package Development Work\\sample_plot")

#=
function add_trajectory(plt, integrator, pL, pU)
    ratio = rand(6)
    pstar = pL.*ratio .+ pU.*(1.0 .- ratio)
    setall!(integrator, ParameterValue(), pstar)
    integrate!(integrator)
    plot!(plt, integrator.local_problem_storage.integrator_t,
    integrator.local_problem_storage.pode_x[1,:], label="", lw=1)
    return plt
end

plt = add_trajectory(plt, integrator, pL, pU)
plt = add_trajectory(plt, integrator, pL, pU)
plot(plt)
show(plt)
=#

#invariant = DenseLinearInvariant(A, b)
#xnew = Interval.(xL,xU)
#xprior = Interval.(xL,xU)

#=
using Plots
plot([integrator.local_problem_storage.pode_x[1,:],
      integrator.local_problem_storage.pode_x[2,:],
      integrator.local_problem_storage.pode_x[3,:],
      integrator.local_problem_storage.pode_x[4,:],
      integrator.local_problem_storage.pode_x[5,:],
      integrator.local_problem_storage.pode_x[6,:]])
=#

#using Profile, ProfileView
#test_func(x::Int) = relax!(integrator)
#@profview test_func(1)
#@profview test_func(2)
#=
t = integrator.relax_t
println("length(t): $(length(t))")

#cv1 = integrator.relax_cv[1,:]
#cc1 = integrator.relax_cc[1,:]
lo1 = integrator.relax_lo[1,:]
hi1 = integrator.relax_hi[1,:]
val1 = integrator.local_problem_storage.pode_x[1,:]

#cv2 = integrator.relax_cv[2,:]
#cc2 = integrator.relax_cc[2,:]
lo2 = integrator.relax_lo[2,:]
hi2 = integrator.relax_hi[2,:]
val2 = integrator.local_problem_storage.pode_x[2,:]

p1 = Plots.plot(t, lo1, label="lo[1,:]", title="Dim1")
#Plots.plot!(t, cc1, label="cc[1,:]")
#Plots.plot!(t, cv1, label="cv[1,:]")
Plots.plot!(t, hi1, label="hi[1,:]")
Plots.plot!(integrator.local_problem_storage.integrator_t, val1, label="val[1,:]")

prob = integrator.relax_ode_prob
#@code_warntype prob.f.f(ScottA2013a_pL, ScottA2013a_pL, ScottA2013a_pL, ScottA2013a_tf)
=#
