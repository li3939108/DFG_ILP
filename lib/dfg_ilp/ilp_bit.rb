module DFG_ILP
	class ILP
		DEFAULT_OPERATION_PARAMETERS = {
		'x' => {
			:type => ["approximate", "approximate", "accurate", "approximate", "accurate", "accurate"],
			:u    => [Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY],
			:d    => [3, 4, 5, 3, 4, 3],
			:g    => [3000, 4000, 5000, 1000, 2000, 1000],
			:p    => [150, 200, 250, 50, 100, 50],
			:n    => [32,32,32,16,16,8],
			:errs => [16,8,0,8,0,0] },
		'ALU' => {
			:type => ["approximate", "approximate", "accurate", "approximate", "accurate", "accurate"],
			:u    => [Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY],
			:d    => [2,3,4,1,2,1],
			:g    => [500, 700,1000,200,500,200],
			:p    => [30,40,50,10,30,10],
			:n    => [32,32,32,16,16,8],
			:errs => [16,8,0,8,0,0]},
		'+' => {
			:type => ["approximate", "approximate", "accurate", "approximate", "accurate", "accurate"],
			:u    => [Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, ],
			:d    => [2,3,4,1,2,1],
			:g    => [500, 700,1000,200,500,200],
			:p    => [30,40,50,10,30,10],
			:n    => [32,32,32,16,16,8],
			:errs => [16,8,0,8,0,0]},
		'D' => {
			:type => ["accurate"],
			:u    => [Float::INFINITY],
			:d    => [1],
			:g    => [20],
			:p    => [3],
			:n    => [32],
			:errs => [0] },
		'@' => {
			:type => ["accurate"],
			:u    => [Float::INFINITY],
			:d    => [1],
			:g    => [20],
			:p    => [3],
			:n    => [32],
			:errs => [0] },
		}
		MIN = true#constant for minimum linear programming
		MAX = false#constant for maximum linear programming
		def initialize(g, parameters = {} )
			mobility_constrainted = true
			no_resource_limit = true
			error_bound = Math::log(1 - 0.01) 
			tq = 2
			if parameters[:q] == nil then q = nil else q = parameters[:q] end

			if parameters[:mobility_constrainted] == nil then mobility_constrainted = mobility_constrainted
			else mobility_constrainted = false end

			if parameters[:no_resource_limit] == nil then no_resource_limit = no_resource_limit
			else no_resource_limit = true end

			operations            = [] 

			if parameters[:error_bound] == nil then error_bound = Math::log(1 - 0.01)
			else error_bound = parameters[:error_bound] end

			if parameters[:times_q] == nil then tq = 2
			else tq = parameters[:times_q]  end

			@q = q
			@bits = g.p[:n]
			@vertex = g.p[:v]
			@edge   = g.p[:e]
			@mC     = mobility_constrainted
			@u      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:u] ]} ]
			@ui     = @vertex.map.with_index {|v,i| # the index of implementation
				[*0..DEFAULT_OPERATION_PARAMETERS[v][:n].length - 1].select{|ii| 
					DEFAULT_OPERATION_PARAMETERS[v][:n][ii] >= @bits[i] }}
			@d      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:d] ]} ]
			@di     = @ui.map.with_index{ |uii,i|
				uii.map{|u,ii| DEFAULT_OPERATION_PARAMETERS[@vertex[i]][:d][u] } }
		#	@g      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:g] ]} ]
			@gi     = @ui.map.with_index{ |uii,i|
				uii.map{|u,ii| DEFAULT_OPERATION_PARAMETERS[@vertex[i]][:g][u] } }
		#	@p      = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:p] ]} ]
			@pi     = @ui.map.with_index{ |uii,i|
				uii.map{|u,ii| DEFAULT_OPERATION_PARAMETERS[@vertex[i][:p][u]] } }
			@err    = Hash[DEFAULT_OPERATION_PARAMETERS.map{|k,v| [k, v[:err]]}]
			@errB = error_bound

			#get the vertices without vertices depending on
			@end = [*0..@vertex.length-1].map{|i| !@edge.map{|e| e[1]}.include?(i)}
			@end_vertex = [*0..@end.length - 1].select{|i| @end[i] == true}
			@PI_vertex = [*0..g.p[:PI].length - 1].select{|i| g.p[:PI][i] == true}
			@PO_vertex = [*0..g.p[:PO].length - 1].select{|i| g.p[:PO][i] == true}
			if (mobility_constrainted )
				ret = self.ASAP
				@critical_length = ret[:latency]
				if( @q == nil) then q = @q = @critical_length * tq end
				@asap = ret[:schedule]
				@alap = self.ALAP
				@mobility = @asap.map.with_index{|m,i| @alap[i] - @asap[i] }
				@Nx = @vertex.map.with_index{|v,i| @ui[i].length * (1 + @mobility[i]) }.reduce(0,:+) 
			else
				@Nx = @vertex.map{|v| @ui[i].length * q}.reduce(0,:+) 
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
			@Nerr = @vertex.length
			@Nu = @u.values.flatten.length 
			@Ns = @vertex.length
			@Ncolumn = @Nx + @Nerr + @Nu + @Ns
			@A = 
			@vertex.map.with_index{|v,i|		#Formula (2)  
				if(mobility_constrainted)
					start_point = [*0..i-1].map{|j| @ui[j].length * (1 + @mobility[j])  }.reduce(0, :+)
					#start_point = [*0..i-1].map{|j| @u[@vertex[j]].length * (1 + @mobility[j]) }.reduce(0,:+) 
					ntail = @Ncolumn - start_point - @ui[ j ].length * (1 + @mobility[i])
					Array.new(start_point, 0) + Array.new(@ui[ i ].length * (1 + @mobility[i]), 1) + Array.new(ntail, 0)
				else
					start_point = [*0..i-1].map{|j| @ui[j].length * q }.reduce(0,:+) 
					ntail = @Ncolumn - start_point - @ui[ i ].length * q
					Array.new(start_point, 0) + Array.new(@ui[ i ].length * q, 1) + Array.new(ntail, 0)
				end
			} +
			@vertex.map.with_index{|v,i|	#Formula (3)  
				if(mobility_constrainted)
					start_point = [*0..i-1].map{|j| @ui[j].length * (1 + @mobility[j]) }.reduce(0,:+) 
					xArray = [*@asap[i]..@alap[i] ].map{|t| Array.new(@ui[i].length, t)}.reduce([], :+) 
					ntail = @Nx - start_point - @ui[i].length * (1 + @mobility[i] )
				else
					start_point = [*0..i-1].map{|j| @ui[j].length * q }.reduce(0,:+) 
					xArray = [*0..q-1].map{|t| Array.new(@ui[i].length, t)}.reduce([], :+)
					ntail = @Nx - start_point - @ui[i].length * q
				end
				sArray = Array.new(@vertex.length,0)
				sArray[i] = -1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0) + Array.new(@Nu, 0) + sArray
			} +
			@edge.map{|e|	#Formula (4)  41
				if(mobility_constrainted)
					start_point = [*0..e[1]-1].map{|j| @ui[j].length * (1 + @mobility[j]) }.reduce(0,:+) 
					ntail = @Nx - start_point - @ui[ e[1] ].length * (1 + @mobility[e[1]])
					xArray = [*@asap[e[1]]..@alap[e[1]]].map{|t|     @di[ e[1] ]                  }.reduce([], :+) 
				else
					start_point = [*0..e[1]-1].map{|j| @ui[ j ].length * q }.reduce(0,:+) 
					ntail = @Nx - start_point - @ui[ e[1] ].length * q
					xArray = [*0..q-1].map{|t|     @di[ e[1] ]                  }.reduce([], :+) 
				end
				sArray = Array.new(@vertex.length,0)
				sArray[e[0]] = -1
				sArray[e[1]] = 1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)  + Array.new(@Nu, 0)+ sArray
			} +
			@end_vertex.map.with_index{|v,i|	#Formula (5)
				if(mobility_constrainted)
					start_point = [*0..v-1].map{|j| @ui[j]].length * (1+@mobility[j]) }.reduce(0,:+) 
					ntail = @Nx - start_point - @ui[v].length * (1+@mobility[v])
					xArray = [*@asap[v]..@alap[v]].map{|t|          @di[ v ]                      }.reduce([], :+)
				else
					start_point = [*0..v-1].map{|j| @ui[ j ].length * q }.reduce(0,:+) 
					ntail = @Nx - start_point - @ui[ v ].length * q
					xArray = [*0..q-1].map{|t|          @di[v ]                      }.reduce([], :+)
				end
				sArray = Array.new(@vertex.length,0)
				sArray[v] = 1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)  + Array.new(@Nu, 0)+ sArray
			} +
			@vertex.map.with_index{|v,i|			#Formula (6) (7) error
				if(mobility_constrainted)
					start_point = [*0..i-1].map{|j| @ui[j].length * (1+@mobility[j]) }.reduce(0,:+) 
					xArray = [*@asap[i]..@alap[i]].map{|t| #Array.new(@err[v])}.reduce([], :+) 
					ntail = @Nx - start_point - @u[v].length * (1+@mobility[i])
				else
					start_point = [*0..i-1].map{|j| @ui[j].length * q }.reduce(0,:+) 
					xArray = [*0..q-1].map{|t| #Array.new(@err[v])}.reduce([], :+) 
					ntail = @Nx - start_point - @ui[i].length * q
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
					@ui[xi].map.with_index{|u,m| if v == type and xt <= t and t <= xt + d - 1 and u == implementation then 1 else 0 end}
					}.reduce([],:+)}.reduce([],:+)
				else xArray = @vertex.map.with_index{|v,xi|	[*0..q - 1].map{|xt|
					@ui[xi].map.with_index{|u,m| if v == type and u == implementation and xt <= t and t <= xt + d - 1 then 1 else 0 end}
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
			@op 	= 	
				Array.new(@vertex.length, EQ)				+		#Formula (2)
				Array.new(@vertex.length, EQ)				+		#Formula (3)
				Array.new(@edge.length, LE)				+		#Formula (4)	
				Array.new(@end_vertex.length, LE )			+		#Formula (5)
				#Array.new(@vertex.length, EQ)				+		#Formula (6) (7)
				#Array.new(@PO_vertex.length, GE)			+		#Formula (8)
				Array.new(q * @u.values.flatten.length, LE)		+		#Formula (9)
				( if no_resource_limit == false then Array.new(@u.values.flatten.length, LE) else [] end)
			@b 	=
				Array.new(@vertex.length, 1)				+		#Formula (2)
				Array.new(@vertex.length, 0)				+		#Formula (3)
				Array.new(@edge.length, 0)				+		#Formula (4)	
				Array.new(@end_vertex.length, q)			+		#Formula (5)
				#Array.new(@vertex.length , 0)				+		#Formula (6) (7)
				#Array.new(@PO_vertex.length, @errB)			+		#Formula (8)
				Array.new(q * @u.values.flatten.length, 0)		+		#Formula (9)
				( if no_resource_limit == false then @u.values.flatten else [] end) 
			@c	=
				if(mobility_constrainted)
					@vertex.map.with_index{|v,xi|   [*@asap[xi]..@alap[xi]].map{|xt|   @g[v]   }.reduce([], :+)      }.reduce([], :+)
				else
					@vertex.map.with_index{|v,xi|   [*0..q-1].map{|xt|   @g[v]   }.reduce([], :+)      }.reduce([], :+)
				end							+		#xArray
				Array.new(@Nerr, 0)					+		#errArray
				@p.values.flatten.map{|p| p * q }			+		#uArray
				Array.new(@Ns, 0)							#sArray
			@int	=
				Array.new(@Nx, 'B')					+
				Array.new(@Nerr, 'C')				+
				Array.new(@Nu, 'I')					+ 
				Array.new(@Ns, 'I')
			@lb	=
				Array.new(@Nx, 0)					+
				Array.new(@Nerr, -Float::INFINITY)	+
				Array.new(@Nu, 0)					+
				Array.new(@Ns, 0)					
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
					time = index/ @u[ @vertex[i] ].length + @asap[i]#TODO need change
				else 
					current_length = @u[@vertex[i]].length * @q
					index = ret[:v][position, current_length].index(1)
					time = index/ @u[ @vertex[i] ].length + 0#TODO need change
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
						print sch[i][:op],sch[i][:id],': ', 'd', sch[i][:delay], 'e', 1 - Math::E**sch[i][:error], "   "
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
