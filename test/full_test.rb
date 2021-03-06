#! /usr/bin/env ruby

require 'dfg_ilp'

root_dir = "/home/me/DFG_ILP"

sds = DFG_ILP::Parser.new("#{root_dir}/test/dot/sds.dot").parse.to_DFG
jbmp =  DFG_ILP::Parser.new("#{root_dir}/test/dot/jbmp.dot").parse.to_DFG
pyr =  DFG_ILP::Parser.new("#{root_dir}/test/dot/pyr.dot").parse.to_DFG
jfdct = DFG_ILP::Parser.new("#{root_dir}/test/dot/jfdct.dot").parse.to_DFG
mm =  DFG_ILP::Parser.new("#{root_dir}/test/dot/mm.dot").parse.to_DFG
mv = DFG_ILP::Parser.new("#{root_dir}/test/dot/mv.dot").parse.to_DFG
invmat = DFG_ILP::Parser.new("#{root_dir}/test/dot/invmat.dot").parse.to_DFG
midct = DFG_ILP::Parser.new("#{root_dir}/test/dot/midct.dot").parse.to_DFG

arf = DFG_ILP::Parser.new("#{root_dir}/test/dot/arf.dot").parse.to_DFG
arf.arf_AST
arf.ifactor

vertex = ['x', 'x', 'x', 'x', 'x', 'x', '+', '+', '+', '+', '+']
edge = [[6, 0], [6,1], [7,6], [7,2],[8,7], [8,3], [9,8], [9,4], [10,9], [10,5] ]
fir = DFG_ILP::GRAPH.new({:e => edge, :v => vertex, :name => 'fir5'})
fir.ifactor


iir4 = DFG_ILP::GRAPH.new
iir4.IIR(4)
testcases = [fir]
fullset = [iir4, arf, midct, mv, mm, jfdct, pyr, jbmp, sds]
testset1 = [iir4, arf, mv, mm, pyr, jbmp, sds]

testcases.each do |g|
	print "\n", g.p[:name], " start", "\n---------------------------\n"
	ilp = DFG_ILP::ILP.new(g, {:q => ARGV[0].to_i, :error_bound => Math::log(1-1)}) 
	ret = ilp.ASAP
	print   "ASAP scheduling done, longest path length: ", ret[:latency], "\n"
	r = ilp.compute(g, :cplex)
	ilp.vs(r[:sch], 0) 
end
