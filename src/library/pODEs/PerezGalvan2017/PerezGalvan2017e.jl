# Three-state Bioreactor
PerezGalvan2017e_t0 = 0.0
PerezGalvan2017e_tf = 7.7
PerezGalvan2017e_pL = [6.45; 0.46; 1.05]
PerezGalvan2017e_pU = [6.55; 0.47; 1.1]
PerezGalvan2017e_x0(p) = [p[1]; 5.0; 15.0]
function PerezGalvan2017e_f(du, u, p, t)
    x3m = 50.0; x2f = 20.0; D = 0.202; Y = 0.4; β = 0.2; α = 0.5
    μ = p[2]*(1.0 - u[3]/x3m)*u[2]/(p[3] + u[2])
    du[1] = (μ - D)*u[1]
    du[2] = D*(x2f - u[2]) - μ*u[1]/Y
    du[3] = D*u[3] + (α*μ + β)*u[1]
    return
end
PerezGalvan2017e_id = :PerezGalvan2017e
PerezGalvan2017e_desc = "Three-state Bioreactor"
