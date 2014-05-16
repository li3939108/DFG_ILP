

require './DFG_ILP.rb'

a=[[-1, 1], [3,2], [2,3]]
op=[DFG_ILP::LE, DFG_ILP::LE, DFG_ILP::LE]
b=[1, 12, 12]
c=[0, 1]
min = false

DFG_ILP::ILP(a,op,b,c,min)
