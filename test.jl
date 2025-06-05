using MAT
using LinearAlgebra

include("types.jl")
include("solver.jl")

Q = [180, 200, 140, 80, 180]
D = [89, 95, 121, 101, 116, 181]
C = [4.50 5.09 4.33 5.96 1.96 7.30;
    3.33 4.33 3.38 1.53 5.95 4.01;
    3.02 2.61 1.61 4.44 2.36 4.60;
    2.43 2.37 2.54 4.13 3.20 4.88;
    6.42 4.83 3.39 4.40 7.44 2.92]

data = Instance(Q, D, C)

opt_tol = 10^(-5)
time_limit = 7200

X = gurobi_solver(data, opt_tol, time_limit)

println("Objetive value: $(tr(C * X'))")