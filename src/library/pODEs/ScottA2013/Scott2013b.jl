# Example from Improved relaxations for the parametric solutionsof ODEs using differential inequalities
id = :ScottA2013b

pL = [1.0; 1.0; 0.001]
pU = [1200.0; 1200.0; 100.0]
ScottA2013b_x0(p::Vector{T}) where T = [1.53*10^(-4)*one(T); 0.4*one(T); zero(T);
                                        zero(T); 0.0019*one(T); zero(T); zero(T);
                                        zero(T); zero(T); zero(T)]
function ScottA2013b_f!(du::Vector{T}, u::Vector{T}, p::Vector{T}, t) where T

    k = T[53.0*one(T); p[1]; p[2]; p[3], 1200.0*one(T)]
    K2 = 2081.0
    K3 = 4162.0

    S = zeros(10,5)
    S[1,1] = -1.0; S[2,1] = -1.0; S[3,1] = 1.0;  S[3,2:3] = -1.0; S[3,5] = -2.0;
    S[4,1] = 1.0; S[5,2] = -1.0;  S[5,3] = -1.0; S[6,2] = 1.0;
    S[7,3] = 1.0; S[7,4] = -1.0;  S[8,4] = 1.0;  S[9,4] = 1.0;  S[10,5] = 1.0

    r = zeros(T, 5)
    r[1] = k[1]*u[1]*u[2]
    r[2] = k[2]*(u[3]*u[5] - (1.0/K2)*u[6])
    r[3] = k[3]*(u[3]*u[5] - (1.0/K3)*u[7])
    r[4] = k[4]*u[7]
    r[5] = k[5]*u[3]^2

    du[:] = S*r
    return
end
tspan = (0.0, 2.0)

prob = ODERelaxProb(ScottA2013b_f!, tspan, ScottA2013b_x0, pL, pU)
url = "https://link.springer.com/article/10.1007%2Fs10898-012-9909-0"
source = "ScottA2013b"
desc = "Cyclohexadienyl Radical Oxidation"
