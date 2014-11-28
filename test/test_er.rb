#! /usr/bin/env ruby

require 'dfg_ilp'
operation_parameters1 = {

	's' => {
		:type => [ "appr1", "accurate"], 
		:u    => [ 1, 1], 
		:d    => [ 3, 3], 
		:g    => [80000, 142200],
		:p    => [ 350,430],
		:err  => [Math::log(1 - 0.978), Math::log(1 - 0)] ,
		:err1 => [ Math::log(1-0.977), Math::log(1-0)],
		:variance  => [8282, 0],
	},
	'x' => {
		:type => ["appr1", "accurate"], 
		:u    => [ 1, 1], 
		:d    => [ 3, 3], 
		:g    => [80000, 142200],
		:p    => [ 350,430],
		:err  => [Math::log(1 - 0.978), Math::log(1 - 0)] ,
		:err1 => [ Math::log(1-0.977), Math::log(1-0)],
		:variance  => [8282, 0],
	},
	'ALU' => {
		:type => ["32/8trun", "32/8appr", "32/4trun","accurate"], 
		:u    => [1, 1, 1, 1],
		:d    => [2, 2, 2, 2], 
		:g    => [48390, 38750, 55670,66780],
		:p    => [7,  4, 8, 10],
		:err  => [Math::log(1 - 0.99999), Math::log(1 - 0.978), Math::log(1- 0.996), Math::log(1 - 0)], 
		:err1 => [Math::log(1 - 0.998), Math::log(1 - 0.754), Math::log(1- 0.468), Math::log(1 - 0)],
		:variance  => [10905, 6833, 42, 0],
	},
	'+' =>  {
		:type => ["32/8trun", "32/8appr", "32/4trun","accurate"], 
		:u    => [1, 1, 1, 1],
		:d    => [2, 2, 2, 2], 
		:g    => [48390, 38750, 55670,66780],
		:p    => [7,  4, 8, 10],
		:err  => [Math::log(1 - 0.99999), Math::log(1 - 0.978), Math::log(1- 0.996), Math::log(1 - 0)], 
		:err1 => [Math::log(1 - 0.998), Math::log(1 - 0.754), Math::log(1- 0.468), Math::log(1 - 0)],
		:variance  => [10905, 6833, 42, 0],
	},
	'D' => {
		:type => ["accurate"],
		:u    => [Float::INFINITY],
		:d    => [1],
		:g    => [0],
		:p    => [0],
		:err  => [Math::log(1 - 0)] ,
		:err1  => [Math::log(1 - 0)] ,
		:variance  => [0],

	},
	'@' => {
		:type => ["accurate"],
		:u    => [Float::INFINITY],
		:d    => [1],
		:g    => [66780],
		:p    => [10],
		:err  => [Math::log(1 - 0)] ,
		:err1  => [Math::log(1 - 0)] ,
		:variance  => [0],
	},
	}


operation_parameters2 = {

	's' => {
		:type => ["approximate", "appr1", "accurate"], 
		:u    => [1, 1, 1], 
		:d    => [3, 3, 3], 
		:g    => [50000,80000, 142200],
		:p    => [300, 350,430],
		:err  => [Math::log(1 - 0.997),Math::log(1 - 0.978), Math::log(1 - 0)] ,
		:err1 => [Math::log(1- 0.997), Math::log(1-0.977), Math::log(1-0)],
		:variance  => [21000,8282, 0],
	},
	'x' => {
		:type => ["approximate", "appr1", "accurate"], 
		:u    => [1, 1, 1], 
		:d    => [3, 3, 3], 
		:g    => [50000,80000, 142200],
		:p    => [300, 350,430],
		:err  => [Math::log(1 - 0.997),Math::log(1 - 0.978), Math::log(1 - 0)] ,
		:err1 => [Math::log(1- 0.997), Math::log(1-0.977), Math::log(1-0)],
		:variance  => [21000,8282, 0],
	},
	'ALU' => {
		:type => ["32/8trun", "32/8appr", "32/4trun","accurate"], 
		:u    => [1, 1, 1, 1],
		:d    => [2, 2, 2, 2], 
		:g    => [48390, 38750, 55670,66780],
		:p    => [7,  4, 8, 10],
		:err  => [Math::log(1 - 0.99999), Math::log(1 - 0.978), Math::log(1- 0.996), Math::log(1 - 0)], 
		:err1 => [Math::log(1 - 0.998), Math::log(1 - 0.754), Math::log(1- 0.468), Math::log(1 - 0)],
		:variance  => [10905, 6833, 42, 0],
	},
	'+' =>  {
		:type => ["32/8trun", "32/8appr", "32/4trun","accurate"], 
		:u    => [1, 1, 1, 1],
		:d    => [2, 2, 2, 2], 
		:g    => [48390, 38750, 55670,66780],
		:p    => [7,  4, 8, 10],
		:err  => [Math::log(1 - 0.99999), Math::log(1 - 0.978), Math::log(1- 0.996), Math::log(1 - 0)], 
		:err1 => [Math::log(1 - 0.998), Math::log(1 - 0.754), Math::log(1- 0.468), Math::log(1 - 0)],
		:variance  => [10905, 6833, 42, 0],
	},
	'D' => {
		:type => ["accurate"],
		:u    => [Float::INFINITY],
		:d    => [1],
		:g    => [0],
		:p    => [0],
		:err  => [Math::log(1 - 0)] ,
		:err1  => [Math::log(1 - 0)] ,
		:variance  => [0],

	},
	'@' => {
		:type => ["accurate"],
		:u    => [Float::INFINITY],
		:d    => [1],
		:g    => [66780],
		:p    => [10],
		:err  => [Math::log(1 - 0)] ,
		:err1  => [Math::log(1 - 0)] ,
		:variance  => [0],
	},
	}

root_dir = "/home/me/DFG_ILP"

vertex = ['x', 'x', 'x', 'x', 'x', 'x', '+', '+', '+', '+', '+']
edge = [[6, 0], [6,1], [7,6], [7,2],[8,7], [8,3], [9,8], [9,4], [10,9], [10,5] ]
fir = DFG_ILP::GRAPH.new({:e => edge, :v => vertex, :name => 'fir5'})
fir.ifactor
$stderr.print fir.p[:adj].map{|v| [v.n, v.rand_number]}

arf = DFG_ILP::Parser.new("#{root_dir}/test/dot/arf.dot").parse.to_DFG
arf.ifactor
#$stderr.print arf.p[:adj].map{|v| [v.n, v.rand_number]}

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

testcase = [fir, arf]
testset = [
	mm ,
	sds, 
	pyr, 
	jbmp,  
	iir4, 
	fir, 
	arf,
	mv,
]

minLatency = {
	mm => 18, 
	pyr => 13, 
	jbmp => 11, 
	sds => 30,
	fir => 13,
	iir4 =>24, 
	arf => 19, 
	mv => 11, 
}


testcase.each do |g|
	operation_parameters = operation_parameters1
	
	@p      = Hash[operation_parameters.map{|k,v| [k, v[:p] ]} ]
	latency = minLatency[g] * 3 / 2
	variance_bound = 50000
	scaling = 10
	$stderr.print "\n", g.p[:name], " start", "\n---------------------------\n"
	# variance based ILP
	#startime = Time.new
	#ilp = DFG_ILP::ILP.new(g, {
	#	:err_type => 'var', 
	#	:q => latency, 
	#	:variance_bound => variance_bound, 
	#	:operation_parameters => operation_parameters,
	#	:scaling => scaling} )
	#ret = ilp.ASAP(:min)
	#$stderr.print   "ASAP scheduling done, longest path length: ", ret[:latency], "\n"
	#r = ilp.compute(g, :cplex)
	#	
	#$stderr.print "var: ", r[:var].map{|var_slack| variance_bound - var_slack}, "\n"
	#max_var = r[:var].map{|var_slack| variance_bound - var_slack}.max
	#er_bound = r[:sch].select{|sch| g.p[:PO][sch[:id] - 1] }.map{|schedule| schedule[:error] }.max
	#
	#$stdout.print "#{g.p[:name]}&\t#{r[:opt]}&\t#{max_var}&\t#{1 - Math::E**er_bound}"
	# 
	#ilp.vs(r[:sch], 0)
        #
	#endtime = Time.new
	#$stderr.print "Run Time: ", endtime - startime, "\n"

	# error rate based ILP
	er_bound =  1 - Math::E** ARGV[0].to_f
	er1_bound = 1 -  Math::E** ARGV[1].to_f
	$stderr.print 'er bound: ', er_bound
	$stderr.print 'er1 bound: ', er1_bound
	er_ilp = DFG_ILP::ILP.new(g, {
		:q => latency, 
		:error_bound => er_bound,
		:error_bound1 => er1_bound,
		:operation_parameters => operation_parameters,
		:scaling => scaling}) 
	er_r = er_ilp.compute(g, :cplex)
	$stderr.print "var: ", er_r[:var].map{|var| -var}, "\n"
	max_var = er_r[:var].map{|var| -var}.max

	$stdout.print "&\t#{er_r[:opt]}&\t#{max_var}&\t#{1 - Math::E**er_bound}"

	er_ilp.vs(er_r[:sch], 0)

	# all approximate	
	unlimited_variance_bound = 99999999999999
	full_approximate_ilp = DFG_ILP::ILP.new(g, {
		:err_type => 'var', 
		:q => latency, 
		:variance_bound =>unlimited_variance_bound,
		:operation_parameters => operation_parameters ,
		:scaling => scaling})
	fa_ret = full_approximate_ilp.compute(g, :cplex)
	$stderr.print "var: ", fa_ret[:var].map{|var_slack| unlimited_variance_bound - var_slack}, "\n"
	max_var = fa_ret[:var].map{|var_slack| unlimited_variance_bound- var_slack}.max
	er_bound = fa_ret[:sch].select{|sch| g.p[:PO][sch[:id] - 1] }.map{|schedule| schedule[:error] }.max
	full_approximate_ilp.vs(fa_ret[:sch], 0)

	$stdout.print "&\t#{fa_ret[:opt]}&\t#{max_var}&\t#{1 - Math::E**er_bound}"

	#accurate 
	accurate_ilp = DFG_ILP::ILP.new(g, {
		:err_type => 'var', 
		:q => latency, 
		:variance_bound => 0, 
		:operation_parameters => operation_parameters,
		:scaling => scaling})
	a_ret = accurate_ilp.compute(g, :cplex)
	accurate_ilp.vs(a_ret[:sch], 0)
	
	$stdout.print "&\t#{a_ret[:opt]}&\t0&\t0"

	# mmkp
	startime = Time.new
	ilp = DFG_ILP::ILP.new(g, {
		:type => 'mmkp', 
		:variance_bound => variance_bound, 
		:q => latency,
		:operation_parameters => operation_parameters,
		:scaling => scaling})
	mmkp_r = ilp.mmkp_compute(g, :cplex)
	max_var =  mmkp_r[:var].map{|var_slack| variance_bound - var_slack}.max
	er_bound = [*0..g.p[:v].length - 1].select{|i| g.p[:PO][i] }.map{|po| mmkp_r[:error][po] }.max
	sch = ilp.list_scheduler(mmkp_r[:type])
	static_energy = @p.map{|k,v|
		sch[:being_used][k].map.with_index{|arr,i|
			arr.length * v[i] 
		}.reduce(0, :+) * latency * scaling
	}.reduce(0, :+)
	$stderr.print "\n", sch,"\n"
	$stderr.print  "energy:", mmkp_r[:energy] + static_energy,  "\n"
	$stderr.print "var: ", max_var, "\n"
	$stderr.print "er: ", er_bound, "\n"
	
	$stdout.print "\t&#{mmkp_r[:energy]}&\t#{max_var}&\t#{1 - Math::E**er_bound}\\\\\n"
	endtime = Time.new
	$stderr.print "Run Time: ", endtime - startime , "\n"
	

end
#
#
#
#
#
