module ColGen

using JuMP
using Coluna
using Gurobi
using CPLEX
using Data

export cg_mlsp

function cg_mlsp(inst::InstanceData, model, params::ParameterData)
    cg_params = Coluna.Params(use_restricted_master_heur = false,
                              apply_preprocessing = false,
                              search_strategy = Coluna.DepthFirst,
                              force_copy_names = true)

    model = Model(with_optimizer(Coluna.Optimizer, params = cg_params,
                                 master_factory = with_optimizer(GLPK.Optimizer),
                                 pricing_factory = with_optimizer(GLPK.Optimizer)),
                                 bridge_constraints=false)

	### Defining variables ###
	@variable(model,0 <= x[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT] <= sum(inst.d[i,p1,k] for p1=1:inst.NP, k=t:inst.NT))
	@variable(model, y[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT], Bin)
	@variable(model,0 <= s[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT] <= sum(inst.d[i,p1,k] for p1=1:inst.NP, k=t:inst.NT))
	@variable(model,0 <= r[i=1:inst.NI,p1=1:inst.NP, p2=1:inst.NP, t=1:inst.NT; p1!= p2] <= sum(inst.d[i,p1,k] for p1=1:inst.NP, k=t:inst.NT))

	### Objective function ###
	@objective(model, Min,
			   sum(x[i,p,t]*inst.pc[i,p]+ y[i,p,t]*inst.sc[i,p] + s[i,p,t]*inst.hc[i,p] for i=1:inst.NI, p=1:inst.NP, t=1:inst.NT)
			   + sum(r[i,p1,p2,t]*inst.tc[p1,p2] for i=1:inst.NI, p1=1:inst.NP, p2=1:inst.NP, t=1:inst.NT if p1!=p2))

	### Balance constraints ###
	@constraint(model,
				balance1[i=1:inst.NI,p=1:inst.NP],
				x[i,p,1] + sum(r[i,p1,p,1] - r[i,p,p1,1] for p1 in 1:inst.NP if p1 != p) == inst.d[i,p,1] + s[i,p,1])
	@constraint(model,
				balance[i=1:inst.NI,p=1:inst.NP,t=2:inst.NT],
				s[i,p,t-1] + x[i,p,t] + sum(r[i,p1,p,t] - r[i,p,p1,t] for p1 in 1:inst.NP if p1 != p) == inst.d[i,p,t] + s[i,p,t])

	### Setup constraints ###
	#@constraint(model, setup[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT], x[i,p,t] <= sum(inst.d[i,p1,k] for p1 in 1:inst.NP, k in t:inst.NT)*y[i,p,t])
	@constraint(model,
				setup[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT],
				x[i,p,t] <= min(floor((inst.C[p]-inst.st[i,p])/inst.pt[i,p]) ,sum(inst.d[i,p1,k] for p1 in 1:inst.NP, k in t:inst.NT))*y[i,p,t])

	### Capacity constraints ###
	@constraint(model,
				capacity[p=1:inst.NP,t=1:inst.NT],
				sum(inst.st[i,p]*y[i,p,t]+inst.pt[i,p]*x[i,p,t] for i in 1:inst.NI) <= inst.C[p])

	# setting Dantzig Wolfe composition: one subproblem per item
    function mplsp_decomp_func(name, key)
        if name in [:balance1, :balance, :setup, :x, :y, :s, :r]
            return key[1]
        else
            return 0
        end
    end
    Coluna.set_dantzig_wolfe_decompostion(model, mplsp_decomp_func)

    # setting pricing cardinality bounds
    card_bounds_dict = Dict(m => (0,1) for i in 1:inst.NI)
    Coluna.set_dantzig_wolfe_cardinality_bounds(model, card_bounds_dict)

	return (model, x, y, s, r)
end


end
