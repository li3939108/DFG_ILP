module DFG_ILP

	#multiple choice multiple dimension Knapsack Problem
	class MMKP 
		def initialize(g, parameters = {} )	
			#all vertices, value being the type
			@vertex = g.p[:v]

			#get the number of variables
			@Nx = @vertex.map{|v| 
				@variance[v].legnth
			}.reduce(0,:+)

			#A is the constraints matrix  Ax <= b
			@A = 

			#Only one of the multiple choices can be selected
			@vertex.map.with_index{|v,i|
				Nzeros_before = [*0..i-1].map{|j|
					@variance[@vertex[j]].length 
				}.reduce(0, :+)
				Nones = @variance[v].length 
				Nzeros_after = Nx - Nzeros_before - Nones
				Array.new(Nzeros_before, 0) + 
				Array.new(Nones, 1)+
				Array.new(Nzeros_after, 0)
			} + 

			@PO_vertex.map.with_index{|v,i|
				
			}
		end
	end
	require 'dfg_ilp/ilp_ext'
end
