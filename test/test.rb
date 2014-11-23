#! /usr/bin/env ruby

require 'dfg_ilp'

operation_parameters1 = {

	's' => {
		:type => ["approximate", "accurate"],
		:u    => [1,1],
		:d    => [2,3],
		:g    => [40930, 74995],
		:p    => [50, 45],
		:err  => [Math::log(1 - 0.91), Math::log(1 - 0), ],
		:variance  => [77, 0],
	},
	'x' => {
		:type => ["approximate", "accurate"], 
		:u    => [1, 1], 
		:d    => [2, 3], 
		:g    => [40930, 74995],
		:p    => [50, 45],
		:err  => [Math::log(1 - 0.91), Math::log(1 - 0)] ,
		:variance  => [77, 0],
	},
	'ALU' => {
		:type => ["approximate", "accurate"], 
		:u    => [1, 1],
		:d    => [1, 2], 
		:g    => [4705, 6050],
		:p    => [3, 4],
		:err  => [Math::log(1 - 0.91),Math::log(1 - 0)], 
		:variance  => [4474, 0],
	},
	'+' => {
		:type => ["approximate", "accurate"], 
		:u    => [1, 1],
		:d    => [1, 2], 
		:g    => [4705, 6050],
		:p    => [3 , 4],
		:err  => [Math::log(1 - 0.91),Math::log(1 - 0)] ,
		:variance  => [4474, 0],
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
		:g    => [6050],
		:p    => [4],
		:err  => [Math::log(1 - 0)] ,
		:variance  => [0],
	},
	}

	

root_dir = "/home/me/DFG_ILP"

arf = DFG_ILP::Parser.new("#{root_dir}/test/dot/arf.dot").parse.to_DFG
arf.ifactor
$stderr.print arf.p[:adj].map{|v| [v.n, v.rand_number]}

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

testcase = [arf]
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


testcase.each do |g|
	latency = minLatency[g] * 2
	variance_bound = 30000
	$stderr.print "\n", g.p[:name], " start", "\n---------------------------\n"
	# variance based ILP
	ilp = DFG_ILP::ILP.new(g, {
		:err_type => 'var', 
		:q => latency, 
		:variance_bound => variance_bound, 
		:operation_parameters => operation_parameters1} )
	ret = ilp.ASAP(:min)
	$stderr.print   "ASAP scheduling done, longest path length: ", ret[:latency], "\n"
	r = ilp.compute(g, :cplex)
	
	$stderr.print "var: ", r[:var].map{|var_slack| variance_bound - var_slack}, "\n"
	max_var = r[:var].map{|var_slack| variance_bound - var_slack}.max
	er_bound = r[:sch].select{|sch| g.p[:PO][sch[:id] - 1] }.map{|schedule| schedule[:error] }.max
	
	$stdout.print "#{g.p[:name]}&\t#{r[:opt]}&\t#{max_var}&\t#{1 - Math::E**er_bound}"
	 
	ilp.vs(r[:sch], 0)
	# error rate based ILP
	$stderr.print 'er bound: ', 1 - Math::E**er_bound
	er_ilp = DFG_ILP::ILP.new(g, {
		:q => latency, 
		:error_bound => er_bound,
		:operation_parameters => operation_parameters1}) 
	er_r = er_ilp.compute(g, :cplex)
	$stderr.print "var: ", er_r[:var].map{|var| -var}, "\n"
	max_var = er_r[:var].map{|var| -var}.max

	$stdout.print "&\t#{er_r[:opt]}&\t#{max_var}&\t#{1 - Math::E**er_bound}"

	er_ilp.vs(er_r[:sch], 0)

	# all approximate	
	full_approximate_ilp = DFG_ILP::ILP.new(g, {
		:err_type => 'var', 
		:q => latency, 
		:variance_bound =>99999999,
		:operation_parameters => operation_parameters1 })
	fa_ret = full_approximate_ilp.compute(g, :cplex)
	$stderr.print "var: ", fa_ret[:var].map{|var_slack| 99999999 - var_slack}, "\n"
	max_var = fa_ret[:var].map{|var_slack| 99999999 - var_slack}.max
	er_bound = fa_ret[:sch].select{|sch| g.p[:PO][sch[:id] - 1] }.map{|schedule| schedule[:error] }.max
	full_approximate_ilp.vs(fa_ret[:sch], 0)

	$stdout.print "&\t#{fa_ret[:opt]}&\t#{max_var}&\t#{1 - Math::E**er_bound}"

	#accurate 
	accurate_ilp = DFG_ILP::ILP.new(g, {
		:err_type => 'var', 
		:q => latency, 
		:variance_bound => 0, 
		:operation_parameters => operation_parameters1})
	a_ret = accurate_ilp.compute(g, :cplex)
	accurate_ilp.vs(a_ret[:sch], 0)
	
	$stdout.print "&\t#{a_ret[:opt]}&\t0&\t0"

	# mmkp
	ilp = DFG_ILP::ILP.new(g, {
		:type => 'mmkp', 
		:variance_bound => variance_bound, 
		:q => latency,
		:operation_parameters => operation_parameters1})
	mmkp_r = ilp.mmkp_compute(g, :cplex)
	max_var =  mmkp_r[:var].map{|var_slack| variance_bound - var_slack}.max
	er_bound = [*0..g.p[:v].length - 1].select{|i| g.p[:PO][i] }.map{|po| mmkp_r[:error][po] }.max
	$stderr.print  "energy:", mmkp_r[:energy],  "\n"
	$stderr.print "var: ", max_var, "\n"
	$stderr.print "er: ", er_bound, "\n"
	
	$stdout.print "\t&#{mmkp_r[:energy]}&\t#{max_var}&\t#{1 - Math::E**er_bound}\\\\\n"

end
