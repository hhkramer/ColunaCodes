module ColGen

using JuMP
using Coluna
using Gurobi
using Data

export cg_clsp

function cg_clsp(inst::InstanceData)
    M = 1000000

    cg_params = Coluna.Params(use_restricted_master_heur = false,
                              apply_preprocessing = false,
                              search_strategy = Coluna.DepthFirst,
                              force_copy_names = true)

    clsp = Model(with_optimizer(Coluna.Optimizer, params = cg_params,
                                 master_factory = with_optimizer(Gurobi.Optimizer),
                                 pricing_factory = with_optimizer(Gurobi.Optimizer)),
                                 bridge_constraints=false)

    # Create variables
    @variable(clsp, x[i=1:inst.numItems,t=1:inst.numPer] >= 0)	# Producao
    @variable(clsp, y[i=1:inst.numItems,t=1:inst.numPer], Bin)	# Setup
    @variable(clsp, s[i=1:inst.numItems,t=1:inst.numPer] >= 0)	# Estoque

    # Create objective function
    @objective(clsp, Min, sum(inst.pc * x[i,t] + inst.sc[i] * y[i,t] + inst.hc[i] * s[i,t] for i=1:inst.numItems, t=1:inst.numPer))

    # Create capacity constraints
    @constraint(clsp, capConstr[t=1:inst.numPer], sum(inst.pt[i] * x[i,t] + inst.st[i] * y[i,t] for i=1:inst.numItems) <= inst.cap)

    # Create inventory balance constraints
    @constraint(clsp, iniBalConstr[i=1:inst.numItems,1], x[i,1] - s[i,1] == inst.dem[i,1])
    @constraint(clsp, balConstr[i=1:inst.numItems,t=2:inst.numPer], s[i,t-1] + x[i,t] - s[i,t] == inst.dem[i,t])

    # Create setup constraints
    @constraint(clsp, setupConstr[i=1:inst.numItems,t=1:inst.numPer], x[i,t] - (M * y[i,t]) <= 0)

    # setting Dantzig Wolfe composition: one subproblem per item
    function clsp_decomp_func(name, key)
     if name in [:iniBalConstr, :balConstr, :setupConstr, :x, :y, :s]
         return key[1]
     else
         return 0
     end
    end
    Coluna.set_dantzig_wolfe_decompostion(clsp, clsp_decomp_func)

    # setting pricing cardinality bounds
    card_bounds_dict = Dict(i => (0,1) for i in 1:inst.numItems)
    Coluna.set_dantzig_wolfe_cardinality_bounds(clsp, card_bounds_dict)

    return (clsp, x, y, s)

end

end
