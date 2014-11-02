module DFG_ILP
	class ILP
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
		MIN = true#constant for minimum linear programming
		MAX = false#constant for maximum linear programming
		def initialize(g, parameters = {} )
			mobility_constrainted = true
			no_resource_limit = true

			tq = 2
			if parameters[:err_type] == nil then @err_type = 'er' else @err_type = 'var' end
			if parameters[:q] == nil then q = nil else q = parameters[:q] end

			if parameters[:mobility_constrainted] == nil then mobility_constrainted = mobility_constrainted
			else mobility_constrainted = false end

			if parameters[:no_resource_limit] == nil then no_resource_limit = no_resource_limit
			else no_resource_limit = true end

			operations            = [] 

			# this is the default error rate bound on the primay outputs
			if parameters[:error_bound] == nil then error_bound = Math::log(1 - 0.01)
			else error_bound = parameters[:error_bound] end

			# this is the default variance bound on the primary outputs 
			if parameters[:variance_bound] == nil then variance_bound = 30000
			else variance_bound = parameters[:variance_bound] end

			if parameters[:times_q] == nil then tq = 2
			else tq = parameters[:times_q]  end

			@q = q
			@vertex = g.p[:v]
			@vertex_precedence_adj = g.p[:adj]
			@edge   = g.p[:e]
			@mC     = mobility_constrainted
			@u      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:u] ]} ]
			@d      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:d] ]} ]
			@g      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:g] ]} ]
			@p      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:p] ]} ]
			@err    = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:err]]}]
			@variance    = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:variance]]}]
			@variance_bound = variance_bound
			@errB = error_bound

			#get the vertices without vertices depending on
			@end = [*0..@vertex.length-1].map{|i| !@edge.map{|e| e[1]}.include?(i)}
			@end_vertex = [*0..@end.length - 1].select{|i| @end[i] == true}
			@PI_vertex = [*0..g.p[:PI].length - 1].select{|i| g.p[:PI][i] == true}
			@PO_vertex = [*0..g.p[:PO].length - 1].select{|i| g.p[:PO][i] == true}
			@po_total = g.p[:po_total]
			if (mobility_constrainted )
				ret = self.ASAP
				@critical_length = ret[:latency]
				if( @q == nil) then q = @q = @critical_length * tq end
				@asap = ret[:schedule]
				@alap = self.ALAP
				@mobility = @asap.map.with_index{|m,i| @alap[i] - @asap[i] }
				@Nx = @vertex.map.with_index{|v,i| @u[v].length * (1 + @mobility[i]) }.reduce(0,:+) 
			else
				@Nx = @vertex.map{|v| @u[v].length * q}.reduce(0,:+) 
				if( q == nil) then q = 40 end
			end
			@Nrow =	
				@vertex.length +
				@vertex.length + 
				@edge.length + 
				@end.count(true) +
				@vertex.count{|v| v != 'D'} + #error in D operation is ignored
				g.p[:PO].count(true) +
				q * @u.values.flatten.length +
				@u.values.flatten.length

			# the number of error for each vertex
			# only for error rate 
			@Nerr =  @vertex.length   

			# Number of different types of implementations used
			@Nu = @u.values.flatten.length 

			# starting time 
			@Ns = @vertex.length

			# number of columns 
			@Ncolumn = @Nx + @Nerr + @Nu + @Ns

			# This giant matrix is the constraint matrix
			# Ax <= b
			@A = 

			# One operation can only be scheduled one time step, 
			# using one type of implementation
			@vertex.map.with_index{|v,i|
				if(mobility_constrainted)
					start_point = [*0..i-1].map{|j| @u[@vertex[j]].length * (1 + @mobility[j]) }.reduce(0,:+) 
					ntail = @Ncolumn - start_point - @u[ v ].length * (1 + @mobility[i])
					Array.new(start_point, 0) + Array.new(@u[ v ].length * (1 + @mobility[i]), 1) + Array.new(ntail, 0)
				else
					start_point = [*0..i-1].map{|j| @u[@vertex[j]].length * q }.reduce(0,:+) 
					ntail = @Ncolumn - start_point - @u[ v ].length * q
					Array.new(start_point, 0) + Array.new(@u[ v ].length * q, 1) + Array.new(ntail, 0)
				end
			} +
			
			# starting time 
			# s_v = \sum_t\sum_m t * x_{v,t,m}
			@vertex.map.with_index{|v,i|	
				if(mobility_constrainted)
					start_point = [*0..i-1].map{|j| @u[@vertex[j]].length * (1 + @mobility[j]) }.reduce(0,:+) 
					xArray = [*@asap[i]..@alap[i] ].map{|t| Array.new(@u[v].length, t)}.reduce([], :+) 
					ntail = @Nx - start_point - @u[v].length * (1 + @mobility[i] )
				else
					start_point = [*0..i-1].map{|j| @u[@vertex[j]].length * q }.reduce(0,:+)
					xArray = [*0..q-1].map{|t| Array.new(@u[v].length, t)}.reduce([], :+)
					ntail = @Nx - start_point - @u[v].length * q
				end
				sArray = Array.new(@vertex.length,0)
				sArray[i] = -1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0) + Array.new(@Nu, 0) + sArray
			} +
			
			# precedence constraints
			@edge.map{|e|	
				if(mobility_constrainted)
					start_point = [*0..e[1]-1].map{|j| @u[@vertex[j]].length * (1 + @mobility[j]) }.reduce(0,:+) 
					ntail = @Nx - start_point - @u[@vertex[e[1]]].length * (1 + @mobility[e[1]])
					xArray = [*@asap[e[1]]..@alap[e[1]]].map{|t|     @d[@vertex[e[1]]]                  }.reduce([], :+) 
				else
					start_point = [*0..e[1]-1].map{|j| @u[@vertex[j]].length * q }.reduce(0,:+) 
					ntail = @Nx - start_point - @u[@vertex[e[1]]].length * q
					xArray = [*0..q-1].map{|t|     @d[@vertex[e[1]]]           }.reduce([], :+) 
				end
				sArray = Array.new(@vertex.length,0)
				sArray[e[0]] = -1
				sArray[e[1]] = 1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)  + Array.new(@Nu, 0)+ sArray
			} +
			
			#precedence constraints at Primary Outputs
			@end_vertex.map.with_index{|v,i|	
				if(mobility_constrainted)
					start_point = [*0..v-1].map{|j| @u[@vertex[j]].length * (1+@mobility[j]) }.reduce(0,:+) 
					ntail = @Nx - start_point - @u[@vertex[v]].length * (1+@mobility[v])
					xArray = [*@asap[v]..@alap[v]].map{|t|          @d[@vertex[v]]                      }.reduce([], :+)
				else
					start_point = [*0..v-1].map{|j| @u[@vertex[j]].length * q }.reduce(0,:+) 
					ntail = @Nx - start_point - @u[@vertex[v]].length * q
					xArray = [*0..q-1].map{|t|          @d[@vertex[v]]                      }.reduce([], :+)
				end
				sArray = Array.new(@vertex.length,0)
				sArray[v] = 1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)  + Array.new(@Nu, 0)+ sArray
			} +
			
			# error constraints
			# Error rate propagation
			@vertex.map.with_index{|v,i|	
				if(mobility_constrainted)
					start_point = [*0..i-1].map{|j| @u[@vertex[j]].length * (1+@mobility[j]) }.reduce(0,:+) 
					xArray = [*@asap[i]..@alap[i]].map{|t| Array.new(@err[v])}.reduce([], :+) 
					ntail = @Nx - start_point - @u[v].length * (1+@mobility[i])
				else
					start_point = [*0..i-1].map{|j| @u[@vertex[j]].length * q }.reduce(0,:+) 
					xArray = [*0..q-1].map{|t| Array.new(@err[v])}.reduce([], :+) 
					ntail = @Nx - start_point - @u[v].length * q
				end
				errArray = Array.new(@Nerr, 0)
				errArray[i] = -1
				if g.p[:PI][i] == false
					@edge.select{|e| e[0] == i}.each{|e| errArray[e[1] ] = 1}	
				end
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + errArray + Array.new(@Nu, 0) + Array.new(@Ns, 0)
			} +
			# variance constraints and bounds
			[*0..@po_total - 1].map{|po_i|
				if(mobility_constrainted)
					xArray = @vertex.map.with_index{|v,i|
						[*@asap[i]..@alap[i]].map{|t| Array.new(
						@variance[v].map{|value|
							# ifactor^2 * varaiance
							value * (@vertex_precedence_adj[i].ifactor[po_i]**2)
						})}.reduce([], :+) 
					}.reduce([], :+)
				else
					xArray = @vertex.map.with_index{|v,i| 
						[*0..q-1].map{|t| Array.new(
						@variance[v].map{|value|
							# ifactor^2 * varaiance
							value * (@vertex_precedence_adj[i].ifactor[po_i]**2)
						})}.reduce([], :+)
					}.reduce([],:+)
				end
				xArray + Array.new(@Nerr, 0) + Array.new(@Nu, 0) + Array.new(@Ns, 0)
			}   +
			(@err_type == 'er' ? 

			# Error bounds at Primary Outputs
			@PO_vertex.map{|v|	
				errArray = Array.new(@Nerr, 0)
				errArray[v] = 1
				Array.new(@Nx, 0) + errArray + Array.new(@Nu, 0) + Array.new(@Ns, 0)
			} : [] ) +
			
			# resource constraints
			[*0..q * @u.values.flatten.length - 1].map{|row_i|
				t = row_i / @u.values.flatten.length
				di = row_i % @u.values.flatten.length
				d = @d.values.flatten[di]
				flattenUtype = @u.keys.map{|k| Array.new(@u[k].length, k)}.reduce([],:+)
				flattenUimplementation = @u.keys.map{|k| [*0..@u[k].length - 1]}.reduce([], :+)
				type = flattenUtype[di]
				implementation = flattenUimplementation[di]
				if(mobility_constrainted) then xArray =	@vertex.map.with_index{|v,xi| [*@asap[xi]..@alap[xi]].map{|xt| 
					@u[v].map.with_index{|u,m| if v == type and xt <= t and t <= xt + d - 1 and m == implementation then 1 else 0 end}
					}.reduce([],:+)}.reduce([],:+)
				else xArray = @vertex.map.with_index{|v,xi|	[*0..q - 1].map{|xt|
					@u[v].map.with_index{|u,m| if v == type and m == implementation and xt <= t and t <= xt + d - 1 then 1 else 0 end}
					}.reduce([],:+)}.reduce([],:+)
				end
				uArray = Array.new(@Nu, 0)
				uArray[di] = -1
				xArray + Array.new(@Nerr, 0) + uArray + Array.new(@Ns, 0) 
			} +
			( if no_resource_limit == false then [*0..@u.values.flatten.length - 1].map{|u|
				uArray = Array.new(@Nu, 0)
				uArray[u] = 1
				Array.new(@Nx, 0) + Array.new(@Nerr, 0) + uArray + Array.new(@Ns, 0)
			} else [] end)
			
			# less than or equal to or greater than
			@op 	= 	
				
				# One implementation constraint
				Array.new(@vertex.length, EQ)				+		
				# Starting time
				Array.new(@vertex.length, EQ)				+
				# Precedence constraints
				Array.new(@edge.length, LE)				+		
				# Precedence constraints at Primary Outputs
				Array.new(@end_vertex.length, LE )			+	
				# Error Rate propagation 
				Array.new(@vertex.length, EQ) 				+
				# variance bounds
				Array.new(@po_total, LE)			 	+		#error
				# Error Rate bounds at Primary Outputs
				(@err_type == 'er' ? 
					Array.new(@PO_vertex.length, GE):[])		+		
				# Resource allocation 
				Array.new(q * @u.values.flatten.length, LE)		+
				# Recousce bounds 
				( if no_resource_limit == false then Array.new(@u.values.flatten.length, LE) else [] end)
			@b 	=
				# One implementation constraint
				Array.new(@vertex.length, 1)					+
				# Starting time
				Array.new(@vertex.length, 0)					+
				# Precedence constraints
				Array.new(@edge.length, 0)					+
				# Precedence constraints at Primary Outputs
				Array.new(@end_vertex.length, q)				+
				# Error rate propagation 
				Array.new(@vertex.length , 0)					+
				# Variance bounds
				(@err_type == 'er' ?  Array.new(@po_total, Float::INFINITY):
					Array.new(@po_total, @variance_bound)		)	+
				# Error Rate bounds at Primary Outputs
				(@err_type == 'er' ? Array.new(@PO_vertex.length, @errB):[])	+
				# Resource allocation 
				Array.new(q * @u.values.flatten.length, 0)			+
				# Recousce bounds 
				( if no_resource_limit == false then @u.values.flatten else [] end )

			# max cx
			# Objective vector
			@c	=
				if(mobility_constrainted)
					@vertex.map.with_index{|v,xi|   [*@asap[xi]..@alap[xi]].map{|xt|   @g[v]   }.reduce([], :+)      }.reduce([], :+)
				else
					@vertex.map.with_index{|v,xi|   [*0..q-1].map{|xt|   @g[v]   }.reduce([], :+)      }.reduce([], :+)
				end							+		#xArray
				Array.new(@Nerr, 0)					+		#errArray
				@p.values.flatten.map{|p| p * q }			+		#uArray
				Array.new(@Ns, 0)							#sArray
			# Integer constraints
			@int	=
				# Binary 
				Array.new(@Nx, 'B')					+
				# Continuous
				Array.new(@Nerr, 'C')					+
				# Integer
				Array.new(@Nu, 'I')					+ 
				Array.new(@Ns, 'I')

			# Lower bounds for each variable
			@lb	=
				Array.new(@Nx, 0)					+
				Array.new(@Nerr, -Float::INFINITY)			+
				Array.new(@Nu, 0)					+
				Array.new(@Ns, 0)					
			# Upper bounds for each variable
			@ub	=
				Array.new(@Nx, Float::INFINITY)    +
				Array.new(@Nerr, 0)                +
				Array.new(@Nu, Float::INFINITY)    +
				Array.new(@Ns, Float::INFINITY)
		end
	
		def p
			{
				:A => @A, 
				:op => @op, 
				:b => @b,
				:c => @c,
				:v => @vertex,
				:d => @d 
			}
		end

		def compute(g, method)
			ret = DFG_ILP.send(method, @A, @op, @b, @c, @int, @lb, @ub, :min)
			# This is the position of resource usage
			position = @Nx +@Nerr - 1
	
			allocation = {}
			@u.keys.each{|k|
				allocation[k] = @u[k].map{|u|
					position = position + 1
					ret[:v][position]
				}
			}
	
			schedule = []
			position = 0
			if @err_type == 'er' then err_position =  @Nx end
			for i in [*0..@vertex.length-1]	do
				if(@mC)
					current_length = @u[@vertex[i]].length * (1+@mobility[i]) 
					index = ret[:v][position, current_length].index(1)
					# The scheduled time step
					time = index/ @u[ @vertex[i] ].length + @asap[i]
				else 
					current_length = @u[@vertex[i]].length * @q
					index = ret[:v][position, current_length].index(1)
					# The scheduled time step
					time = index/ @u[ @vertex[i] ].length + 0
				end
				# The allocated resource type
				type = index% @u[@vertex[i]].length 
				if @err_type == 'er' then  error = ret[:v][err_position] end
				schedule = schedule + [{
						:id => i + 1, 
						:op => @vertex[i], 
						:time => time, 
						:type => type, 
						:error => ( @err_type == 'er' ? error : 0) , 
						:delay => @d[ @vertex[i] ][ type ] }]				
				position = position + current_length
				if @err_type == 'er' then err_position = err_position + 1 end
			end
			print	"\n", "optimal value: ", ret[:o], "\n", 
				"number of constraints: ", ret[:s].length, "\n", 
				"number of variables: ", ret[:v].length, "\n", 
				"allocation: ", allocation, "\n"
			return {:opt => ret[:o], :sch => schedule}
		end
		def vs(sch, l = 0)
			if(l == 0)
				print "----------------------------------", "\n"
			end
			if(sch.empty?)
				print "----------------------------------", "\n"
				return
			else
				print l, "\t|\t"
				i = 0
				while i < sch.length do
					if (sch[i][:time] == l) 
						print sch[i][:op],sch[i][:id],': ', 
						'd', sch[i][:delay], 't', sch[i][:type],
						'e', 1 - Math::E**sch[i][:error], "   "
						sch.delete_at(i)
					else
						i = i + 1
					end
				end
				print "\n"
				vs(sch, l + 1)
			end
		end
	
		require 'dfg_ilp/ilp_ext'
	end
end
