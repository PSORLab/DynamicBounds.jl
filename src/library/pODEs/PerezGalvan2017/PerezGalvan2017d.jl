# Two-state Bioreactor
PerezGalvan2017d_t0 = 0.0
PerezGalvan2017d_tf = 10.0
PerezGalvan2017d_pL = [0.8; 1.1]
PerezGalvan2017d_pU = [0.85; 1.2]
PerezGalvan2017d_x0(p) = [p[1]; 0.8]
function PerezGalvan2017d_f(du, u, p, t)
    α = 0.5; k = 10.53; D = 0.36; Sf = 5.7; Ks = 7.0; k0 = 0.022
    μ = p[2]*u[2]/(Ks + u[2])
    du[1] = (μ - α*D)*u[1]
    du[2] = D*(Sf - u[2]) - k*μ*u[1]
    return
end
PerezGalvan2017d_id = :PerezGalvan2017d
PerezGalvan2017d_desc = "Two-state Bioreactor"
