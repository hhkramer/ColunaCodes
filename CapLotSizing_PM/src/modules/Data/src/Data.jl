module Data

using DelimitedFiles

struct InstanceData
    instName::String
    numItems::Int
    numMachines::Int
    numPer::Int
    cap
    pc
    sc
    hc
    pt
    st
    dem
end

export InstanceData, readInstance

function readInstance(instanceFile::String)
    # Read the data file as a matrix
    data = readdlm(instanceFile)

    numItems    = data[1,1]
    numPer      = data[1,2]
    numMachines = data[1,3]

    cap = Array{Int}(undef, numMachines)
    for k = 1:numMachines
        cap[k]=data[2+k,1]
    end

    hc = Array{Float64}(undef, numItems)
    for i = 1:numItems
        hc[i] = data[2+numMachines+i]/10
    end

    pt = Array{Float64}(undef, numItems,numMachines)
    st = Array{Float64}(undef, numItems,numMachines)
    sc = Array{Float64}(undef, numItems,numMachines)
    pc = Array{Float64}(undef, numItems,numMachines)

    for i=1:numItems
        for k=1:numMachines
            pt[i,k] = data[2+numMachines+k*numItems+i,1]
            st[i,k] = data[2+numMachines+k*numItems+i,2]
            sc[i,k] = data[2+numMachines+k*numItems+i,3]
            pc[i,k] = data[2+numMachines+k*numItems+i,4]/10
        end
    end

    dem = Array{Int}(undef, numItems,numPer)
    for i = 1:numItems
        for t = 1:numPer
            if i < 16
                dem[i,t] = data[2+numMachines+numItems+(numMachines*numItems)+t,i]
            end
            if i >= 16
                dem[i,t] = data[2+numMachines+numItems+(numMachines*numItems)+numPer+t,i-15]
            end
        end
    end

    instance = InstanceData(instanceFile, numItems, numMachines, numPer,
                            cap, pc, sc, hc, pt, st, dem)

    return instance

end

end
