#! /usr/bin/env ruby

require 'dfg_ilp'
operation_parameters = {

	's' => {
		:type => ["approximate", "accurate"], 
		:u    => [1, 1], 
		:d    => [3, 3], 
		:g    => [50000, 142200],
		:p    => [300, 430],
		:err  => [Math::log(1 - 0.91), Math::log(1 - 0)] ,
		:variance  => [210000, 0],
	},
	'x' => {
		:type => ["approximate", "accurate"], 
		:u    => [1, 1], 
		:d    => [3, 3], 
		:g    => [50000, 142200],
		:p    => [300, 430],
		:err  => [Math::log(1 - 0.91), Math::log(1 - 0)] ,
		:variance  => [210000, 0],
	},
	'ALU' => {
		:type => ["32/8trun", "32/8appr", "32/4trun","accurate"], 
		:u    => [1, 1, 1, 1],
		:d    => [2, 2, 2, 2], 
		:g    => [48390, 38750, 55670,66780],
		:p    => [7,  4, 8, 10],
		:err  => [Math::log(1 - 0.99999), Math::log(1- 0.996), Math::log(1 - 0.91),Math::log(1 - 0)], 
		:variance  => [10905, 6833, 42, 0],
	},
	'+' => {
		:type => ["32/8trun", "32/8appr", "32/4trun","accurate"], 
		:u    => [1, 1, 1, 1],
		:d    => [2, 2, 2, 2], 
		:g    => [48390, 38750, 55670,66780],
		:p    => [7,  4, 8, 10],
		:err  => [Math::log(1 - 0.99999), Math::log(1- 0.996), Math::log(1 - 0.91),Math::log(1 - 0)], 
		:variance  => [10905, 6833, 42, 0],
	},
	'D' => {
		:type => ["accurate"],
		:u    => [Float::INFINITY],
		:d    => [1],
		:g    => [0],
		:p    => [0],
		:err  => [Math::log(1 - 0)] ,
		:variance  => [0],

	},
	'@' => {
		:type => ["accurate"],
		:u    => [Float::INFINITY],
		:d    => [1],
		:g    => [66780],
		:p    => [10],
		:err  => [Math::log(1 - 0)] ,
		:variance  => [0],
	},
	}



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
@p      = Hash[operation_parameters.map{|k,v| [k, v[:p] ]} ]

testcases.each do |g|
	variance_bound = 30000
	latency = ARGV[0].to_i
	scaling = 10
	print "\n", g.p[:name], "start", "\n------------------------\n"
	ilp = DFG_ILP::ILP.new(g, {:type => 'mmkp', :variance_bound => variance_bound, :q => latency, :operation_parameters => operation_parameters, :scaling => scaling})
	r = ilp.mmkp_compute(g, :cplex)
	$stderr.print  "energy:", r[:energy],  "\n"
	$stderr.print "var: ", r[:var].map{|var_slack| variance_bound - var_slack}, "\n"
	$stderr.print "er: ", [*0..g.p[:v].length - 1].select{|i| g.p[:PO][i] }.map{|po| r[:error][po] }.max
	sch = ilp.list_scheduler(r[:type])
	print "\n\n------------------\nresults: \n\n"
	sch[:time_slot].each{|arr|
		print arr != nil ? arr.map{|v| v.n}:nil, "\n"
	}
	static_energy = @p.map{|k,v|
		sch[:being_used][k].map.with_index{|arr,i|
			arr.length * v[i] 
		}.reduce(0, :+) * latency * scaling
	}.reduce(0, :+)
	print "energy: ", static_energy + r[:energy], "\n"
	print "\n\n", sch, "\n"
end
