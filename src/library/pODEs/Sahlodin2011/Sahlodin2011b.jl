# Lotka-Volterra, np = 1
id = :Sahlodin2011b

pL = [2.95]
pU = [3.05]
Sahlodin2011b_x0(p::Vector{T}) where T = T[1.2*one(T); 1.1*one(T)]
function Sahlodin2011b_f!(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T
    du[1] = p[1]*u[1]*(1.0 - u[2])
    du[2] = p[1]*u[2]*(u[1] - 1.0)
    return
end
tspan = (0.0, 2.0)

prob = ODERelaxProb(Sahlodin2011b_f!, tspan, Sahlodin2011b_x0, pL, pU)
url = "https://www.sciencedirect.com/science/article/abs/pii/S0168927411000316"
source = "Sahlodin2011"
desc = "Lotka-Volterra, np = 1"
