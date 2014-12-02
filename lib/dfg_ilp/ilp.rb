module DFG_ILP
	class ILP

		MIN = true#constant for minimum linear programming
		MAX = false#constant for maximum linear programming
		def initialize(g, parameters = {} )
			operation_parameters = parameters[:operation_parameters]
			mobility_constrainted = true
			no_resource_limit = true

			tq = 2
			if parameters[:err_type] == nil then @err_type = 'er' else @err_type = 'var' end
			if parameters[:q] == nil then q = nil else q = parameters[:q] end

			if parameters[:mobility_constrainted] == nil then mobility_constrainted = mobility_constrainted
			else mobility_constrainted = false end

			if parameters[:no_resource_limit] == nil then no_resource_limit = no_resource_limit
			else no_resource_limit = true end

			# this is the default error rate bound on the primay outputs
			if parameters[:error_bound] == nil then error_bound = Math::log(1 - 0.99)
			else error_bound = parameters[:error_bound] end

			# this is the default error rate bound on the primay outputs
			if parameters[:error_bound1] == nil then error_bound1 = Math::log(1 - 0.9)
			else error_bound1 = parameters[:error_bound1] end

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
			@type   = Hash[operation_parameters.map{|k,v| [k, v[:type] ]}]
			@u      = Hash[operation_parameters.map{|k,v| [k, v[:u] ]} ]
			@d      = Hash[operation_parameters.map{|k,v| [k, v[:d] ]} ]
			# dynamic energy
			@g      = Hash[operation_parameters.map{|k,v| [k, v[:g] ]} ]
			# static power
			@p      = Hash[operation_parameters.map{|k,v| [k, v[:p] ]} ]
			@err    = Hash[operation_parameters.map{|k,v| [k, v[:err]]}]
			@err1   = Hash[operation_parameters.map{|k,v| [k, v[:err1]]}]
			@variance    = Hash[operation_parameters.map{|k,v| [k, v[:variance]]}]
			@variance_bound = variance_bound
			@errB = error_bound
			@errB1 = error_bound1
			@scaling_factor = parameters[:scaling]

			#get the vertices without vertices depending on
			@end = [*0..@vertex.length-1].map{|i| !@edge.map{|e| e[1]}.include?(i)}
			@end_vertex = [*0..@end.length - 1].select{|i| @end[i] == true}
			@PI_vertex = [*0..g.p[:PI].length - 1].select{|i| g.p[:PI][i] == true}
			@PO_vertex = [*0..g.p[:PO].length - 1].select{|i| g.p[:PO][i] == true}
			@po_total = g.p[:po_total]


			if parameters[:type] == 'mmkp' 


			#get the number of variables
			@Nerr = @vertex.length
			@Nx = @vertex.map{|v| 
				@variance[v].length
			}.reduce(0,:+) 

			#A is the constraints matrix  Ax <= b
			@A = 

			# Only one of the multiple choices can be selected
			# Multiple choice
			@vertex.map.with_index{|v,i|
				n_zeros_before = [*0..i-1].map{|j|
					@variance[@vertex[j]].length 
				}.reduce(0, :+)
				n_ones = @variance[v].length 
				n_zeros_after = @Nx - n_zeros_before - n_ones
				Array.new(n_zeros_before, 0) + 
				Array.new(n_ones, 1)+
				Array.new(n_zeros_after, 0)+
				Array.new(1, 0) + Array.new(@Nerr, 0)
			} + 

			# Multiple dimension
			[*0..@po_total-1].map{|po_i|
				xArray = @vertex.map.with_index{|v,i|
					@variance[v].map{|value|
						value * (@vertex_precedence_adj[i].ifactor[po_i]**2)
					}
				}.reduce([], :+)
				xArray + [0]+ Array.new(@Nerr, 0)
			}+
			# Energy
			[@vertex.map.with_index{|v,i|
				@g[v]
			}.reduce([], :+) + [-1] + Array.new(@Nerr, 0) ] +
			
			#Error Rate
			@vertex.map.with_index{|v,i|	
				start_point = [*0..i-1].map{|j| @variance[@vertex[j]].length  }.reduce(0,:+) 
				xArray =  Array.new(@err[v]) 
				ntail = @Nx - start_point - xArray.length
				errArray = Array.new(@Nerr, 0)
				errArray[i] = -1
				if g.p[:PI][i] == false
					@edge.select{|e| e[0] == i}.each{|e| errArray[e[1] ] = 1}	
				end
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + [0] + errArray 
			} 

			@op = 
			Array.new(@vertex.length, EQ)+
			Array.new(@po_total, LE)+
			Array.new(1, EQ)+
			# Error rate propagation 
			Array.new(@vertex.length , EQ)
			
			@b =
			Array.new(@vertex.length, 1)+
			Array.new(@po_total, @variance_bound)+
			[0] + 
			# Error rate propagation 
			Array.new(@vertex.length , 0)

			@c =
			@vertex.map.with_index{|v,i|
				ref_index = @type[v].index("accurate")
				@g[v].map{|value|
					 @g[v][ref_index] - value
				}
			}.reduce([],:+) + [0] + Array.new(@Nerr, 0)
			@int = Array.new(@Nx , 'B') + ['I'] + Array.new(@Nerr, 'C')
			@lb = Array.new(@Nx , 0)+ [0] + Array.new(@Nerr, -Float::INFINITY)
			@ub = Array.new(@Nx , 1)+ [Float::INFINITY] + Array.new(@Nerr, 0)



			else




			if (mobility_constrainted )
				ret = self.ASAP(:min)
				@critical_length = ret[:latency]
				if( @q == nil) then q = @q = @critical_length * tq end
				@asap = ret[:schedule]
				@alap = self.ALAP(:min)
				@mobility = @asap.map.with_index{|m,i| @alap[i] - @asap[i] }
				@Nx = @vertex.map.with_index{|v,i| @u[v].length * (1 + @mobility[i]) }.reduce(0,:+) 
			else
				@Nx = @vertex.map{|v| @u[v].length * q}.reduce(0,:+) 
				if( q == nil) then q = 40 end
			end

			# the number of error for each vertex
			# only for error rate 
			@Nerr =  @vertex.length   

			# Number of different types of implementations used
			@Nu = @u.values.flatten.length 

			# starting time 
			@Ns = @vertex.length

			# number of columns 
			@Ncolumn = @Nx + @Nerr + @Nerr + @Nu + @Ns

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
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0) * 2 + Array.new(@Nu, 0) + sArray
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
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)* 2  + Array.new(@Nu, 0)+ sArray
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
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)*2  + Array.new(@Nu, 0)+ sArray
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
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + errArray+Array.new(@Nerr,0) + Array.new(@Nu, 0) + Array.new(@Ns, 0)
			} +@vertex.map.with_index{|v,i|	
				if(mobility_constrainted)
					start_point = [*0..i-1].map{|j| @u[@vertex[j]].length * (1+@mobility[j]) }.reduce(0,:+) 
					xArray = [*@asap[i]..@alap[i]].map{|t| Array.new(@err1[v])}.reduce([], :+) 
					ntail = @Nx - start_point - @u[v].length * (1+@mobility[i])
				else
					start_point = [*0..i-1].map{|j| @u[@vertex[j]].length * q }.reduce(0,:+) 
					xArray = [*0..q-1].map{|t| Array.new(@err1[v])}.reduce([], :+) 
					ntail = @Nx - start_point - @u[v].length * q
				end
				errArray = Array.new(@Nerr, 0)
				errArray[i] = -1
				if g.p[:PI][i] == false
					@edge.select{|e| e[0] == i}.each{|e| errArray[e[1] ] = 1}	
				end
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr,0) + errArray + Array.new(@Nu, 0) +  Array.new(@Ns, 0)
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
				xArray + Array.new(@Nerr, 0)*2 + Array.new(@Nu, 0) + Array.new(@Ns, 0)
			}   +
			(@err_type == 'er' ? 

			# Error bounds at Primary Outputs
			(@PO_vertex.map{|v|	
				errArray = Array.new(@Nerr, 0)
				errArray[v] = 1
				Array.new(@Nx, 0) + errArray + Array.new(@Nerr, 0) + Array.new(@Nu, 0) + Array.new(@Ns, 0)
			}+@PO_vertex.map{|v|	
				errArray = Array.new(@Nerr, 0)
				errArray[v] = 1
				Array.new(@Nx, 0) + Array.new(@Nerr, 0) + errArray + Array.new(@Nu, 0)  + Array.new(@Ns, 0)
			}) : [] ) +
			
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
				xArray + Array.new(@Nerr, 0)*2 + uArray + Array.new(@Ns, 0) 
			} +
			( if no_resource_limit == false then [*0..@u.values.flatten.length - 1].map{|u|
				uArray = Array.new(@Nu, 0)
				uArray[u] = 1
				Array.new(@Nx, 0) + Array.new(@Nerr, 0)*2 + uArray + Array.new(@Ns, 0)
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
				Array.new(@vertex.length, EQ)*2				+
				# variance bounds
				(@err_type == 'er' ? Array.new(@po_total, GE):
					Array.new(@po_total, LE))		 	+		#error
				# Error Rate bounds at Primary Outputs
				(@err_type == 'er' ? 
					Array.new(@PO_vertex.length, GE):[])*2		+		
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
				Array.new(@vertex.length , 0)*2					+
				# Variance bounds
				(@err_type == 'er' ?  Array.new(@po_total, 0):
					Array.new(@po_total, @variance_bound)		)	+
				# Error Rate bounds at Primary Outputs
				(@err_type == 'er' ? Array.new(@PO_vertex.length, @errB):[])	+
				# Error Rate bounds at Primary Outputs
				(@err_type == 'er' ? Array.new(@PO_vertex.length, @errB1):[])	+
				# Resource allocation 
				Array.new(q * @u.values.flatten.length, 0)			+
				# Recousce bounds 
				( if no_resource_limit == false then @u.values.flatten else [] end )

			# max cx
			# Objective vector
			@c	=
				if(mobility_constrainted)
					@vertex.map.with_index{|v,xi|   [*@asap[xi]..@alap[xi]].map{|xt|   @g[v].map{|v| 0}   }.reduce([], :+)      }.reduce([], :+)
				else
					@vertex.map.with_index{|v,xi|   [*0..q-1].map{|xt|   @g[v].map{|v| 0}  }.reduce([], :+)      }.reduce([], :+)
				end							+		#xArray
				Array.new(@Nerr, 0)*2					+		#errArray
				@p.values.flatten.map{|p| p * q * @scaling_factor }	+		#uArray
				Array.new(@Ns, 0)							#sArray
			# Integer constraints
			@int	=
				# Binary 
				Array.new(@Nx, 'B')					+
				# Continuous
				Array.new(@Nerr, 'C')*2					+
				# Integer
				Array.new(@Nu, 'I')					+ 
				Array.new(@Ns, 'I')

			# Lower bounds for each variable
			@lb	=
				Array.new(@Nx, 0)					+
				Array.new(@Nerr, -Float::INFINITY)*2			+
				Array.new(@Nu, 0)					+
				Array.new(@Ns, 0)					
			# Upper bounds for each variable
			@ub	=
				Array.new(@Nx, Float::INFINITY)    +
				Array.new(@Nerr, 0)*2              +
				Array.new(@Nu, Float::INFINITY)    +
				Array.new(@Ns, Float::INFINITY)
		end
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
		def mmkp_compute(g, method)
			ret = DFG_ILP.send(method, @A, @op, @b, @c, @int, @lb, @ub, :max)
			position = 0
			err_position =  @Nx + 1
			@delay = []
			t = []
			error = []
			for i in [*0..@vertex.length - 1] do
				index = ret[:v][position, @variance[ @vertex[i] ].length].index(1)
				$stderr.print 'vertex', i, ': ', @vertex[i] , ' ',  @type[ @vertex[i] ] [index], "delay: ", @d[ @vertex[i] ][ index ], "\n"
				@delay [i] = @d[ @vertex[i] ][ index ]
				t[i] = index
				error.push( ret[:v][err_position]  )
				position += @variance[ @vertex[i] ].length
				err_position += 1
			end
			position = @vertex.length 
			var_slack = []
			for i in [*0..@po_total-1] do
				var_slack.push(ret[:s][position])
				position += 1
			end 
			{:type => t,
			 :energy => ret[:v][@Nx],
			 :var => var_slack,
			 :error => error} 
			
		end

		###################################
		# following are for list scheduling
		###################################
		def delay(vertex, type, index) 
			@d[vertex.type][type [ index ] ]
		end
		def finished(time, cur, vertex, type)
			index = vertex.n - 1
			if(time[index] == nil) 
				return false
			else
				return ( cur >= time[index] + delay( vertex, type, index) )
			end
		end
		def scheduled(time, cur, vertex, type)
			index = vertex.n - 1
			if(time[index] == nil)
				return false 
			else 
				return true 
			end
		end
		def allocate_available_resource( being_used, vindex_0, implementation, allocated, allocated_index)
			type = @vertex[ vindex_0 ]
			length = being_used[ type ].length
			for i in  implementation..length-1 
				available_resource = being_used[ type ][ i ].index(0) 
				if(available_resource != nil)
					being_used[ type ][ i][available_resource] = @d[ type ][ i ]
					allocated [ vindex_0 ] = i 
					allocated_index[ vindex_0] = available_resource 
					return true
				end
			end
			return false
		end
		def add_to(cur,time_slot, time, reverse_adj_list, vindex_0)
			time[vindex_0] = cur
			if(time_slot[cur] == nil) 
				time_slot[cur] = Array.new(1, reverse_adj_list[vindex_0])
			else
				time_slot[cur].push(reverse_adj_list[vindex_0])
			end
		end
		
		def list_scheduler(implementation, util, prev_used, y, prev_util)
			time = []
			time_slot = []
			allocated = []
			allocated_index = []
			time_alap = self.ALAP(nil)
			time_slot_alap = []
			reverse_adj_list = []
			for i in [*0..time_alap.length - 1] do
				if time_slot_alap[ time_alap[i] ] == nil 
					time_slot_alap[ time_alap[i] ] = Array.new(1, i) 
				else 
					time_slot_alap[ time_alap[i] ].push(i) 
				end
			end
			print "\n", "time_alap: ", time_alap, "time_slot_alap: ", time_slot_alap, "\n\n"
			being_used = Hash[ @d.map{|k,v| [k, v.map{|delay| []} ] } ]

			# Create reverse adjancency list 
			# No dummy node at index 0
			@vertex_precedence_adj.each{|v|
				reverse_adj_list[v.n - 1] = DFG_ILP::Vertex_precedence.new(v.n, v.type) }
			@vertex_precedence_adj.each{|v|
				v.adj.each{|w|
					reverse_adj_list[w.n - 1].adj_push(v)}}
			#print "reverselist: ", reverse_adj_list , "\n\n"
			#scheduled = []
			for_scheduling = reverse_adj_list.select{|v| 
				(v.adj.empty? or 
				v.adj.select{|vi| 
					not finished(time, i, vi, allocated) }.empty?) and 
				(not scheduled( time, i, v, implementation) ) }
			#print for_scheduling , "\n\n"
			for i in [*0..time_slot_alap.length - 1] do
				#print "enter step: ", i, "\n\n", time, "\n\n----------\n\n"
				being_used = Hash[ being_used.map{|k,v| [k, v.map{|delay| delay.map{|d| d > 0 ? d - 1 : 0 }} ]}  ]
				if time_slot_alap[i]  != nil then
					time_slot_alap[i].each{|vindex_0|# starting from index 0
					
					if(not scheduled( time, i, reverse_adj_list[vindex_0], implementation) ) then 
						add_to(i, time_slot, time, reverse_adj_list, vindex_0)
						if( allocate_available_resource( being_used, vindex_0, implementation[vindex_0], allocated, allocated_index ) == false)
							being_used[ @vertex[vindex_0] ][ implementation[vindex_0] ].push ( 
								@d[ @vertex[vindex_0] ][implementation[ vindex_0 ]] )
							allocated[ vindex_0] = implementation[vindex_0]
							allocated_index[vindex_0] =  being_used[ @vertex[vindex_0] ][ implementation[vindex_0] ].length - 1 
						end
					end
					}
				else 
					for_scheduling = reverse_adj_list.select{|v| 
						(v.adj.empty? or 
						v.adj.select{|vi| 
							not finished( time, i, vi, allocated) }.empty?) and 
						(not scheduled( time, i, v, implementation) ) }
					if(not for_scheduling.empty?) then 
						for_scheduling = for_scheduling.sort{|x,y|
							time_alap[x.n - 1] <=> time_alap[y.n - 1]
						}
					#	print time_alap, "\n"
					#	print for_scheduling, "\n"
						for_scheduling.each{|v|
						vindex_0 = v.n - 1
						if ( true == allocate_available_resource( being_used, vindex_0, implementation[vindex_0], allocated, allocated_index) )
							add_to(i, time_slot, time, reverse_adj_list, vindex_0 )
						elsif (  prev_used == nil and being_used[ v.type ][ implementation[ vindex_0 ] ].empty? )  

							add_to(i, time_slot, time, reverse_adj_list, vindex_0)
							being_used[ v.type ][ implementation[ vindex_0] ].push ( 
								@d[ @vertex[vindex_0] ][implementation[ vindex_0 ]] )
							allocated[ vindex_0] = implementation[vindex_0]
							allocated_index[vindex_0 ] = being_used[ v.type ][ implementation[ vindex_0] ].length - 1

						elsif( prev_used != nil and ( (being_used[ v.type ].map{|arr| arr.length}.reduce(0, :+) + 0.0) / 
						prev_used[ v.type].map{|arr| arr.length}.reduce(0, :+)  < util[ v.type ] * y) ) 

							chosen_type = choose_type_to_allocate(prev_util, @vertex[ vindex_0 ], implementation[ vindex_0 ])
							if(chosen_type != -1)
								add_to(i, time_slot, time, reverse_adj_list, vindex_0)
								being_used[ v.type ][ chosen_type ].push(
									@d[ @vertex[vindex_0] ][ chosen_type ] ) 
								allocated[ vindex_0 ] = chosen_type 
								allocated_index[ vindex_0 ] = being_used[v.type ][chosen_type ].length - 1
							end
						end
						}
					end
				end
			end
			{:time => time, 
			:time_slot=> time_slot, 
			:being_used => being_used,
			:allocated => allocated,
			:allocated_index => allocated_index,
			}
		end
		def choose_type_to_allocate(util, vtype, imptype)
			max_index = -1
			i = imptype
			max = 0
			util[vtype][imptype..-1].each{|arr|
				if( not arr.empty?  )
					if(arr.last > max)
						max = arr.last
						max_index =  i
					end
				end
				i += 1
			}
			if(max_index != -1) then util[vtype][max_index].pop end
			max_index
		end
		
		def iterative_list_scheduling(implementation, y, run_bound = Float::INFINITY)
			cur_overall_util = nil
			prev_overall_util = nil
			cur_each_util = nil
			prev_each_util = nil
			prev_used = nil
			cur_used = nil
			run = 0
			while(run < run_bound and (  cur_overall_util == nil or 
			prev_overall_util == nil or 
			(not cur_overall_util.values.map.with_index{|u,i|
				u == nil or u - prev_overall_util.values[i] < 0.01}.select{|t| t == false}.empty? ) ) )
				
				prev_each_util = cur_each_util
				prev_overall_util = cur_overall_util
				prev_used = cur_used
				ret = list_scheduler(implementation, cur_overall_util, prev_used, y, cur_each_util)
				cur_used = ret[:being_used]
				cur_overall_util = all_utilization( @q,	ret[:being_used], ret[:allocated], @d, @vertex )
				cur_each_util = utilization(@q, ret[:being_used], ret[:allocated], ret[:allocated_index], @d, @vertex)
				run += 1
			end
			$stderr.print "\n\nrun: " , run ,"\n\n"
			print utilization(@q, ret[:being_used], ret[:allocated], ret[:allocated_index], @d, @vertex)
			ret
		end
		#def current_utilization(cur, being_used, allocated, delay, vertex_type, type)
		#	total = (cur + 1) * being_allocated[type].map{|arr| arr.length}.reduce(0, :+)
		#	occupied = allocated.map.with_index{|imp, i|
		#		vertex_type[i] == type ? delay[ vertex_type[i] ][ imp ] : 0	
		#	}.reduce(0, :+)
		#	
		#end
		def all_utilization(q, previous_used, previous_allocated, delay, vertex_type)
			ret = {}
			Hash[ previous_used.keys.map{|v| 
				previous_used[v].map{|arr| arr.length}.reduce(0, :+) == 0 ? 
				[v, nil] : 
				[v, average_utilization( @q,previous_used, previous_allocated,@d,@vertex,v)] }]
		end
		def utilization(q, used, allocated, allocated_index, delay, vertex_type)
			ret = Hash[ used.map{|k,v|
				[k, v.map.with_index{|res, i|
					total = q 
					res.map.with_index{|nouse, index|
						occupied = delay[ k ][ i ] * allocated.map.with_index{|type, aindex|
							( vertex_type[aindex] == k and type == i and allocated_index[ aindex ] == index ) ? 1: 0
						}.reduce(0, :+) / (q + 0.0)
					}.sort
				} ]
			}]
		end
		def average_utilization(q, previous_used, previous_allocated, delay, vertex_type, type)
			total = q * previous_used[type].map{|arr| arr.length}.reduce(0, :+);
			occupied = vertex_type.map.with_index{|v,i| 
				v == type ? delay[v][ previous_allocated[i] ]: 0
			}.reduce(0, :+)
			(occupied + 0.0) / total
		end
		#######################
		#End of List Scheduling
		#######################
		def compute(g, method)
			ret = DFG_ILP.send(method, @A, @op, @b, @c, @int, @lb, @ub, :min)
			# This is the position of resource usage
			position = @Nx +@Nerr*2 - 1
	        
			allocation = {}
			@u.keys.each{|k|
				allocation[k] = @u[k].map{|u|
					position = position + 1
					ret[:v][position] 
				}
			}
			schedule = []
			position = 0
			err_position =  @Nx
			err1_position = @Nx + @Nerr
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
				error = ret[:v][err_position] 
				error1 = ret[:v][err1_position] 
				schedule = schedule + [{
						:id => i + 1, 
						:op => @vertex[i], 
						:time => time, 
						:type => type, 
						:error =>  error , 
						:error1 => error1,
						:delay => @d[ @vertex[i] ][ type ] }]				
				position = position + current_length
				err1_position = err1_position + 1 
				err_position = err_position + 1 
			end
			position = @vertex.length + @vertex.length + @edge.length + @end_vertex.length + @vertex.length*2
			var_slack = []
			for i in [*0..@po_total-1] do
				var_slack.push(ret[:s][position])
				position += 1
			end 			
			$stderr.print	"\n", "optimal value: ", ret[:o], "\n", 
				"number of constraints: ", ret[:s].length, "\n", 
				"number of variables: ", ret[:v].length, "\n", 
				"allocation: ", allocation, "\n"
			return {:opt => ret[:o], :sch => schedule, :var => var_slack}
		end
		def vs(sch, l = 0)
			if(l == 0)
				$stderr.print "----------------------------------", "\n"
			end
			if(sch.empty?)
				$stderr.print "----------------------------------", "\n"
				return
			else
				$stderr.print l, "\t|\t"
				i = 0
				while i < sch.length do
					if (sch[i][:time] == l) 
						$stderr.print sch[i][:op],sch[i][:id],': ', 
						'd', sch[i][:delay], 't', sch[i][:type],
						'e', 1 - Math::E**sch[i][:error],'e1', 1-Math::E**sch[i][:error1], "   "
						sch.delete_at(i)
					else
						i = i + 1
					end
				end
				$stderr.print "\n"
				vs(sch, l + 1)
			end
		end

	
		require 'dfg_ilp/ilp_ext'
	end
end
