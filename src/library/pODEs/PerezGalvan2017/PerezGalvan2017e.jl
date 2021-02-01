# Three-state Bioreactor
id = :PerezGalvan2017e

pL = [6.45; 0.46; 1.05]
pU = [6.55; 0.47; 1.1]
PerezGalvan2017e_x0(p::Vector{T}) where T = T[p[1]; 5.0*one(T); 15.0*one(T)]
function PerezGalvan2017e_f!(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T
    x3m = 50.0; x2f = 20.0; D = 0.202; Y = 0.4; β = 0.2; α = 0.5
    μ = p[2]*(1.0 - u[3]/x3m)*u[2]/(p[3] + u[2])
    du[1] = (μ - D)*u[1]
    du[2] = D*(x2f - u[2]) - μ*u[1]/Y
    du[3] = D*u[3] + (α*μ + β)*u[1]
    return
end
tspan = (0.0, 7.7)

prob = ODERelaxProb(PerezGalvan2017e_f!, tspan, PerezGalvan2017e_x0, pL, pU)
url = "https://www.sciencedirect.com/science/article/abs/pii/S0098135417300923"
source = "PerezGalvan2017"
desc = "Three-state Bioreactor"
