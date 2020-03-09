# Example from Interval bounds on solutions of semi-explicit index-one DAEs. Part 2: computation
ScottC2013a_t0 = 0.0
ScottC2013a_tf = 0.4
ScottC2013a_pL = [0.5]
ScottC2013a_pU = [4.0]
ScottC2013a_x0(p) = [1.0]
function ScottC2013a_f(du, u, y, p, t)
    du[1] = -p[1]*u[1] - 0.1*y[1]
    return
end
function ScottC2013a_g(out, u, y, p, t)
    out[1] = y[1] - sin(p[1])/sqrt(y[1]) - 25.0*x[1]
    return
end
ScottC2013a_id = :ScottC2013a
ScottC2013a_desc = "DAE with Singularity"
