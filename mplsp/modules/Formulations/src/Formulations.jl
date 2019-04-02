module Formulations

using JuMP
using Gurobi
using CPLEX
using Data
using Parameters

mutable struct stdFormVars
	x
	y
	s
	r
end

export standardFormulation, stdFormVars

function standardFormulation(inst::InstanceData, model, params::ParameterData)
	println("Running Formulations.standardFormulation")
	if params.solver == "Gurobi"
		env = Gurobi.Env()
		# model = Model(solver=GurobiSolver(TimeLimit=params.maxtime,MIPGap=0.000001))
		setsolver(model, GurobiSolver())
		setparams!(env, TimeLimit=params.maxtime, MIPGap=0.000001)
	elseif params.solver == "Cplex"
		env = Cplex.Env()
		#model = Model(solver=CplexSolver(CPX_PARAM_MIPDISPLAY=1, CPX_PARAM_MIPINTERVAL=1))
		# model = Model(solver=CplexSolver(CPX_PARAM_EPGAP=0.000001,CPX_PARAM_TILIM=params.maxtime))
		setsolver(model, CplexSolver())
		setparams!(env, CPX_PARAM_TILIM=params.maxtime, CPX_PARAM_EPGAP=0.000001)
	else
		println("No solver selected")
		return 0
	end

	### Defining variables ###
	@variable(model,0 <= x[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT] <= sum(inst.d[i,p1,k] for p1=1:inst.NP, k=t:inst.NT))
	@variable(model, y[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT], Bin)
	@variable(model,0 <= s[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT] <= sum(inst.d[i,p1,k] for p1=1:inst.NP, k=t:inst.NT))
	@variable(model,0 <= r[i=1:inst.NI,p1=1:inst.NP, p2=1:inst.NP, t=1:inst.NT; p1!= p2] <= sum(inst.d[i,p1,k] for p1=1:inst.NP, k=t:inst.NT))

	### Objective function ###
	@objective(model, Min,
			   sum(x[i,p,t]*inst.pc[i,p]+ y[i,p,t]*inst.sc[i,p] + s[i,p,t]*inst.hc[i,p] for i=1:inst.NI, p=1:inst.NP, t=1:inst.NT)
			   + sum(r[i,p1,p2,t]*inst.tc[p1,p2] for i=1:inst.NI, p1=1:inst.NP, p2=1:inst.NP, t=1:inst.NT if p1!=p2))
	#@objective(model, Min, sum(x[i,p,t]*pc[i,p]+y[i,p,t]*sc[i,p] for i=1:NI,p=1:NP,t=1:NT)  )

	### Balance constraints ###
	@constraint(model,
				balance1[i=1:inst.NI,p=1:inst.NP],
				x[i,p,1] + sum(r[i,p1,p,1] - r[i,p,p1,1]  for p1 in 1:inst.NP if p1 != p) == inst.d[i,p,1] + s[i,p,1])
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

	writeLP(model,"modelo.lp",genericnames=false)

	status = solve(model)
#	for i in 1:NI
#		for p in 1:NP
#			for t in 1:NT
#				if getvalue(y[i,p,t])> 0.00000001
#					println("y[$(i),$(p),$(t)] = $(getvalue(y[i,p,t])), cost $(inst.sc[i,p])")
#				end
#				if getvalue(x[i,p,t])> 0.00000001
#					println("x[$(i),$(p),$(t)] = $(getvalue(x[i,p,t])), cost $(inst.pc[i,p])")
#				end
#				if getvalue(s[i,p,t])> 0.00000001
#					println("s[$(i),$(p),$(t)] = $(getvalue(s[i,p,t])), cost $(inst.hc[i,p])")
#				end
#				println("")
#			end
#		end
#	end
#	for i in 1:NI
#		for p1 in 1:NP
#			for p2 in 1:NP
#				for t in 1:NT
#					if getvalue(r[i,p1,p2,t]) > 0.00000001
#						println("r[$(i),$(p1),$(p2),$(t)] = $(getvalue(r[i,p1,p2,t])), cost $(inst.tc[p1,p2])")
#					end
#				end
#			end
#		end
#	end

end

function facilityLocationFormulation(inst::InstanceData, model, params::ParameterData)
	println("Running Formulations.facilityLocationFormulation")
	if params.solver == "Gurobi"
		env = Gurobi.Env()
		model = Model(solver=GurobiSolver(TimeLimit=params.maxtime,MIPGap=0.000001))
	elseif solver == "Cplex"
		#env = Cplex.Env()
		#model = Model(solver=CplexSolver(CPX_PARAM_MIPDISPLAY=1, CPX_PARAM_MIPINTERVAL=1))
		model = Model(solver=CplexSolver(CPX_PARAM_EPGAP=0.000001,CPX_PARAM_TILIM=params.maxtime))

	else
		println("No solver selected")
		return 0
	end

	CX = zeros(Float64,inst.NI,inst.NP,inst.NT,inst.NP,inst.NT) #new calculated costs

	for i in 1:inst.NI
		for p in 1:inst.NP
			for t in 1:inst.NT
				for k in 1:inst.NP
					for u in t:inst.NT
						minC = (u-t)*inst.hc[i,1] + inst.tc[p,1] + inst.tc[1,k]
						for p2 in 2:inst.NP
							if (u-t)*inst.hc[i,p2] + inst.tc[p,p2] + inst.tc[p2,k] < minC
								minC = (u-t)*inst.hc[i,p2] + inst.tc[p,p2] + inst.tc[p2,k]
							end
						end
						CX[i,p,t,k,u] = minC + inst.pc[i,p]
						#CX[i,p,t,k,u] = inst.pc[i,p]
					end
				end
			end
		end
	end


	### Defining variables ###
	@variable(model,0 <= X[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT,k=1:inst.NP,u=t:inst.NT] <= inst.d[i,k,u], Int)
	@variable(model,0 <= y[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT] <= 1, Int)


	### Objective function ###
	@objective(model, Min, sum(y[i,p,t]*inst.sc[i,p] for i=1:inst.NI, p=1:inst.NP, t=1:inst.NT) + sum(X[i,p,t,k,u]*CX[i,p,t,k,u] for i=1:inst.NI, p=1:inst.NP, t=1:inst.NT,k=1:inst.NP,u=t:inst.NT))

	### Production quantities ###
	@constraint(model, satisfy[i=1:inst.NI,k=1:inst.NP,u=1:inst.NT], sum(X[i,p,t,k,u] for p=1:inst.NP, t=1:u) == inst.d[i,k,u])

	### Setup constraints ###
	#@constraint(model, setup[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT,k=1:inst.NP,u=t:inst.NT], X[i,p,t,k,u] <= inst.d[i,k,u]*y[i,p,t])
	@constraint(model, setup[i=1:inst.NI,p=1:inst.NP,t=1:inst.NT,k=1:inst.NP,u=t:inst.NT], X[i,p,t,k,u] <= min(floor((inst.C[p]-inst.st[i,p])/inst.pt[i,p]) ,inst.d[i,k,u])*y[i,p,t] )

	### Capacity constraints ###
	@constraint(model,capacity[p=1:inst.NP,t=1:inst.NT], sum(inst.st[i,p]*y[i,p,t] for i in 1:inst.NI) + sum(inst.pt[i,p]*X[i,p,t,k,u] for i=1:inst.NI,k=1:inst.NP,u=t:inst.NT) <= inst.C[p])

	status = solve(model)

	for i in 1:inst.NI
		for p in 1:inst.NP
			for t in 1:inst.NT
				if getvalue(y[i,p,t])> 0.00000001
					println("y[$(i),$(p),$(t)] = $(getvalue(y[i,p,t])), unit cost $(inst.sc[i,p])")
				end
				for k in 1:inst.NP
					for u in t:inst.NT
						if getvalue(X[i,p,t,k,u]) > 0.00000001
							println("X[$(i),$(p),$(t),$(k),$(u)] = $(getvalue(X[i,p,t,k,u])), unit cost $(CX[i,p,t,k,u])")
						end
					end
				end
				println("")
			end
		end
	end

end

end
