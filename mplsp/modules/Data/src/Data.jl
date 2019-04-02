module Data

struct InstanceData
  NI::Int
  NT::Int
  NP::Int
  d
  pc
  sc
  hc
  tc
  C
  pt
  st
end

export InstanceData, readData

function readData(instanceFile)

	println("Running Data.readData with file $(instanceFile)")
	file = open(instanceFile)
	fileText = read(file, String)
	tokens = split(fileText) #tokens will have all the tokens of the input file in a single vector. We will get the input token by token

	# read the problem's dimensions NI, NT and NP
	NI = parse(Int,tokens[1])
	NT = parse(Int,tokens[2])
	NP = parse(Int,tokens[3])

	#resize data structures according to NI, NT and NP
	d = zeros(Int,NI,NP,NT) #demand NI x NP x NT
	pc = zeros(Float64,NI,NP) #production costs : NI x NP
	sc = zeros(Float64,NI,NP) #setup costs : NI x NP
	hc = zeros(Float64,NI,NP) #holding costs: NI x NP
	tc = zeros(Float64,NP,NP) # transfer costs NP x NP
	C = zeros(Int,NP) #plants capacities
	pt = zeros(Float64,NI,NP) #production time : NI x NP
	st = zeros(Float64,NI,NP) #setup time : NI x NP

	aux = 3 #aux will keep the position of the latest processed token
	#read plants' capacities
	for p in 1:NP
		aux = aux + 1
		C[p] = parse(Int,tokens[aux])
		#println("$(C[p])")
	end

	# read the production time, setup time, setup cost and production costs
	for p in 1:NP
		for i in 1:NI
			aux = aux+1
			pt[i,p] = parse(Float64,tokens[aux])
			st[i,p] = parse(Float64,tokens[aux+1])
			sc[i,p] = parse(Float64,tokens[aux+2])
			pc[i,p] = parse(Float64,tokens[aux+3])
			#println("pro plant $(p) item $(i): $(pt[i,p]) $(st[i,p]) $(sc[i,p]) $(pc[i,p])")
			aux = aux+3
		end
	end

	# read the inventory costs of the items (they are constants along the planning horizon)
	for p in 1:NP
		for i in 1:NI
			aux = aux+1
			hc[i,p] = parse(Float64,tokens[aux])
			#println("inv plant $(p) item $(i): $(hc[i,p]) ")
		end
	end
	#println("")

	# read the demands of items on the plants
	for t in 1:NT
		for p in 1:NP
			for i in 1:NI
				aux = aux+1
				d[i,p,t] = parse(Int, tokens[aux])
				#print("$(d[i,p,t]) ")
			end
		end
		#println("3 #############################")
		#println("")
	end

	# read the transfer costs
	for p1 in 1:NP-1
		for p2 in p1+1:NP
			aux = aux+1
			tc[p1,p2] = parse(Float64,tokens[aux])
			tc[p2,p1] = tc[p1,p2]
			#println("$(tc[p1,p2])")
		end
	end

	inst = InstanceData(NI, NT, NP, d, pc, sc, hc, tc, C, pt, st)

	return inst

end

end
