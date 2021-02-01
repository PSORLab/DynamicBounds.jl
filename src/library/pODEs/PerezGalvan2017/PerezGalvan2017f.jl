# Reactor Separator Model
id = :PerezGalvan2017f

pL = [0.0; 0.0]
pU = [0.08; 0.16]
PerezGalvan2017f_x0(p::Vector{T}) where T = T[0.5; 0.0; 0.0; 0.0; p[1]; p[2]]
function PerezGalvan2017f_f(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T
    k = 0.06; xF0 = 0.0; D = 1.0; H = 63.33
    α = 7.5; B = 1.2; L = 1.704; F = 1.0
    V = pi*(H/4)*D^2    # THIS MAY BE INCORRECT...
    xF = (F*xF0 + B*u[2])/(F + B)
    y2 = α*u[2]/(1.0 + (α-1.0)*u[2])
    y3 = α*u[3]/(1.0 + (α-1.0)*u[3])
    y4 = α*u[4]/(1.0 + (α-1.0)*u[4])
    y5 = α*u[5]/(1.0 + (α-1.0)*u[5])
    du[1] = (F+B)*(xF - u[1])/H + k*u[1]*(1.0 - u[1])
    du[2] = (L + F + B)*u[3] - B*u[2] - V*y2
    du[3] = (L + F + B)*(u[4] - u[3]) + V*(y2 - y3)
    du[4] = (F+B)*u[1] + L*u[5] - (L + F + B)*u[4] +V*(y3 - y4)
    du[5] = L*(u[6] - u[5]) + V*(y4 - y5)
    du[6] = -(L + D)*u[6] + V*y5
    return
end
tspan = (0.0, 100.0)

prob = ODERelaxProb(PerezGalvan2017d_f!, tspan, PerezGalvan2017d_x0, pL, pU)
url = "https://www.sciencedirect.com/science/article/abs/pii/S0098135417300923"
source = "PerezGalvan2017"
desc = "Reactor Separator Model"
