# Exothermic Batch Reactor
id = :PerezGalvan2017c

pL = [310.0; 290.0]
pU = [410.0; 310.0]
PerezGalvan2017c_x0(p::Vector{T}) where T = T[zero(T); p[1]]
function PerezGalvan2017c_f!(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T
    du[1] =  0.022*(1.0-u[1])*exp(-6000/(8.314*u[2]))
    du[2] = 0.05*(p[2]-u[2]) - (-14000.0/6.0)*0.022*(1-u[1])*exp(-6000.0/(8.314*u[2]))
    return
end
tspan = (0.0, 60.0)

prob = ODERelaxProb(PerezGalvan2017c_f!, tspan, PerezGalvan2017c_x0, pL, pU)
url = "https://www.sciencedirect.com/science/article/abs/pii/S0098135417300923"
source = "PerezGalvan2017"
desc = "Exothermic Batch Reactor"
