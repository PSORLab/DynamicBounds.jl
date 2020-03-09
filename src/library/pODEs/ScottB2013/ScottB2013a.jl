# Example from "Bounds on the reachable sets of nonlinear control systems" Constant Temperature Profile
ScottB2013a_t0 = 0.0
ScottB2013a_tf = 0.08
ScottB2013a_pL = [420.0]
ScottB2013a_pU = [480.0]
ScottB2013a_x0(p) = [1.5; 0.5; 0.0]

function ScottB2013a_f(du, u, p, t)

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
ScottB2013a_id = :ScottB2013a
ScottB2013a_desc = "3 Series Rxn Network"
