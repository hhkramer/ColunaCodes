push!(LOAD_PATH, "modules/")

using JuMP
using Coluna
using Gurobi
using CPLEX

import Data
import Parameters
import Formulations
import RelaxAndFix
import ColGen

# Define instance file path
# instanceFile = "minhasinstancias/A000muchsmaller.dat"
#instanceFile = ARGS[1]

# Define formulation/approach
# form = ARGS[2]

# Read the parameters from command line
params = Parameters.readInputParameters(ARGS)

# Read instance data
inst = Data.readData(params.instName)

model = Model()

if params.method == "exact"
    if params.form == "std"
        Formulations.standardFormulation(inst, model, params)
    elseif params.form == "fl"
        Formulations.facilityLocationFormulation(inst, model, params)
    end
elseif params.method == "rf"
    RelaxAndFix.RFStandardFormulation(inst, model, params)
elseif params.method == "cg"
    appfolder = dirname(@__FILE__)
    data = read_dataGap("$appfolder/data/gapC-10-100.txt")
    (model, x, y, s, r) = ColGen.cg_mplsp(inst, model, params)
    optimize!(gap)
    # @test abs(JuMP.objective_value(gap) - 1402.0) < 1e-5
    # @test print_and_check_sol(data, gap, x)
end
