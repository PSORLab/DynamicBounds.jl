# Reactor Separator Model
PerezGalvan2017f_t0 = 0.0
PerezGalvan2017f_tf = 100.0
PerezGalvan2017f_pL = [0.0; 0.0]
PerezGalvan2017f_pU = [0.08; 0.16]
PerezGalvan2017f_x0(p) = [0.5; 0.0; 0.0; 0.0; p[1]; p[2]]
function PerezGalvan2017f_f(du, u, p, t)
    k = 0.06; xF0 = 0.0; D = 1.0; H = 63.33
    α = 7.5; B = 1.2; L = 1.704; F = 1.0
    V = pi*(H/4)*D^2    # THIS MAY BE INCORRECT...
    xF = (F*xF0 + B*u[2])/(F + B)
    y2 = α*u[2]/(1.0 + (α-1.0)*u[2])
    y3 = α*u[3]/(1.0 + (α-1.0)*u[3])
    y4 = α*u[4]/(1.0 + (α-1.0)*u[4])
    y5 = α*u[5]/(1.0 + (α-1.0)*u[5])
    du[1] = (F+B)*(xF - u[1])/H + k*u[1]*(1.0 - u[1])
    du[2] = (L + F + B)*u[3] - B*u[2] - V*y2
    du[3] = (L + F + B)*(u[4] - u[3]) + V*(y2 - y3)
    du[4] = (F+B)*u[1] + L*u[5] - (L + F + B)*u[4] +V*(y3 - y4)
    du[5] = L*(u[6] - u[5]) + V*(y4 - y5)
    du[6] = -(L + D)*u[6] + V*y5
    return
end
PerezGalvan2017f_id = :PerezGalvan2017f
PerezGalvan2017f_desc = "Reactor Separator Model"
