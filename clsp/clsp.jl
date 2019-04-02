###########################################################################################################
# Exemplo de implementacao do modelo de PI para o Problema do Dimensionamento de Lotes
#
# Modelo:
#
# \min \sum_{t=1}^{T} p_t x_t + f_t y_t + h_t s_t
# Subject to
# s_{0}, s_{T} = 0
# s_{t-1} + x_{t} = d_{t} + s_{t}, \forall t = 1, \dots, T
# x_t \leq M y_{t}, \forall t = 1, \dots, T
# y_t \in \{0, 1\}, \forall t = 1, \dots, T
# x_{t}, s{t} \geq 0, \forall t = 1, \dots, T
#
###########################################################################################################
push!(LOAD_PATH, "modules/")

using JuMP
using Coluna
using Gurobi

import Data
import ColGen

appfolder = dirname(@__FILE__)
inst = Data.readData("$appfolder/instTese")
(model, x, y, s) = ColGen.cg_clsp(inst)
optimize!(model)
