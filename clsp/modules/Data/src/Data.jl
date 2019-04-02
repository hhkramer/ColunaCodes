module Data

using DelimitedFiles

struct InstanceData
    numItems::Int
    numPer::Int
    cap::Int
    pc::Int
    sc
    hc
    pt
    st
    dem
end

export InstanceData, readData

function readData(instanceFile)
    instance = readdlm(instanceFile)

    n = instance[1, 1]  # Get number of items
    m = instance[1, 2]  # Get number of periods
    p = instance[2, 1]  # Get unitary production cost
    c = instance[3, 1]  # Get capacity

    a = Array{Float64}(undef, n)
    h = Array{Float64}(undef, n)
    b = Array{Float64}(undef, n)
    f = Array{Float64}(undef, n)
    for i=1:n
        a[i] = instance[3+i, 1]     # Get unitary resource consumptions
        h[i] = instance[3+i, 2]     # Get unitary inventory costs
        b[i] = instance[3+i, 3]     # Get setup resource consumptions
        f[i] = instance[3+i, 4]     # Get setup costs
    end

    d = Array{Int64}(undef, n, m)
    for i=1:n
        for t=1:m
            d[i, t] = instance[3+n+t, i]    # Get demands
        end
    end

    # Print instance data
    println("Instance data:",
            "\nNumber of items: ", n,
            "\nNumber of periods: ", m,
            "\nUnitary production cost: ", p,
            "\nSetup cost: ", f,
            "\nUnitary inventory holding cost: ", h,
            "\nUnitary resource consumptions: ", a,
            "\nSetup resource consumption: ", b,
            "\nResource availability (capacity): ", c,
            "\nDemands: ", d)

    instance = InstanceData(n, m, c, p, f, h, a, b, d)

end

end
