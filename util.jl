using MathOptInterface

function viability_solver(data::Instance, opt_tol::Float64=10^(-5), time_limit::Int64=7200)
    model = Model(Gurobi.Optimizer)

    m, n = size(data.C)
    null_matrix = zeros(m, n)

    @variable(model, X[1:m, 1:n])

    @objective(model, Min, 0)

    y = vec(sum(X, dims=2))

    @constraint(model, y .>= 0.75 * data.Q, base_name = "Minimum_production_")
    @constraint(model, y .<= data.Q, base_name = "Maximum_production_")

    z = vec(sum(X, dims=1))

    @constraint(model, z .>= data.D, base_name = "Minimum_demand_")

    @constraint(model, X .>= null_matrix, base_name = "Nonnegativity_")

    set_attribute(model, "OptimalityTol", opt_tol)

    set_optimizer_attribute(model, "TimeLimit", time_limit)

    set_optimizer_attribute(model, "LogToConsole", 0)

    # set_optimizer_attribute(inst.model, "LogFile", "gurobi_log.txt")

    optimize!(model)

    status = termination_status(model)
    if (status == MOI.OPTIMAL)
        X_star = [value(X[i,j]) for i in 1:m, j in 1:n]
        return X_star
    else
        throw(ErrorException("Model was not optimized successfully. Status Code: $status"))
    end
end

# function rhs_analysis(data::Instance, opt_tol::Float64=10^(-5), time_limit::Int64=7200)
#     model = Model(Gurobi.Optimizer)

#     m, n = size(data.C)
#     q = length(data.Q)
#     d = length(data.D)
#     println("Value of q: $(q)")
#     null_matrix = zeros(m, n)

#     @variable(model, X[1:m, 1:n])

#     @objective(model, Min, tr(data.C * X'))

#     y = vec(sum(X, dims=2))

#     # @constraint(model, y .>= 0.75 * data.Q, base_name = "Minimum_production_")
#     # @constraint(model, y .<= data.Q, base_name = "Maximum_production_")
#     for i in 1:q
#         con1 = @constraint(model, y[i] >= 0.75 * data.Q[i])
#         con2 = @constraint(model, y[i] <= data.Q[i])
#         set_name(con1, "Minimum_production_$i")
#         set_name(con2, "Maximum_production_$i")
#     end

#     z = vec(sum(X, dims=1))

#     # @constraint(model, z .>= data.D, base_name = "Minimum_demand_")
#     # for i in 1:d
#     #     @constraint(model, z[i] >= data.D[i], name = "Minimum_demand_$i")
#     # end
#     for i in 1:d
#         con3 = @constraint(model, z[i] >= data.D[i])
#         set_name(con3, "Minimum_demand_$i")
#     end

#     # @constraint(model, X .>= null_matrix, basename = "Nonnegativity_")
#     @constraint(model, X .>= 0)

#     set_attribute(model, "OptimalityTol", opt_tol)

#     set_optimizer_attribute(model, "TimeLimit", time_limit)

#     set_optimizer_attribute(model, "LogToConsole", 0)

#     # set_optimizer_attribute(inst.model, "LogFile", "gurobi_log.txt")

#     optimize!(model)

#     status = termination_status(model)
#     if (status == MOI.OPTIMAL)
#         rhs_range = Dict(
#             "Minimum_production" => [],
#             "Maximum_production" => [],
#             "Minimum_demand" => []
#         )
#         for i in 1:q
#             constr_ref = constraint_by_name(model, "Minimum_production_$(i)")
#             rhs_r = MOI.get(model, MOI.ConstraintDual(), constr_ref)
#             push!(rhs_range["Minimum_production"], rhs_r)
#             constr_ref = constraint_by_name(model, "Maximum_production_$(i)")
#             rhs_r = MOI.get(model, MOI.ConstraintDual(), constr_ref)
#             push!(rhs_range["Maximum_production"], rhs_r)
#         end
#         for i in 1:d
#             constr_ref = constraint_by_name(model, "Minimum_demand_$(i)")
#             rhs_r = MOI.get(model, MOI.ConstraintDual(), constr_ref)
#             push!(rhs_range["Minimum_demand"], rhs_r)
#         end
#         return rhs_range
#     else
#         throw(ErrorException("Model was not optimized successfully. Status Code: $status"))
#     end
# end

function rhs_analysis(data::Instance, opt_tol::Float64=10^(-5), time_limit::Int64=7200)
    model = Model(Gurobi.Optimizer)

    m, n = size(data.C)
    q = length(data.Q)
    d = length(data.D)
    null_matrix = zeros(m, n)
    constraints = Dict()

    @variable(model, X[1:m, 1:n])

    @objective(model, Min, tr(data.C * X'))

    y = vec(sum(X, dims=2))

    # @constraint(model, y .>= 0.75 * data.Q, base_name = "Minimum_production_")
    # @constraint(model, y .<= data.Q, base_name = "Maximum_production_")
    for i in 1:q
        con1 = @constraint(model, y[i] >= 0.75 * data.Q[i])
        con2 = @constraint(model, y[i] <= data.Q[i])
        set_name(con1, "Minimum_production_$i")
        set_name(con2, "Maximum_production_$i")
        constraints["Minimum_production_$i"] = con1
        constraints["Maximum_production_$i"] = con2
    end

    z = vec(sum(X, dims=1))

    # @constraint(model, z .>= data.D, base_name = "Minimum_demand_")
    # for i in 1:d
    #     @constraint(model, z[i] >= data.D[i], name = "Minimum_demand_$i")
    # end
    for i in 1:d
        con3 = @constraint(model, z[i] >= data.D[i])
        set_name(con3, "Minimum_demand_$i")
        constraints["Minimum_demand_$i"] = con3
    end

    # @constraint(model, X .>= null_matrix, basename = "Nonnegativity_")
    @constraint(model, X .>= 0)

    set_attribute(model, "OptimalityTol", opt_tol)

    set_optimizer_attribute(model, "TimeLimit", time_limit)

    set_optimizer_attribute(model, "LogToConsole", 0)

    # set_optimizer_attribute(inst.model, "LogFile", "gurobi_log.txt")

    optimize!(model)

    status = termination_status(model)
    if (status == MOI.OPTIMAL)
        sensitivity_report = lp_sensitivity_report(model)
        return sensitivity_report
    else
        throw(ErrorException("Model was not optimized successfully. Status Code: $status"))
    end
end

function dual_variables(data::Instance, opt_tol::Float64=10^(-5), time_limit::Int64=7200)
    model = Model(Gurobi.Optimizer)

    m, n = size(data.C)
    q = length(data.Q)
    d = length(data.D)
    null_matrix = zeros(m, n)
    constraints = Dict()

    @variable(model, X[1:m, 1:n])

    @objective(model, Min, tr(data.C * X'))

    y = vec(sum(X, dims=2))

    # @constraint(model, y .>= 0.75 * data.Q, base_name = "Minimum_production_")
    # @constraint(model, y .<= data.Q, base_name = "Maximum_production_")
    for i in 1:q
        con1 = @constraint(model, y[i] >= 0.75 * data.Q[i])
        con2 = @constraint(model, y[i] <= data.Q[i])
        set_name(con1, "Minimum_production_$i")
        set_name(con2, "Maximum_production_$i")
        constraints["Minimum_production_$i"] = con1
        constraints["Maximum_production_$i"] = con2
    end

    z = vec(sum(X, dims=1))

    # @constraint(model, z .>= data.D, base_name = "Minimum_demand_")
    # for i in 1:d
    #     @constraint(model, z[i] >= data.D[i], name = "Minimum_demand_$i")
    # end
    for i in 1:d
        con3 = @constraint(model, z[i] >= data.D[i])
        set_name(con3, "Minimum_demand_$i")
        constraints["Minimum_demand_$i"] = con3
    end

    # @constraint(model, X .>= null_matrix, basename = "Nonnegativity_")
    @constraint(model, X .>= 0)

    set_attribute(model, "OptimalityTol", opt_tol)

    set_optimizer_attribute(model, "TimeLimit", time_limit)

    set_optimizer_attribute(model, "LogToConsole", 0)

    # set_optimizer_attribute(inst.model, "LogFile", "gurobi_log.txt")

    optimize!(model)

    status = termination_status(model)
    if (status == MOI.OPTIMAL)
        dual_variables = Dict(
            "Minimum_production" => [],
            "Maximum_production" => [],
            "Minimum_demand" => []
        )
        for i in 1:q
            dual_var = dual(constraints["Minimum_production_$(i)"])
            push!(dual_variables["Minimum_production"], dual_var)
            dual_var = dual(constraints["Maximum_production_$(i)"])
            push!(dual_variables["Maximum_production"], dual_var)
        end
        for i in 1:d
            dual_var = dual(constraints["Minimum_demand_$(i)"])
            push!(dual_variables["Minimum_demand"], dual_var)
        end
        return dual_variables
    else
        throw(ErrorException("Model was not optimized successfully. Status Code: $status"))
    end
end