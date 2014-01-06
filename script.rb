require './DFG_ILP.rb'
g=DFG_ILP::GRAPH.new()
g.IIR(5)
DFG_ILP::ILP.new(g)
