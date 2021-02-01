# Example from Improved relaxations for the parametric solutionsof ODEs using differential inequalities
id = :ScottA2013a

pL = [-6.5; 0.01]
pU = [1.0; 0.05]
ScottA2013a_x0(p::Vector{T}) where T = T[one(T); 0.5*one(T)]
function ScottA2013a_f!(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T
    du[1] = -(2.0 + sin(p[1]/3.0))*u[1]^2 + p[2]*u[1]*u[2]
    du[2] = sin(p[1]/3.0)*u[1]^2 - p[2]*u[1]*u[2]
    return
end
tspan = (0.0, 2.0)

prob = ODERelaxProb(ScottA2013a_f!, tspan, ScottA2013a_x0, pL, pU)
url = "https://link.springer.com/article/10.1007%2Fs10898-012-9909-0"
source = "ScottA2013"
desc = "Sinusodial Example 1"
