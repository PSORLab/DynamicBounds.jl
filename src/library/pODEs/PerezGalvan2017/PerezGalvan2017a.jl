# First-order irreversible series reaction
PerezGalvan2017a_t0 = 0.0
PerezGalvan2017a_tf = 1.0
PerezGalvan2017a_pL = [4.5; 0.2]
PerezGalvan2017a_pU = [0.2; 1.8]
PerezGalvan2017a_x0(p) = [1.0; 0.0]
function PerezGalvan2017a_f(du, u, p, t)
    du[1] = -p[1]*u[1]
    du[2] = p[1]*u[1] - p[2]*u[2]
    return
end
PerezGalvan2017a_id = :PerezGalvan2017A
PerezGalvan2017a_desc = "First-order irreversible series reaction"
