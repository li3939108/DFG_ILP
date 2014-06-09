#!/usr/bin/env ruby
require 'dfg_ilp'
root_dir = "/home/me/DFG_ILP"

g1 = DFG_ILP::Parser.new("#{root_dir}/test/dot/idct.dot").parse.to_DFG
g = DFG_ILP::GRAPH.new
g.IIR(4)
#g.dot(File.open("tmp.dot", "w") )
ilp = DFG_ILP::ILP.new(g)
ret = ilp.ASAP
sch = ret[:schedule].map.with_index{|t,i|
	{:id => i + 1,
	:op =>ilp.p[:v][i],
	:time => t,
	:delay => ilp.p[:d][ ilp.p[:v][i] ].min}	}
print "longest: ", ret[:latency], "\n"
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
