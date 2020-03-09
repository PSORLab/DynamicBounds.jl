# Example from "Bounds on the reachable sets of nonlinear control systems" Constant Temperature Profile
ScottB2013b_t0 = 0.0
ScottB2013b_tf = 0.04
k = [0.1; 0.033; 16.0; 5.0; 0.5; 0.3]
ScottB2013b_pL = k
ScottB2013b_pU = 10.0*k
ScottB2013b_x0(p) = [34; 20]

function ScottB2013b_f(du, u, p, t)

    R = 8.134
    A1 = 2400
    A2 = 8800
    E1 = 6.9*10^3
    E2 = 1.69*10^4

    du[1] = -p[1]*u[1]*u[2] + p[2]*u[3] + p[6]*u[6]
    du[2] = -p[1]*u[1]*u[2] + p[2]*u[3] + p[3]*u[3]
    du[3] = p[1]*u[1]*u[2] - p[2]*u[3] - p[3]*u[3]
    du[4] = p[3]*u[3] - p[4]*u[1]*u[6] + p[5]*u[6]
    du[5] = -p[4]*u[4]*u[5] + p[5]*u[6] + p[6]*u[6]
    du[6] = p[4]*u[4]*u[5] - p[5]*u[6] - p[6]*u[6]
    return
end
ScottB2013b_id = :ScottB2013b
ScottB2013b_desc = "3 Series Rxn Network"
