#!/usr/bin/env ruby
require 'dfg_ilp'
root_dir = "/home/me/DFG_ILP"

mm =  DFG_ILP::Parser.new("#{root_dir}/test/dot/mm.dot").parse.to_DFG
mv = DFG_ILP::Parser.new("#{root_dir}/test/dot/mv.dot").parse.to_DFG
invmat = DFG_ILP::Parser.new("#{root_dir}/test/dot/invmat.dot").parse.to_DFG
idct = DFG_ILP::Parser.new("#{root_dir}/test/dot/idct.dot").parse.to_DFG
arf = DFG_ILP::Parser.new("#{root_dir}/test/dot/arf.dot").parse.to_DFG
iir4 = DFG_ILP::GRAPH.new
iir4.IIR(4)

ilp = DFG_ILP::ILP.new(mm)
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
