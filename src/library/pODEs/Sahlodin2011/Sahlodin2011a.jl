# First-order irreversible series reaction
Sahlodin2011a_t0 = 0.0
Sahlodin2011a_tf = 1.0
Sahlodin2011a_pL = [-1.0]
Sahlodin2011a_pU = [1.0]
Sahlodin2011a_x0(p) = [9.0]
function Sahlodin2011a_f(du, u, p, t)
    du[1] = -u[1]^2 + p[1]
    return
end
Sahlodin2011a_id = :Sahlodin2011a
Sahlodin2011a_desc = "First-order irreversible series reaction"
