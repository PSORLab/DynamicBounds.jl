# Example from Interval bounds on solutions of semi-explicit index-one DAEs. Part 2: computation
ScottC2013b_t0 = 0.0
ScottC2013b_tf = 6.0

Ab = 6.87987
Bt = 1342.31
ScottC2013b_pL = [Ab*(1.0-0.002);Bt*(1.0-0.002)]
ScottC2013b_pU = [Ab*(1.0+0.002);Bt*(1.0+0.002)]
ScottC2013b_x0(p) = [1.0]
function ScottC2013b_f(du, u, y, p, t)
    du[1] = u[1] - y[1]
    return
end
function ScottC2013b_g(out, u, y, p, t)
    Ab = p[1]
    Bb = 1196.76
    Cb = 219.161
    At = 6.95087
    Bt = p[2]
    Ct = 219.187
    P = 759.81
    Pbsat = exp10(Ab - Bb/(T + Cb))
    Ptsat = exp10(At - Bt/(T + Ct))
    out[1] = u[1] + y[1] - 1.0
    out[2] = y[2] + y[3] - 1.0
    out[3] = P*y[2] - Pbsat*u[1]
    out[4] = P*y[3] - Ptsat*y[1]
    return
end
ScottC2013b_id = :ScottC2013b
ScottC2013b_desc = "Simple Distillation 2 Uncertain Parameters +/-0.2%"
