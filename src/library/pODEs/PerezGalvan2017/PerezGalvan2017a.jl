# First-order irreversible series reaction
id = :PerezGalvan2017a

pL = [4.5; 0.2]
pU = [0.2; 1.8]
PerezGalvan2017a_x0(p::Vector{T}) where T = T[one(T); zero(T)]
function PerezGalvan2017a_f!(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T
    du[1] = -p[1]*u[1]
    du[2] = p[1]*u[1] - p[2]*u[2]
    return
end
tspan = (0.0, 1.0)

prob = ODERelaxProb(PerezGalvan2017a_f!, tspan, PerezGalvan2017a_x0, pL, pU)
url = "https://www.sciencedirect.com/science/article/abs/pii/S0098135417300923"
source = "PerezGalvan2017"
desc = "First-order irreversible series reaction"
