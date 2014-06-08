#!/usr/bin/env ruby
require 'dfg_ilp'

g = DFG_ILP::GRAPH.new
g.IIR(4)
#g.dot(File.open("tmp.dot", "w") )
ilp = DFG_ILP::ILP.new(
	g, 
	ARGV[0] == nil||ARGV[0] == "nil" ? nil : ARGV[0].to_i,
	ARGV[1] == nil ? false : true)
ret = ilp.ASAP
sch = ret.map.with_index{|t,i|
	{:id => i + 1,
	:op =>ilp.p[:v][i],
	:time => t,
	:delay => ilp.p[:d][ ilp.p[:v][i] ].min}	}
ilp.vs(sch)
ret = ilp.ALAP
sch = ret.map.with_index{|t,i|
	{:id => i + 1,
	:op =>ilp.p[:v][i],
	:time => t,
	:delay => ilp.p[:d][ ilp.p[:v][i] ].min}	}
ilp.vs(sch)
ret = ilp.M
print ret, "\n"
