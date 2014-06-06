#!/usr/bin/env ruby

require './DFG_ILP.rb'
g = DFG_ILP::GRAPH.new
g.IIR(4)
#g.dot(File.open("tmp.dot", "w") )
ilp = DFG_ILP::ILP.new(
	g, 
	ARGV[0] == nil||ARGV[0] == "nil" ? nil : ARGV[0].to_i,
	ARGV[1] == nil ? false : true,
	{'+' => [9999, 9999],         'x' => [9999,9999],          'D' => [9999]})
		
r = ilp.compute(g)
DFG_ILP::GRAPH.vs(r[:sch], 0)
