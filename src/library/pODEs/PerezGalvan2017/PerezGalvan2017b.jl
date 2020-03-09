# First-order reversible series reaction INCONSISTENT NOTATION IN TABLE, CHECK LATER
PerezGalvan2017b_t0 = 0.0
PerezGalvan2017b_tf = 0.5
PerezGalvan2017b_pL = [2.0; 1.0]
PerezGalvan2017b_pU = [6.0; 3.0]
PerezGalvan2017b_x0(p) = [1.0; 0.0]
function PerezGalvan2017b_f(du, u, p, t)
    k1 = p[1]
    k1rev = p[2]
    k2 = 2.0
    k2rev = 20.0
    du[1] = -k1*u[1] + k1rev*u[2]
    du[2] = k1*u[1] - (k1rev + k2)*u[2] + k2rev*(1.0 - u[1] - u[2])
    return
end
PerezGalvan2017b_id = :PerezGalvan2017b
PerezGalvan2017b_desc = "First-order reversible series reaction"
