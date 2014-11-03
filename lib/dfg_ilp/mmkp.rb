module DFG_ILP

	#multiple choice multiple dimension Knapsack Problem
	class MMKP 
	DEFAULT_OPERATION_PARAMETERS = {
		's' => {
			:type => ["approximate", "accurate"],
			:u    => [1,1],
			:d    => [2,3],
			:g    => [1000, 2000],
			:p    => [50, 100],
			:err  => [Math::log(1 - 0.001), Math::log(1 - 0), ],
			:variance  => [8000, 0],
		},
		'x' => {
			:type => ["approximate", "accurate"], 
			:u    => [1, 1], 
			:d    => [2, 3], 
			:g    => [1000, 2000],
			:p    => [50, 100],
			:err  => [Math::log(1 - 0.001), Math::log(1 - 0)] ,
			:variance  => [8000, 0],

		},
			
		'ALU' => {
			:type => ["approximate", "accurate"], 
			:u    => [1, 1],
			:d    => [1, 2], 
			:g    => [200, 500],
			:p    => [10, 30],
			:err  => [Math::log(1 - 0.001),Math::log(1 - 0)], 
			:variance  => [8000, 0],
		},
		'+' => {
			:type => ["approximate", "accurate"], 
			:u    => [1, 1],
			:d    => [1, 2], 
			:g    => [200, 500],
			:p    => [10, 30],
			:err  => [Math::log(1 - 0.001),Math::log(1 - 0)] ,
			:variance  => [8000, 0],
		},
		'D' => {
			:type => ["accurate"],
			:u    => [Float::INFINITY],
			:d    => [1],
			:g    => [20],
			:p    => [3],
			:err  => [Math::log(1 - 0)] ,
			:variance  => [0],

		},
		'@' => {
			:type => ["accurate"],
			:u    => [Float::INFINITY],
			:d    => [1],
			:g    => [20],
			:p    => [3],
			:err  => [Math::log(1 - 0)] ,
			:variance  => [0],
		}
		}
		def initialize(g, parameters = {} )

		end
	end
	require 'dfg_ilp/ilp_ext'
end
