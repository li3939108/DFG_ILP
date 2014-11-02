#! /usr/bin/env ruby

require 'dfg_ilp'

root_dir = "/home/me/DFG_ILP"

arf = DFG_ILP::Parser.new("#{root_dir}/test/dot/arf.dot").parse.to_DFG
arf.arf_AST
arf.ifactor



testcases = [arf]

testcases.each do |g|
	print "\n", g.p[:name], " start", "\n---------------------------\n"
	ilp = DFG_ILP::ILP.new(g, {:err_type => 'var', :q => ARGV[0].to_i, :variance_bound => ARGV[1].to_i}) 
	ret = ilp.ASAP
	print   "ASAP scheduling done, longest path length: ", ret[:latency], "\n"
	r = ilp.compute(g, :cplex)
	
	print "var: ", r[:var].map{|var_slack| ARGV[1].to_i - var_slack}, "\n"
	er_bound = r[:sch].select{|sch| g.p[:PO][sch[:id] - 1] }.map{|schedule| schedule[:error] }.max

	ilp.vs(r[:sch], 0)

	print 'er bound: ', 1 - Math::E**er_bound
	er_ilp = DFG_ILP::ILP.new(g, {:q => ARGV[0].to_i, :error_bound => er_bound}) 
	er_r = er_ilp.compute(g, :cplex)
	print "var: ", er_r[:var].map{|var| -var}, "\n"

	er_ilp.vs(er_r[:sch], 0)

	# all approximate	
	full_approximate_ilp = DFG_ILP::ILP.new(g, {:err_type => 'var', :q => ARGV[0].to_i, :variance_bound =>99999999 })
	fa_ret = full_approximate_ilp.compute(g, :cplex)
	print "var: ", fa_ret[:var].map{|var_slack| 99999999 - var_slack}, "\n"
	full_approximate_ilp.vs(fa_ret[:sch], 0)
	#accurate 
	accurate_ilp = DFG_ILP::ILP.new(g, {:err_type => 'var', :q => ARGV[0].to_i, :variance_bound => 0})
	a_ret = accurate_ilp.compute(g, :cplex)
	accurate_ilp.vs(a_ret[:sch], 0)
end
