module Model

using JuMP
using BlockDecomposition
using Coluna
using Data

export cg_clsppm

function cg_clsppm(data::InstanceData, optimizer)

    clsppm = BlockModel(optimizer, bridge_constraints=false)

    @axis(NI, 1:data.numItems)
    NT = 1:data.numPer
    NTT = 2:data.numPer
    NM = 1:data.numMachines

    # Create variables
    @variable(clsppm, x[i in NI, t in NT, j in NM] >= 0)
    @variable(clsppm, s[i in NI, t in NT] >= 0)
    @variable(clsppm, y[i in NI, t in NT, j in NM], Bin)

    #Create Objective function
    @objective(clsppm, Min,
               sum(data.sc[i,j]*y[i,t,j] + data.pc[i,j]*x[i,t,j] + data.hc[i]*s[i,t] for i in NI, t in NT, j in NM))

    # Create inventory balance constraints
    @constraint(clsppm, iniBalConstr[i in NI],
                sum(x[i,1,j] for j in NM) == data.dem[i,1] + s[i,1])

    @constraint(clsppm, balConstr[i in NI, t in NTT],
                s[i,t-1] + sum(x[i,t,j] for j in NM) ==  data.dem[i,t] + s[i,t] )

    # Create capacity constraints
    @constraint(clsppm, capConstr[t in NT, j in NM],
                sum(data.st[i,j] * y[i,t,j] + data.pt[i,j] * x[i,t,j] for i in NI) <= data.cap[j])

    # println(lote)

    # Compute, for each item, the sum of demands from the begining of the horizon to a given period t
    sumDem = Array{Int}(undef, data.numItems, data.numPer)
    for i = 1:data.numItems
        for t = 1:data.numPer
            sumDem[i,t]= sum(data.dem[i,k] for k=t:data.numPer)
        end
    end

    # Create disjunctive setup constraints
    @constraint(clsppm, setupConstr[i in NI, t in NT, j in NM],
                x[i,t,j] <= min((data.cap[j] - data.st[i,j]) / data.pt[i,j], sumDem[i,t]) * y[i,t,j])

    @dantzig_wolfe_decomposition(clsppm, dec, NI)

    return clsppm, x, y, s, dec

end

end #module
