#!/usr/bin/env ruby 

require 'dfg_ilp'

g = DFG_ILP::GRAPH.new
g.IIR(4)
#g.dot(File.open("tmp.dot", "w") )
ilp = DFG_ILP::ILP.new(
	g, 
	ARGV[0] == nil||ARGV[0] == "nil" ? nil : ARGV[0].to_i,
	ARGV[1] == nil||ARGV[1] == "nil" ? false : true)
if(ARGV[2] == nil)
	r = ilp.compute(g, :cplex)
else
	r = ilp.compute(g, :gurobi)
end
ilp.vs(r[:sch], 0)
