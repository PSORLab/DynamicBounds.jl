# Example from "Bounds on the reachable sets of nonlinear control systems" Constant Temperature Profile
id = :ScottB2013a

pL = [420.0]
pU = [480.0]
ScottB2013a_x0(p::Vector{T}) where T = [1.5*one(T); 0.5*one(T); zero(T)]
function ScottB2013a_f!(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T

    R = 8.134
    A1 = 2400
    A2 = 8800
    E1 = 6.9*10^3
    E2 = 1.69*10^4

    du[1] = -A1*exp(E1/(R*p[1]))*u[1]
    du[2] = A1*exp(E1/(R*p[1]))*u[1] - A2*exp(E2/(R*p[1]))*u[2]
    du[3] = A2*exp(E2/(R*p[1]))*u[2]
    return
end
tspan = (0.0, 0.08)

prob = ODERelaxProb(ScottB2013a_f!, tspan, ScottB2013a_x0, pL, pU)
url = "https://www.sciencedirect.com/science/article/pii/S0005109812004839"
source = "ScottB2013"
desc = "3 Series Rxn Network"
