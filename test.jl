using MAT
using LinearAlgebra

include("types.jl")
include("solver.jl")
include("util.jl")

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
# X = viability_solver(data, opt_tol, time_limit)

println("Objetive value: $(tr(C * X'))")

println("Matrix X: $(X)")

sensitivity_report = rhs_analysis(data, opt_tol, time_limit)

q = length(Q)
d = length(D)

rhs_range = Dict(
    "Minimum_production_lower" => [],
    "Minimum_production_upper" => [],
    "Maximum_production_lower" => [],
    "Maximum_production_upper" => [],
    "Minimum_demand_lower" => [],
    "Minimum_demand_upper" => []
)

for (ref, (lower, upper)) in sensitivity_report.rhs
    ref_str = string(ref)
    for i in 1:q
        if occursin("Minimum_production_$(i)", ref_str)
            push!(rhs_range["Minimum_production_lower"], lower)
            push!(rhs_range["Minimum_production_upper"], upper)
        elseif occursin("Maximum_production_$(i)", ref_str)
            push!(rhs_range["Maximum_production_lower"], lower)
            push!(rhs_range["Maximum_production_upper"], upper)
        end
    end
    for i in 1:d
        if occursin("Minimum_demand_$(i)", ref_str)
            push!(rhs_range["Minimum_demand_lower"], lower)
            push!(rhs_range["Minimum_demand_upper"], upper)
        end
    end
end

println("Minimum_production_lower")
println(rhs_range["Minimum_production_lower"])
println("Minimum_production_upper")
println(rhs_range["Minimum_production_upper"])
println("Maximum_production_lower")
println(rhs_range["Maximum_production_lower"])
println("Maximum_production_upper")
println(rhs_range["Maximum_production_upper"])
println("Minimum_demand_lower")
println(rhs_range["Minimum_demand_lower"])
println("Minimum_demand_upper")
println(rhs_range["Minimum_demand_upper"])

dual_vars = dual_variables(data, opt_tol, time_limit)

println("Minimum_production: $(dual_vars["Minimum_production"])")
println("Maximum_production: $(dual_vars["Maximum_production"])")
println("Minimum_demand: $(dual_vars["Minimum_demand"])")