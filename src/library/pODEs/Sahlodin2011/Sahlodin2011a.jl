# First-order irreversible series reaction
id = :Sahlodin2011a

pL = [-1.0]
pU = [1.0]
Sahlodin2011a_x0(p::Vector{T}) where T = T[9.0*one(T)]
function Sahlodin2011a_f!(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T
    du[1] = -u[1]^2 + p[1]
    return
end
tspan = (0.0, 1.0)

prob = ODERelaxProb(Sahlodin2011a_f!, tspan, Sahlodin2011a_x0, pL, pU)
url = "https://www.sciencedirect.com/science/article/abs/pii/S0168927411000316"
source = "Sahlodin2011"
desc = "First-order irreversible series reaction"
