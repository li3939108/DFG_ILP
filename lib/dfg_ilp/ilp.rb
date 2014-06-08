module DFG_ILP
	class ILP
		DEFAULT_OPERATION_PARAMETERS = {
		'x' => {
			:type => ["approximate", "accurate"], 
			:u    => [1, 1], 
			:d    => [2, 3], 
			:g    => [1000, 2000],
			:p    => [50, 100],
			:err  => [1, 0] },
		'+' => {
			:type => ["approximate", "accurate"], 
			:u    => [1, 1],
			:d    => [1, 2], 
			:g    => [200, 500],
			:p    => [10, 30],
			:err  => [1, 0] },
		'D' => {
			:type => ["accurate"],
			:u    => [Float::INFINITY],
			:d    => [1],
			:g    => [20],
			:p    => [3],
			:err  => [0] },
		
		'@' => {
			:type => ["accurate"],
			:u    => [Float::INFINITY],
			:d    => [1],
			:g    => [20],
			:p    => [3],
			:err  => [0] }
		}
		MIN = true#constant for minimum linear programming
		MAX = false#constant for maximum linear programming
		def initialize(
			g, 
			q                     = 20,
			mobility_constrainted = false,
			operations            = [] ,
			#error Bound on Primary Output
			error_bound           = 10 
			)
			@q = q
			@vertex = g.p[:v]
			@edge   = g.p[:e]
			@mC     = mobility_constrainted
			@u      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:u] ]} ]
			@d      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:d] ]} ]
			@g      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:g] ]} ]
			@p      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:p] ]} ]
			@err    = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:err]]}]
			@errB = error_bound

			#get the vertices without vertices depending on
			@end = [*0..@vertex.length-1].map{|i| !@edge.map{|e| e[1]}.include?(i)}
			@end_vertex = [*0..@end.length - 1].select{|i| @end[i] == true}
			@PI_vertex = [*0..g.p[:PI].length - 1].select{|i| g.p[:PI][i] == true}
			@PO_vertex = [*0..g.p[:PO].length - 1].select{|i| g.p[:PO][i] == true}
			@Nrow =	
				@vertex.length +
				@vertex.length + 
				@edge.length + 
				@end.count(true) +
				@vertex.count{|v| v != 'D'} + #error in D operation is ignored
				g.p[:PO].count(true) +
				q * @u.values.flatten.length +
				@u.values.flatten.length
			if (mobility_constrainted )
				@asap = self.ASAP
				@alap = self.ALAP
				@mobility = @asap.map.with_index{|m,i| @alap[i] - @asap[i] }
				@Nx = @vertex.map.with_index{|v,i| @u[v].length * (1 + @mobility[i]) }.reduce(0,:+) 
			else
				@Nx = @vertex.map{|v| @u[v].length * q}.reduce(0,:+) 
			end
			@Nerr = @vertex.length
			@Nu = @u.values.flatten.length 
			@Ns = @vertex.length
			@Ncolumn = @Nx + @Nerr + @Nu + @Ns
			@A = 
			@vertex.map.with_index{|v,i|		#Formula (2)  
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
			@vertex.map.with_index{|v,i|	#Formula (3)  
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
			@edge.map{|e|	#Formula (4)  41
				if(mobility_constrainted)
					start_point = [*0..e[1]-1].map{|j| @u[@vertex[j]].length * (1 + @mobility[j]) }.reduce(0,:+) 
					ntail = @Nx - start_point - @u[@vertex[e[1]]].length * (1 + @mobility[e[1]])
					xArray = [*@asap[e[1]]..@alap[e[1]]].map{|t|     @d[@vertex[e[1]]]                  }.reduce([], :+) 
				else
					start_point = [*0..e[1]-1].map{|j| @u[@vertex[j]].length * q }.reduce(0,:+) 
					ntail = @Nx - start_point - @u[@vertex[e[1]]].length * q
					xArray = [*0..q-1].map{|t|     @d[@vertex[e[1]]]                  }.reduce([], :+) 
				end
				sArray = Array.new(@vertex.length,0)
				sArray[e[0]] = -1
				sArray[e[1]] = 1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)  + Array.new(@Nu, 0)+ sArray
			} +
			@end_vertex.map.with_index{|v,i|	#Formula (5)
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
			@vertex.map.with_index{|v,i|			#Formula (6) (7)
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
			@PO_vertex.map{|v|			#Formula (8)
				errArray = Array.new(@Nerr, 0)
				errArray[v] = 1
				Array.new(@Nx, 0) + errArray + Array.new(@Nu, 0) + Array.new(@Ns, 0)
			} +
			[*0..q * @u.values.flatten.length - 1].map{|row_i|	#Formula (9)
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
			[*0..@u.values.flatten.length - 1].map{|u|
				uArray = Array.new(@Nu, 0)
				uArray[u] = 1
				Array.new(@Nx, 0) + Array.new(@Nerr, 0) + uArray + Array.new(@Ns, 0)
			}
			@op 	= 	
				Array.new(@vertex.length, EQ)				+		#Formula (2)
				Array.new(@vertex.length, EQ)				+		#Formula (3)
				Array.new(@edge.length, LE)				+		#Formula (4)	
				Array.new(@end_vertex.length, LE )			+		#Formula (5)
				Array.new(@vertex.length, EQ)				+
				Array.new(@PO_vertex.length, LE)			+		#Formula (8)
				Array.new(q * @u.values.flatten.length, LE)		+		#Formula (9)
				Array.new(@u.values.flatten.length, LE)
			@b 	=
				Array.new(@vertex.length, 1)				+		#Formula (2)
				Array.new(@vertex.length, 0)				+		#Formula (3)
				Array.new(@edge.length, 0)				+		#Formula (4)	
				Array.new(@end_vertex.length, q)			+		#Formula (5)
				Array.new(@vertex.length , 0)				+		#Formula (6) (7)							
				Array.new(@PO_vertex.length, @errB)			+		#Formula (8)
				Array.new(q * @u.values.flatten.length, 0)		+		#Formula (9)
				@u.values.flatten
			@c	=
				if(mobility_constrainted)
					@vertex.map.with_index{|v,xi|   [*@asap[xi]..@alap[xi]].map{|xt|   @g[v]   }.reduce([], :+)      }.reduce([], :+)
				else
					@vertex.map.with_index{|v,xi|   [*0..q-1].map{|xt|   @g[v]   }.reduce([], :+)      }.reduce([], :+)
				end							+		#xArray
				Array.new(@Nerr, 0)					+		#errArray
				@p.values.flatten.map{|p| p * q }			+		#uArray
				Array.new(@Ns, 0)							#sArray
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
			ret = DFG_ILP.send(method, @A, @op, @b, @c, :min)
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
			err_position =  @Nx 
			for i in [*0..@vertex.length-1]	do
				if(@mC)
					current_length = @u[@vertex[i]].length * (1+@mobility[i]) 
					index = ret[:v][position, current_length].index(1)
					time = index/ @u[ @vertex[i] ].length + @asap[i]
				else 
					current_length = @u[@vertex[i]].length * @q
					index = ret[:v][position, current_length].index(1)
					time = index/ @u[ @vertex[i] ].length + 0
				end
				type = index% @u[@vertex[i]].length 
				error = ret[:v][err_position]
				schedule = schedule + [{
						:id => i + 1, 
						:op => @vertex[i], 
						:time => time, 
						:type => type, 
						:error => error, 
						:delay => @d[ @vertex[i] ][ type ] }]				
				position = position + current_length
				err_position = err_position + 1
			end
			print	"\n", "optimal value: ", ret[:o], "\n", "number of constraints: ", ret[:s].length, "\n", "number of variables: ", ret[:v].length, "\n", 
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
						print sch[i][:op],sch[i][:id],': ', 'd', sch[i][:delay], 'e', sch[i][:error], "   "
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
