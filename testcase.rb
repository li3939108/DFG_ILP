require './DFG_ILP.rb'
g = DFG_ILP::GRAPH.new
g.IIR(4)
ilp = DFG_ILP::ILP.new(g, 20)
ilp.compute(g)
