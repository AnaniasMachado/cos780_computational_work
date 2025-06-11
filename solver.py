import gurobipy as gp
from gurobipy import GRB
import numpy as np

def gurobi_solver(C, Q, D, opt_tol=1e-5, time_limit=7200):
    """
    Data input: the following attributes:
        - C: Transport cost (numpy array of shape m x n)
        - Q: Production capacity (numpy array of shape m)
        - D: Demand vector (numpy array of shape n)
    """

    m, n = C.shape
    q = Q.shape[0]
    d = D.shape[0]

    sensitivity_analysis = {
        "Minimum_production_lower": [],
        "Minimum_production_upper": [],
        "Maximum_production_lower": [],
        "Maximum_production_upper": [],
        "Minimum_demand_lower": [],
        "Minimum_demand_upper": [],
        "Optimal_basis_lower": [],
        "Optimal_basis_upper": []
    }

    dual_variables = {
        "Minimum_production": [],
        "Maximum_production": [],
        "Minimum_demand": []
    }

    # Create model
    model = gp.Model()

    # Define variables X[i, j] nonnegative
    X = model.addVars(m, n, lb=0, name="X")

    # Objective: minimize the sum tr(C * X')
    # Notice that tr(C * X') = sum_{i,j} C[i,j] * X[i,j]
    model.setObjective(
        gp.quicksum(C[i,j] * X[i,j] for i in range(m) for j in range(n)),
        GRB.MINIMIZE
    )

    # Constraint : y = sum over the columns
    # y_i = sum_j X[i,j]
    # y >= 0.75 * Q
    for i in range(m):
        model.addConstr(
            gp.quicksum(X[i,j] for j in range(n)) >= 0.75 * Q[i],
            name=f"Minimum_production_{i}"
        )
        # y <= Q
        model.addConstr(
            gp.quicksum(X[i,j] for j in range(n)) <= Q[i],
            name=f"Maximum_production_{i}"
        )

    # Constraint: z = sum over the rows
    # z_j = sum_i X[i,j]
    # z >= D
    for j in range(n):
        model.addConstr(
            gp.quicksum(X[i,j] for i in range(m)) >= D[j],
            name=f"Minimum_demand_{j}"
        )

    # Due to lb = 0, variables are already nonnegative
    # Gurobi configuration
    model.Params.TimeLimit = time_limit
    model.Params.OptimalityTol = opt_tol
    model.Params.OutputFlag = 0

    # Optimize
    model.optimize()

    # Checks optimization status
    if model.status == GRB.OPTIMAL:
        for i in range(0, q):
            constraint = model.getConstrByName(f"Minimum_production_{i}")
            sarhsup_value = constraint.getAttr("SARHSLow")
            sensitivity_analysis["Minimum_production_lower"].append(sarhsup_value)
            sarhsup_value = constraint.getAttr("SARHSUp")
            sensitivity_analysis["Minimum_production_upper"].append(sarhsup_value)
            dual_variables["Minimum_production"].append(constraint.Pi)

            constraint = model.getConstrByName(f"Maximum_production_{i}")
            sarhsup_value = constraint.getAttr("SARHSLow")
            sensitivity_analysis["Maximum_production_lower"].append(sarhsup_value)
            sarhsup_value = constraint.getAttr("SARHSUp")
            sensitivity_analysis["Maximum_production_upper"].append(sarhsup_value)
            dual_variables["Maximum_production"].append(constraint.Pi)
        for i in range(0, d):
            constraint = model.getConstrByName(f"Minimum_demand_{i}")
            sarhsup_value = constraint.getAttr("SARHSLow")
            sensitivity_analysis["Minimum_demand_lower"].append(sarhsup_value)
            sarhsup_value = constraint.getAttr("SARHSUp")
            sensitivity_analysis["Minimum_demand_upper"].append(sarhsup_value)
            dual_variables["Minimum_demand"].append(constraint.Pi)
        sensitivity_analysis["Optimal_basis_lower"].append(np.array([[X[i,j].SAObjLow for j in range(n)] for i in range(m)]))
        sensitivity_analysis["Optimal_basis_upper"].append(np.array([[X[i,j].SAObjUp for j in range(n)] for i in range(m)]))
        X_star = np.array([[X[i,j].X for j in range(n)] for i in range(m)])
        return X_star, sensitivity_analysis, dual_variables
    else:
        raise RuntimeError(f"Model was not optimized successfully. Status: {model.status}")