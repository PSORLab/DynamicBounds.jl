using Plots
using DynamicBounds
using DiffEqBase: ODEFunction
using DataFrames

function f(du,u,p,t)
    du[1] = 0.0
    for i in 2:20
        du[i] = p[1]*(u[i+1] - 2.0*u[i] + u[i-1])
    end
    du[21] = 0.0
    return
end
function fj(Jout,u,p,t)

end
function x0(p)
    x = collect(range(-1,1,step=0.1))
    return cos.(pi*x./2.0)
end
pL = [0.9]
pU = [1.1]
nt = 21
nx = 21

kwargs = Dict{Symbol,Any}()
prob = ODERelaxProb(f, (0,1), collect(1:(nt-1)), x0, 0.5*(pL+pU), pL, pU, nt,
                    xLconst = zeros(nx), xUconst = zeros(nx), kwargs...)
#integrator = make(prob, Wilhelm2019(AM2()))
npnts = 20
value = zeros(nx,nt)
lower_bound = zeros(nx,nt)
upper_bound = zeros(nx,nt)
convex = zeros(nx,nt)
concave = zeros(nx,nt)
for p in range(pL, pU, length = npnts)
    set!(integrator, ParameterValue(1), p)
    integrate!(integrator)
    getall!(values, integrator, Value())
    getall!(lower_bound, integrator, Bound{LOWER}())
    getall!(upper_bound, integrator, Bound{UPPER}())
    getall!(convex, integrator, Relaxation{LOWER}())
    getall!(concave, integrator, Relaxation{UPPER}())
end

#=
4x4 plot
1 surface
2 interval/convex
3 convex with
End Point... Relative Trajectory
=#
