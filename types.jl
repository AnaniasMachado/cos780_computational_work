struct Instance
    Q::Vector{Int}             # Production capacity
    D::Vector{Int}             # Demand
    C::Matrix{Float64}         # Transport cost
end