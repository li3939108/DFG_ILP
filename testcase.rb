#!/usr/bin/env ruby

require './DFG_ILP.rb'
g = DFG_ILP::GRAPH.new
g.IIR(4)
ilp = DFG_ILP::ILP.new(g, ARGV[0].to_i)
r = ilp.compute(g)
DFG_ILP::GRAPH.vs(r[:sch], 0)
