# Oil Shale Pyrolysis Problem # WAITING ON INTER LIBRARY LOAN FOR A & B Parameters
Singer2006_t0 = 0.0
Singer2006_tf = 10.0
Singer2006_pL = [0.0]
Singer2006_pU = [1.0]
Singer2006_x0(p) = [1.0; 0.0]
function Singer2006_f(du, u, p, t)
    k1 = a1*exp((-b1/R)/(689.5 + 50.0*p[1]))
    k2 = a2*exp((-b2/R)/(689.5 + 50.0*p[1]))
    k3 = a3*exp((-b3/R)/(689.5 + 50.0*p[1]))
    k4 = a4*exp((-b4/R)/(689.5 + 50.0*p[1]))
    k5 = a5*exp((-b5/R)/(689.5 + 50.0*p[1]))
    du[1] = -k1*u[1] - (k3 + k4 + k5)*u[1]*u[2]
    du[2] = k1*u[1] - k2*u[2] + k3*u[1]*u[2]
    return
end
Singer2006_id = :Singer2006
Singer2006_desc = "Oil Shale Pyrolysis"
