# Exothermic Batch Reactor
PerezGalvan2017c_t0 = 0.0
PerezGalvan2017c_tf = 60.0
PerezGalvan2017c_pL = [310.0; 290.0]
PerezGalvan2017c_pU = [410.0; 310.0]
PerezGalvan2017c_x0(p) = [0.0, p[1]]
function PerezGalvan2017c_f(du, u, p, t)
    du[1] =  0.022*(1.0-u[1])*exp(-6000/(8.314*u[2]))
    du[2] = 0.05*(p[2]-u[2]) - (-14000.0/6.0)*0.022*(1-u[1])*exp(-6000.0/(8.314*u[2]))
    return
end
PerezGalvan2017c_id = :PerezGalvan2017c
PerezGalvan2017c_desc = "Exothermic Batch Reactor"
