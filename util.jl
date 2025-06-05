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