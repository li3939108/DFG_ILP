#! /usr/bin/env ruby

require 'dfg_ilp'
operation_parameters3 = {

	's' => {
		:type => ["approximate", "accurate"], 
		:u    => [1, 1], 
		:d    => [3, 3], 
		:g    => [50000, 142200],
		:p    => [300, 430],
		:err  => [Math::log(1 - 0.978), Math::log(1 - 0)] ,
		:err1 => [ Math::log(1-0.977), Math::log(1-0)],
		:variance  => [210000, 0],
	},
	'x' => {
		:type => ["approximate", "accurate"], 
		:u    => [1, 1], 
		:d    => [3, 3], 
		:g    => [50000, 142200],
		:p    => [300, 430],
		:err  => [Math::log(1 - 0.978), Math::log(1 - 0)] ,
		:err1 => [ Math::log(1-0.977), Math::log(1-0)],
		:variance  => [210000, 0],
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
	'+' => {
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
operation_parameters1 = {

	'x' => {
		:type => ["appr1", "accurate"], 
		:u    => [ 1, 1], 
		:d    => [ 3, 3], 
		:g    => [83100, 142200],
		:p    => [ 350,430],
		:err  => [Math::log(1 - 0.978), Math::log(1 - 0)] ,
		:err1 => [ Math::log(1-0.977), Math::log(1-0)],
		:variance  => [2500, 0],
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
#root_dir = "/homes/grad/li3939108/DFG_ILP"
vertex = ['x', 'x', 'x', 'x', 'x', 'x', '+', '+', '+', '+', '+']
edge = [[6, 0], [6,1], [7,6], [7,2],[8,7], [8,3], [9,8], [9,4], [10,9], [10,5] ]


energyout = File.open("EnergyOut_#{Time.new}", "w")
varout = File.open("VarianceOut_#{Time.new}", "w")
bindingOut = File.open("BindingOut_#{Time.new}", "w")
scalersOut = File.open("ScalerOut_#{Time.new}", "w")


fir = DFG_ILP::GRAPH.new({:e => edge, :v => vertex, :name => 'fir5'})
fir.ifactor

scalersOut.print "\n\/********fir******\/\n"
fir.p[:adj].each{|v| 
	scalersOut.print v.n," = ", v.rand_number, "\n"
}

arf = DFG_ILP::Parser.new("#{root_dir}/test/dot/arf.dot").parse.to_DFG
arf.ifactor

scalersOut.print "\n\/********arf******\/\n"
arf.p[:adj].each{|v| 
	scalersOut.print v.n," = ", v.rand_number, "\n"
}

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
complexcases = [mm]
testset = [
	fir, 
	arf,
	sds, 
	pyr, 
	jbmp,  
	iir4, 
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


testset.each do |g|
	operation_parameters = operation_parameters1
	
	@p      = Hash[operation_parameters.map{|k,v| [k, v[:p] ]} ]
	@g      = Hash[operation_parameters.map{|k,v| [k, v[:g] ]} ]
	@variance=Hash[operation_parameters.map{|k,v| [k, v[:variance]]}]
	latency = minLatency[g] * 2
	variance_bound = 30000
	scaling = 10
	$stderr.print "\n", g.p[:name], " start", "\n---------------------------\n"
	# variance based ILP
	startime = Time.new
	ilp = DFG_ILP::ILP.new(g, {
		:err_type => 'var', 
		:q => latency, 
		:variance_bound => variance_bound, 
		:operation_parameters => operation_parameters,
		:scaling => scaling} )
	ret = ilp.ASAP(:min)
	$stderr.print   "ASAP scheduling done, longest path length: ", ret[:latency], "\n"
	r = ilp.compute(g, :cplex)
	
	$stderr.print "var: ", r[:var].map{|var_slack| variance_bound - var_slack}, "\n"
	max_var = r[:var].map{|var_slack| variance_bound - var_slack}.max
	er_bound = r[:sch].select{|sch| g.p[:PO][sch[:id] - 1] }.map{|schedule| schedule[:error] }.max
	er1_bound = r[:sch].select{|sch| g.p[:PO][sch[:id] - 1] }.map{|schedule| schedule[:error1] }.max
	
	$stderr.print "#{g.p[:name]}&\t#{r[:opt]}&\t#{max_var}&\t#{1 - Math::E**er_bound}\n"
	$stderr.print "#{g.p[:name]}&\t#{r[:opt]}&\t#{max_var}&"
	#$stderr.print "#{g.p[:name]}&\t#{r[:opt]}&\t#{max_var}&\t#{1 - Math::E**er1_bound}\n"

	var_ILP_energy = r[:opt]
	var_ILP_var = max_var
	 
	bindingOut.print "\n\/*****#{g.p[:name]}***ILP*******\/\n"
	r[:sch].each{|sch|
		bindingOut.print "#{(sch[:op] == '+' or sch[:op] == 'ALU')?"add":"mul"}_#{sch[:type]} #{(sch[:op] == '+' or sch[:op] == 'ALU')?"adder":"multiplier"}_#{sch[:id]}#{(sch[:op] == '+' or sch[:op] == 'ALU')?"       ":" "}(out_#{sch[:id]}, in_#{sch[:id]}_0, in_#{sch[:id]}_1 );\n" 
	}

	ilp.vs(r[:sch], 0)

	endtime = Time.new
	$stderr.print "Run Time: ", endtime - startime, "\n"
	
	# error rate based ILP
	#$stderr.print 'er bound: ', 1 - Math::E**er_bound
	#$stderr.print 'er1 bound: ', 1 - Math::E**er1_bound
	#er_ilp = DFG_ILP::ILP.new(g, {
	#	:q => latency, 
	#	:error_bound => er_bound,
	#	:error_bound1 => er1_bound,
	#	:operation_parameters => operation_parameters,
	#	:scaling => scaling}) 
	#er_r = er_ilp.compute(g, :cplex)
	#$stderr.print "var: ", er_r[:var].map{|var| -var}, "\n"
	#max_var = er_r[:var].map{|var| -var}.max

	#$stderr.print "&\t#{er_r[:opt]}&\t#{max_var}&\t#{1 - Math::E**er_bound}"

	#er_ilp.vs(er_r[:sch], 0)

	# all approximate	
	#unlimited_variance_bound = 99999999999999
	#full_approximate_ilp = DFG_ILP::ILP.new(g, {
	#	:err_type => 'var', 
	#	:q => latency, 
	#	:variance_bound =>unlimited_variance_bound,
	#	:operation_parameters => operation_parameters ,
	#	:scaling => scaling})
	#fa_ret = full_approximate_ilp.compute(g, :cplex)
	#$stderr.print "var: ", fa_ret[:var].map{|var_slack| unlimited_variance_bound - var_slack}, "\n"
	#max_var = fa_ret[:var].map{|var_slack| unlimited_variance_bound- var_slack}.max
	#er_bound = fa_ret[:sch].select{|sch| g.p[:PO][sch[:id] - 1] }.map{|schedule| schedule[:error] }.max
	#full_approximate_ilp.vs(fa_ret[:sch], 0)

	#$stderr.print "&\t#{fa_ret[:opt]}&\t#{max_var}&\t#{1 - Math::E**er_bound}"
	#$stderr.print "#{fa_ret[:opt]}&\t#{max_var}&"
        #
	##accurate 
	#accurate_ilp = DFG_ILP::ILP.new(g, {
	#	:err_type => 'var', 
	#	:q => latency, 
	#	:variance_bound => 0, 
	#	:operation_parameters => operation_parameters,
	#	:scaling => scaling})
	#a_ret = accurate_ilp.compute(g, :cplex)
	#accurate_ilp.vs(a_ret[:sch], 0)
	#
	#$stderr.print "&\t#{a_ret[:opt]}&\t0"

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
	sch = ilp.iterative_list_scheduling(mmkp_r[:type], 1.75)
	static_energy = @p.map{|k,v|
		sch[:being_used][k].map.with_index{|arr,i|
			arr.length * v[i] 
		}.reduce(0, :+) * latency * scaling
	}.reduce(0, :+)
	dynamic_energy = sch[:allocated].map.with_index{|t,i|
		@g[ g.p[:v][i] ][ t ]
	}.reduce(0, :+)
	new_variance = sch[:allocated].map.with_index{|t,i|
		g.p[:adj][i].ifactor.map{|factor|
			@variance[ g.p[:v][i] ][ t ] * (factor**2)
		}
	}.inject(Array.new(g.p[:adj][1].ifactor.length, 0) ){|sum, arr| 
		arr.map.with_index{|ele,i|
			ele + sum[i]
		}
	}
	new_energy = static_energy + dynamic_energy
	$stderr.print "\n", sch,"\n"
	$stderr.print  "energy:", mmkp_r[:energy] + static_energy,  "\n"
	$stderr.print "new_energy:", static_energy + dynamic_energy , "\n"
	$stderr.print "var: ", max_var, "\n"
	$stderr.print "new_var: ", new_variance, "\n"
	$stderr.print "er: ", er_bound, "\n"
	
	$stderr.print "\t&#{new_energy}&#{new_variance}\t\\\\\n"
	endtime = Time.new
	$stderr.print "Run Time: ", endtime - startime , "\n"
	
	kils_energy = new_energy
	kils_var = new_variance

	
	bindingOut.print "\n\/***#{g.p[:name]}**KILS*******\/\n"
	for i in [*0..sch[:allocated].length-1] do
		bindingOut.print "#{(g.p[:v][i] == '+' or g.p[:v][i] == 'ALU')?"add":"mul"}_#{sch[:allocated][i]} #{( g.p[:v][i] == '+' or g.p[:v][i] == 'ALU')?"adder":"multiplier"}_#{i+1}#{(g.p[:v][i] == '+' or g.p[:v][i] == 'ALU')?"      ":" "}(out_#{i+1}, in_#{i+1}_0, in_#{i+1}_1 );\n" 
	end

	
	$stderr.print "single run \n*********************\n"
	# mmkp
	startime = Time.new

	max_var =  mmkp_r[:var].map{|var_slack| variance_bound - var_slack}.max
	er_bound = [*0..g.p[:v].length - 1].select{|i| g.p[:PO][i] }.map{|po| mmkp_r[:error][po] }.max
	sch = ilp.iterative_list_scheduling(mmkp_r[:type], 1.05, 1)
	static_energy = @p.map{|k,v|
		sch[:being_used][k].map.with_index{|arr,i|
			arr.length * v[i] 
		}.reduce(0, :+) * latency * scaling
	}.reduce(0, :+)
	dynamic_energy = sch[:allocated].map.with_index{|t,i|
		@g[ g.p[:v][i] ][ t ]
	}.reduce(0, :+)
	new_energy = static_energy + dynamic_energy
	new_variance = sch[:allocated].map.with_index{|t,i|
		g.p[:adj][i].ifactor.map{|factor|
			@variance[ g.p[:v][i] ][ t ] * (factor**2)
		}
	}.inject(Array.new(g.p[:adj][1].ifactor.length, 0) ){|sum, arr| 
		arr.map.with_index{|ele,i|
			ele + sum[i]
		}
	}
	$stderr.print "\n", sch,"\n"
	$stderr.print  "energy:", mmkp_r[:energy] + static_energy,  "\n"
	$stderr.print "new_energy:",new_energy  , "\n"
	$stderr.print "var: ", max_var, "\n"
	$stderr.print "new_var: ", new_variance, "\n"
	$stderr.print "er: ", er_bound, "\n"
	
	$stderr.print "\t&#{new_energy}&#{new_variance}\t\\\\\n"
	endtime = Time.new
	$stderr.print "Run Time: ", endtime - startime , "\n"
	
	kls_energy = new_energy
	kls_var = new_variance

	bindingOut.print "\n\/***#{g.p[:name]}**KLS*******\/\n"
	for i in [*0..sch[:allocated].length-1] do
		bindingOut.print "#{(g.p[:v][i] == '+' or g.p[:v][i] == 'ALU')?"add":"mul"}_#{sch[:allocated][i]} #{( g.p[:v][i] == '+' or g.p[:v][i] == 'ALU')?"adder":"multiplier"}_#{i+1}#{(g.p[:v][i] == '+' or g.p[:v][i] == 'ALU')?"      ":" "}(out_#{i+1}, in_#{i+1}_0, in_#{i+1}_1  );\n" 
	end

	

	static_energy = @p.map{|k,v|
		sch[:being_used][k].map.with_index{|arr,i|
			arr.length  
		}.reduce(0, :+) * v.last * latency * scaling
	}.reduce(0, :+)
	dynamic_energy = sch[:allocated].map.with_index{|t,i|
		@g[ g.p[:v][i] ].last
	}.reduce(0, :+)
	ils_acc_energy = static_energy + dynamic_energy
	ils_acc_var = 0




	static_nergy = @p.map{|k,v|
		sch[:being_used][k].map.with_index{|arr,i|
			arr.length
		}.reduce(0, :+) * ( (k == '+') ? v[1]: v[0] ) * latency * scaling
	}.reduce(0,:+)
	dynamic_energy = sch[:allocated].map.with_index{|t,i|
		((g.p[:v][i] == '+' )?@g[ g.p[:v][i] ][1]:@g[ g.p[:v][i] ][0])
	}.reduce(0, :+)
	new_variance = sch[:allocated].map.with_index{|t,i|
		g.p[:adj][i].ifactor.map{|factor|
			g.p[:v][i] == '+' ? @variance[ g.p[:v][i] ][ 1 ] * (factor**2) : @variance[ g.p[:v][i] ][ 0] * (factor**2)
		}
	}.inject(Array.new(g.p[:adj][1].ifactor.length, 0) ){|sum, arr| 
		arr.map.with_index{|ele,i|
			ele + sum[i]
		}
	}
	ils_app_energy = static_nergy+dynamic_energy
	ils_app_var = new_variance

	energyout.print "#{var_ILP_energy/(ils_acc_energy + 0.0) }&#{ils_app_energy/(ils_acc_energy+0.0)}&#{kils_energy/(ils_acc_energy + 0.0)}&#{kls_energy / (ils_acc_energy + 0.0)}\n"
	varout.print "#{var_ILP_var.kind_of?(Array) ? var_ILP_var.max/(variance_bound + 0.0):var_ILP_var/(variance_bound + 0.0) }&#{ils_app_var.kind_of?(Array)?ils_app_var.max/(variance_bound+0.0):ils_app_var/(variance_bound+0.0)}&#{kils_var.kind_of?(Array)? kils_var.max/(variance_bound + 0.0): kils_var/(variance_bound+0.0)}&#{kls_var.kind_of?(Array)?kls_var.max/(variance_bound + 0.0):kls_var/(variance_bound+0.0)}\n" 
	

end

bindingOut.close
energyout.close
varout.close
