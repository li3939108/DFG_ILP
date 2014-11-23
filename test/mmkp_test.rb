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

iir4 = DFG_ILP::GRAPH.new
iir4.IIR(4)
iir4.ifactor

testcases = [arf]

testcases.each do |g|
	variance_bound = 30000
	print "\n", g.p[:name], "start", "\n------------------------\n"
	ilp = DFG_ILP::ILP.new(g, {:type => 'mmkp', :variance_bound => variance_bound, :q => 22})
	r = ilp.mmkp_compute(g, :cplex)
	$stderr.print  "energy:", r[:energy],  "\n"
	$stderr.print "var: ", r[:var].map{|var_slack| variance_bound - var_slack}, "\n"
	$stderr.print "er: ", [*0..g.p[:v].length - 1].select{|i| g.p[:PO][i] }.map{|po| r[:error][po] }.max
	sch = ilp.list_scheduler(r[:type])
	print "\n\n------------------\nresults: \n\n"
	sch[1].each{|arr|
		print arr != nil ? arr.map{|v| v.n}:nil, "\n"
	}
	print "\n\n", sch, "\n"
end
