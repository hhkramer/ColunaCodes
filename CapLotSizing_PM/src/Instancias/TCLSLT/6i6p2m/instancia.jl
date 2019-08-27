# Como buscar a Instancia e declarar cada elemento.
instancia = readdlm("NBB00.dat")
# Declarar o Custo Unitario de Produção.
numItens = instancia[1,1]
numPer = instancia[1,2]
numMaqs = instancia[1,3]
cap = Array{Int}(numMaqs)
println("numero de itens (i): ",numItens)
println("numero de Periodos(j): ",numPer)
println("numero de Maquinas(k): ",numMaqs)

for k=1:numMaqs
    cap[k]=instancia[2+k,1]
end

# Lendo a Matriz de Custo de Estoque (matriz 1x6)
cest = Array{Float64}(numItens)
for i= 1:numItens
    cest[i] = instancia[2+numMaqs+i]/10
end

# Lendo a Matriz 4x6 de: coluna1(tempo de poducao), coluna2(tempo de setup), coluna3(custo de setup), coluna4(custo de producao)
tprod = Array{Float64}(numItens,numMaqs)
tsetup = Array{Float64}(numItens,numMaqs)
csetup = Array{Float64}(numItens,numMaqs)
cprod = Array{Float64}(numItens,numMaqs)

for k=1:numMaqs
    for i=1:numItens
        tprod[i,k]=instancia[2+numMaqs+k*numItens+i,1]
        tsetup[i,k]=instancia[2+numMaqs+k*numItens+i,2]
        csetup[i,k]=instancia[2+numMaqs+k*numItens+i,3]
        cprod[i,k]=instancia[2+numMaqs+k*numItens+i,4]/10
    end
end


demanda=Array{Int}(numItens,numPer)
for i=1:numItens
    for j=1:numPer
        if i<16
            demanda[i,j]=instancia[2+numMaqs+numItens+(numMaqs*numItens)+j,i]
        end
        if i>=16
            demanda[i,j]=instancia[2+numMaqs+numItens+(numMaqs*numItens)+numPer+j,i-15]
        end
    end
end

println("Custo de Estoque: ",cest)
println("Tempo de Produção: ",tprod)
println("Tempo de Setup: ",tsetup)
println("Custo de Setup: ",csetup)
println("Custo de Produção: ",cprod)
println("Demanda: ",demanda)

#MODELANDO O PROBLEMA CLASSICO:
using JuMP
using CPLEX
loteclassico = Model(solver = CplexSolver())
