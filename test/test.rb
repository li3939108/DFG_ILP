#! /usr/bin/env ruby

require 'dfg_ilp'

root_dir = "/home/me/DFG_ILP"

arf = DFG_ILP::Parser.new("#{root_dir}/test/dot/arf.dot").parse.to_DFG
arf.ifactor

iir4 = DFG_ILP::GRAPH.new
iir4.IIR(4)
iir4.ifactor

mm =  DFG_ILP::Parser.new("#{root_dir}/test/dot/mm.dot").parse.to_DFG
mm.ifactor

mv = DFG_ILP::Parser.new("#{root_dir}/test/dot/mv.dot").parse.to_DFG
mv.ifactor

pyr =  DFG_ILP::Parser.new("#{root_dir}/test/dot/pyr.dot").parse.to_DFG
pyr.ifactor


jbmp =  DFG_ILP::Parser.new("#{root_dir}/test/dot/jbmp.dot").parse.to_DFG
jbmp.ifactor


sds = DFG_ILP::Parser.new("#{root_dir}/test/dot/sds.dot").parse.to_DFG
sds.ifactor

testcase = [sds]
testset = [iir4, arf, mv, mm, pyr, jbmp, sds]

minLatency = {
	iir4 =>14, 
	arf => 11, 
	mv => 7, 
	mm => 11, 
	pyr => 8, 
	jbmp => 8, 
	sds => 17,
}


testset.each do |g|
	latency = minLatency[g] * 2
	variance_bound = 30000
	print "\n", g.p[:name], " start", "\n---------------------------\n"
	ilp = DFG_ILP::ILP.new(g, {:err_type => 'var', :q => latency, :variance_bound => variance_bound}) 
	ret = ilp.ASAP(:min)
	print   "ASAP scheduling done, longest path length: ", ret[:latency], "\n"
	r = ilp.compute(g, :cplex)
	
	print "var: ", r[:var].map{|var_slack| variance_bound - var_slack}, "\n"
	er_bound = r[:sch].select{|sch| g.p[:PO][sch[:id] - 1] }.map{|schedule| schedule[:error] }.max

	ilp.vs(r[:sch], 0)

	print 'er bound: ', 1 - Math::E**er_bound
	er_ilp = DFG_ILP::ILP.new(g, {:q => latency, :error_bound => er_bound}) 
	er_r = er_ilp.compute(g, :cplex)
	print "var: ", er_r[:var].map{|var| -var}, "\n"

	er_ilp.vs(er_r[:sch], 0)

	# all approximate	
	full_approximate_ilp = DFG_ILP::ILP.new(g, {:err_type => 'var', :q => latency, :variance_bound =>99999999 })
	fa_ret = full_approximate_ilp.compute(g, :cplex)
	print "var: ", fa_ret[:var].map{|var_slack| 99999999 - var_slack}, "\n"
	full_approximate_ilp.vs(fa_ret[:sch], 0)

	#accurate 
	accurate_ilp = DFG_ILP::ILP.new(g, {:err_type => 'var', :q => latency, :variance_bound => 0})
	a_ret = accurate_ilp.compute(g, :cplex)
	accurate_ilp.vs(a_ret[:sch], 0)
end
