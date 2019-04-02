module Parameters

struct ParameterData
    instName::String
    method::String ### exact, rf, rffo
    form::String ## std, fl
    solver::String
    maxtime::Int
end


export ParameterData,readInputParameters


function readInputParameters(ARGS)

    println("Running Parameters.readInputParameters")

    instName="instances/NBA01266_4.dat"
    method="exact"
    form="std"
    solver = "Gurobi"
    maxtime = 180

    for param in 1:length(ARGS)
        if ARGS[param] == "--method"
            method = ARGS[param+1]
            param += 1
        elseif ARGS[param] == "--inst"
            instName = ARGS[param+1]
            param += 1
        elseif ARGS[param] == "--form"
            form = ARGS[param+1]
            param += 1
        elseif ARGS[param] == "--solver"
            solver = ARGS[param+1]
            param += 1
        elseif ARGS[param] == "--maxtime"
            maxtime = parse(Int,ARGS[param+1])
            param += 1
        end
    end

    params = ParameterData(instName,method,form,solver,maxtime)

    return params

end ### end readInputParameters


end ### end module
