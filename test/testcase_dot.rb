#!/usr/bin/env ruby

require 'dfg_ilp'

root_dir = "/home/me/DFG_ILP"
g = DFG_ILP::Parser.new("#{root_dir}/test/dot/arf.dot").parse.to_DFG
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
