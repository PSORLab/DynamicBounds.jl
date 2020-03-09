# Example from Interval bounds on solutions of semi-explicit index-one DAEs. Part 2: computation
ScottC2013g_t0 = 0.0
ScottC2013g_tf = 6.0

Ab = 6.87987
Bt = 1342.31
Bb = 1196.76
At = 6.95087
Cb = 219.161
Ct = 219.187
frac = 0.002
ScottC2013g_pL = [Ab*(1.0-frac); Bb*(1.0-frac); Cb*(1.0-frac); At*(1.0-frac); Bt*(1.0-frac);  Ct*(1.0-frac)]
ScottC2013g_pU = [Ab*(1.0+frac); Bb*(1.0+frac); Cb*(1.0+frac); At*(1.0+frac); Bt*(1.0+frac);  Ct*(1.0+frac)]
ScottC2013g_x0(p) = [1.0]
function ScottC2013g_f(du, u, y, p, t)
    du[1] = u[1] - y[1]
    return
end
function ScottC2013g_g(out, u, y, p, t)
    Ab = p[1]
    Bb = p[2]
    Cb = p[3]
    At = p[4]
    Bt = p[5]
    Ct = p[6]
    P = 759.81
    Pbsat = exp10(Ab - Bb/(T + Cb))
    Ptsat = exp10(At - Bt/(T + Ct))
    out[1] = u[1] + y[1] - 1.0
    out[2] = y[2] + y[3] - 1.0
    out[3] = P*y[2] - Pbsat*u[1]
    out[4] = P*y[3] - Ptsat*y[1]
    return
end
ScottC2013g_id = :ScottC2013g
ScottC2013g_desc = "Simple Distillation 6 Uncertain Parameters +/-0.1%"
