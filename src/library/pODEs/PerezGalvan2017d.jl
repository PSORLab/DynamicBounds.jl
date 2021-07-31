# Two-state Bioreactor
id = :PerezGalvan2017d

pL = [0.8; 1.1]
pU = [0.85; 1.2]
PerezGalvan2017d_x0(p::Vector{T}) where T = T[p[1]; 0.8*one(T)]
function PerezGalvan2017d_f!(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T
    α = 0.5; k = 10.53; D = 0.36; Sf = 5.7; Ks = 7.0; k0 = 0.022
    μ = p[2]*u[2]/(Ks + u[2])
    du[1] = (μ - α*D)*u[1]
    du[2] = D*(Sf - u[2]) - k*μ*u[1]
    return
end
tspan = (0.0, 10.0)

prob = ODERelaxProb(PerezGalvan2017d_f!, tspan, PerezGalvan2017d_x0, pL, pU)
url = "https://www.sciencedirect.com/science/article/abs/pii/S0098135417300923"
source = "PerezGalvan2017"
desc = "Two-state Bioreactor"
