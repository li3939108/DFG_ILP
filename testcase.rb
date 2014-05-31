#!/usr/bin/env ruby

require './DFG_ILP.rb'
g = DFG_ILP::GRAPH.new
g.IIR(4)
#g.dot(File.open("tmp.dot", "w") )
ilp = DFG_ILP::ILP.new(
	g, 
	ARGV[0] == nil||ARGV[0] == "nil" ? nil : ARGV[0].to_i,
	ARGV[1] == nil ? false : true)
		
r = ilp.compute(g, :lpsolve)
#r = ilp.compute(g, :cplex)
ilp.vs(r[:sch], 0)
