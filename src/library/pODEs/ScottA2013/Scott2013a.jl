# Example from Improved relaxations for the parametric solutionsof ODEs using differential inequalities
ScottA2013a_t0 = 0.0
ScottA2013a_tf = 2.0
ScottA2013a_pL = [-6.5;0.01]
ScottA2013a_pU = [1.0;0.05]
ScottA2013a_x0(p) = [1.0;0.5]
function ScottA2013a_f(du, u, p, t)
    du[1] = -(2.0 + sin(p[1]/3.0))*u[1]^2 + p[2]*u[1]*u[2]
    du[2] = sin(p[1]/3.0)*u[1]^2 - p[2]*u[1]*u[2]
    return
end
ScottA2013a_id = :ScottA2013a
ScottA2013a_desc = "Sinusodial Example 1"
