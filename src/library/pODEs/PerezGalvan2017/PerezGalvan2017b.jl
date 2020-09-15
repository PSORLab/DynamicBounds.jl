# First-order reversible series reaction INCONSISTENT NOTATION IN TABLE, CHECK LATER
id = :PerezGalvan2017b

pL = [2.0; 1.0]
pU = [6.0; 3.0]
PerezGalvan2017b_x0(p::Vector{T}) where T = T[one(T); zero(T)]
function f!(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T
    k1 = p[1]
    k1rev = p[2]
    k2 = 2.0
    k2rev = 20.0
    du[1] = -k1*u[1] + k1rev*u[2]
    du[2] = k1*u[1] - (k1rev + k2)*u[2] + k2rev*(1.0 - u[1] - u[2])
    return
end
tspan = (0.0, 0.5)

prob = ODERelaxProb(PerezGalvan2017b_f!, tspan, PerezGalvan2017b_x0, pL, pU)
url = "https://www.sciencedirect.com/science/article/abs/pii/S0098135417300923"
source = "PerezGalvan2017"
desc = "First-order reversible series reaction"
