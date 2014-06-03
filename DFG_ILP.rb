module DFG_ILP
	#load the C implemented extension ,i.e., ILP.bundle in MAC or ILP.so in others
	#note that this file can only be loaded after the module declaration of DFG_ILP
	MIN = true#constant for minimum linear programming
	MAX = false#constant for maximum linear programming
	class GRAPH
		def read_dot(input)
			
		end
		def write_dot(out)
			out.puts "digraph g {", "node [fontcolor=white,style=filled,color=blue2];"
			[*0..@vertex.length - 1].each{|v| out.puts "node_#{v+1} [label = \"#{@vertex[v]}#{v + 1}\"];"}
			@edge.each{|e| out.puts "node_#{e[1] + 1} -> node_#{e[0] + 1} ;"}
			out.puts "}"
		end
		def initialize()
			@edge = []
			@vertex = []
			@vertex_without_D = []
			@PI = []
			@PO = []

		end
		def ewf
		#	@vertex = [
		end
		def IIR(order)
			vertex2 = ['x', '+', '+', '+', '+', 'D', 'x', 'x', 'D', 'x']
			edge2 = [[1,0],[1,6],[2,1],[2,9],[3,2],[3,7],[4,3],[5,2],[5,6],[5,7],[5,8],[8,9],[8,4]]
			vertex1 = ['x', '+', '+', 'D', 'x']
			edge1 = [[1,0],[1,4],[2,1],[3,1],[3,2],[3,4]]
			section2 = order / 2
			section1 = order % 2
			@vertex = vertex2 * section2 + vertex1 * section1
			@edge = 
			[*0..section2-1].map{|x| #[0,1,2,...,section2 - 1]
				edge2.map{|edge|
					edge.map{|v|
						v + vertex2.count * x
					}
				}
			}.flatten(1) + 
			[*0..section1-1].map{|x|
				edge1.map{|edge|
					edge.map{|v|
						v + vertex1.count * x + vertex2.count * section2
					}
				}
			}.flatten(1) +
			[*1..section2-1].map{|x|
				[x * vertex2.count, x * vertex2.count - 6]
			} +
			(section1 == 0 ? [] : [[section2 * vertex2.count, section2 * vertex2.count - 6]])
			@PI = [*0..@vertex.length-1].map{|i| !@edge.map{|e| e[0]}.include?(i) and @vertex[i] != 'D'}
			@PO = [*0..@vertex.length-1].map{|i| @edge.select{|e| e[1] == i}.select{|e| @vertex[e[0]] != 'D'}.empty? and @vertex[i] != 'D'}
			@vertex_without_D = [*0..@vertex.length - 1].select{|i| @vertex[i] != 'D'}
		end

		def p
			{
				:v => @vertex, 
				:e => @edge, 
				:PI => @PI, 
				:PO => @PO, 
				:vNoD => @vertex_without_D, 
			}
		end
	end
	
	class ILP
		def initialize(
			g, 
			q =                     20,
			mobility_constrainted = false,
			resource_bound =        {'+' => [1, 1],         'x' => [1, 1],          'D' => [400]} ,
			delay =                 {'+' => [1, 2],         'x' => [2, 3],          'D' => [1]}, #delay for every implementation of every operation types
			dynamic_energy =        {'+' => [200, 500],     'x' => [1000, 2000],    'D' => [100]}, #dynamic energy for every implementation of every operation types
			static_power =          {'+' => [10, 30],       'x' => [50, 100],       'D' => [3]}, #static power for every implementation of every operation types
			error =                 {'+' => [1, 0],         'x' => [1, 0],          'D' => [0]}, #error for every implementation of every operation types
			error_bound =           10 #error Bound on Primary Output
			)
			@q = q
			@vertex = g.p[:v]
			@edge = g.p[:e]
			@mC = mobility_constrainted
			@U = resource_bound 
			@d = delay 
			@g = dynamic_energy
			@p = static_power
			@err = error
			@errB = error_bound
			@end = [*0..@vertex.length-1].map{|i| !@edge.map{|e| e[1]}.include?(i)}#get the vertices without vertices depending on
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
				q * @U.values.flatten.length +
				@U.values.flatten.length
			if (mobility_constrainted )
				@asap = self.ASAP
				@alap = self.ALAP
				@mobility = @asap.map.with_index{|m,i| @alap[i] - @asap[i] }
				@Nx = @vertex.map.with_index{|v,i| @U[v].length * (1 + @mobility[i]) }.reduce(0,:+) 
			else
				@Nx = @vertex.map{|v| @U[v].length * q}.reduce(0,:+) 
			end
			@Nerr = @vertex.length
			@Nu = @U.values.flatten.length 
			@Ns = @vertex.length
			@Ncolumn = @Nx + @Nerr + @Nu + @Ns
			@A = 
			@vertex.map.with_index{|v,i|		#Formula (2)  
				if(mobility_constrainted)
					start_point = [*0..i-1].map{|j| @U[@vertex[j]].length * (1 + @mobility[j]) }.reduce(0,:+) 
					ntail = @Ncolumn - start_point - @U[ v ].length * (1 + @mobility[i])
					Array.new(start_point, 0) + Array.new(@U[ v ].length * (1 + @mobility[i]), 1) + Array.new(ntail, 0)
				else
					start_point = [*0..i-1].map{|j| @U[@vertex[j]].length * q }.reduce(0,:+) 
					ntail = @Ncolumn - start_point - @U[ v ].length * q
					Array.new(start_point, 0) + Array.new(@U[ v ].length * q, 1) + Array.new(ntail, 0)
				end
			} +
			@vertex.map.with_index{|v,i|	#Formula (3)  
				if(mobility_constrainted)
					start_point = [*0..i-1].map{|j| @U[@vertex[j]].length * (1 + @mobility[j]) }.reduce(0,:+) 
					xArray = [*@asap[i]..@alap[i] ].map{|t| Array.new(@U[v].length, t)}.reduce([], :+) 
					ntail = @Nx - start_point - @U[v].length * (1 + @mobility[i] )
				else
					start_point = [*0..i-1].map{|j| @U[@vertex[j]].length * q }.reduce(0,:+) 
					xArray = [*0..q-1].map{|t| Array.new(@U[v].length, t)}.reduce([], :+)
					ntail = @Nx - start_point - @U[v].length * q
				end
				sArray = Array.new(@vertex.length,0)
				sArray[i] = -1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0) + Array.new(@Nu, 0) + sArray
			} +
			@edge.map{|e|	#Formula (4)  41
				if(mobility_constrainted)
					start_point = [*0..e[1]-1].map{|j| @U[@vertex[j]].length * (1 + @mobility[j]) }.reduce(0,:+) 
					ntail = @Nx - start_point - @U[@vertex[e[1]]].length * (1 + @mobility[e[1]])
					xArray = [*@asap[e[1]]..@alap[e[1]]].map{|t|     @d[@vertex[e[1]]]                  }.reduce([], :+) 
				else
					start_point = [*0..e[1]-1].map{|j| @U[@vertex[j]].length * q }.reduce(0,:+) 
					ntail = @Nx - start_point - @U[@vertex[e[1]]].length * q
					xArray = [*0..q-1].map{|t|     @d[@vertex[e[1]]]                  }.reduce([], :+) 
				end
				sArray = Array.new(@vertex.length,0)
				sArray[e[0]] = -1
				sArray[e[1]] = 1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)  + Array.new(@Nu, 0)+ sArray
			} +
			@end_vertex.map.with_index{|v,i|	#Formula (5)
				if(mobility_constrainted)
					start_point = [*0..v-1].map{|j| @U[@vertex[j]].length * (1+@mobility[j]) }.reduce(0,:+) 
					ntail = @Nx - start_point - @U[@vertex[v]].length * (1+@mobility[v])
					xArray = [*@asap[v]..@alap[v]].map{|t|          @d[@vertex[v]]                      }.reduce([], :+)
				else
					start_point = [*0..v-1].map{|j| @U[@vertex[j]].length * q }.reduce(0,:+) 
					ntail = @Nx - start_point - @U[@vertex[v]].length * q
					xArray = [*0..q-1].map{|t|          @d[@vertex[v]]                      }.reduce([], :+)
				end
				sArray = Array.new(@vertex.length,0)
				sArray[v] = 1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)  + Array.new(@Nu, 0)+ sArray
			} +
			@vertex.map.with_index{|v,i|			#Formula (6) (7)
				if(mobility_constrainted)
					start_point = [*0..i-1].map{|j| @U[@vertex[j]].length * (1+@mobility[j]) }.reduce(0,:+) 
					xArray = [*@asap[i]..@alap[i]].map{|t| Array.new(@err[v])}.reduce([], :+) 
					ntail = @Nx - start_point - @U[v].length * (1+@mobility[i])
				else
					start_point = [*0..i-1].map{|j| @U[@vertex[j]].length * q }.reduce(0,:+) 
					xArray = [*0..q-1].map{|t| Array.new(@err[v])}.reduce([], :+) 
					ntail = @Nx - start_point - @U[v].length * q
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
			[*0..q * @U.values.flatten.length - 1].map{|row_i|	#Formula (9)
				t = row_i / @U.values.flatten.length
				di = row_i % @U.values.flatten.length
				d = @d.values.flatten[di]
				flattenUtype = @U.keys.map{|k| Array.new(@U[k].length, k)}.reduce([],:+)
				flattenUimplementation = @U.keys.map{|k| [*0..@U[k].length - 1]}.reduce([], :+)
				type = flattenUtype[di]
				implementation = flattenUimplementation[di]
				if(mobility_constrainted) then xArray =	@vertex.map.with_index{|v,xi| [*@asap[xi]..@alap[xi]].map{|xt| 
					@U[v].map.with_index{|u,m| if v == type and xt <= t and t <= xt + d - 1 and m == implementation then 1 else 0 end}
					}.reduce([],:+)}.reduce([],:+)
				else xArray = @vertex.map.with_index{|v,xi|	[*0..q - 1].map{|xt|
					@U[v].map.with_index{|u,m| if v == type and m == implementation and xt <= t and t <= xt + d - 1 then 1 else 0 end}
					}.reduce([],:+)}.reduce([],:+)
				end
				uArray = Array.new(@Nu, 0)
				uArray[di] = -1
				xArray + Array.new(@Nerr, 0) + uArray + Array.new(@Ns, 0) 
			} +
			[*0..@U.values.flatten.length - 1].map{|u|
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
				Array.new(q * @U.values.flatten.length, LE)		+		#Formula (9)
				Array.new(@U.values.flatten.length, LE)
			@b 	=
				Array.new(@vertex.length, 1)				+		#Formula (2)
				Array.new(@vertex.length, 0)				+		#Formula (3)
				Array.new(@edge.length, 0)				+		#Formula (4)	
				Array.new(@end_vertex.length, q)			+		#Formula (5)
				Array.new(@vertex.length , 0)				+		#Formula (6) (7)							
				Array.new(@PO_vertex.length, @errB)			+		#Formula (8)
				Array.new(q * @U.values.flatten.length, 0)		+		#Formula (9)
				@U.values.flatten
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
			@U.keys.each{|k|
				allocation[k] = @U[k].map{|u|
					position = position + 1
					ret[:v][position]
				}
			}
	
			schedule = []
			position = 0
			err_position =  @Nx 
			for i in [*0..@vertex.length-1]	do
				if(@mC)
					current_length = @U[@vertex[i]].length * (1+@mobility[i]) 
					index = ret[:v][position, current_length].index(1)
					time = index/ @U[ @vertex[i] ].length + @asap[i]
				else 
					current_length = @U[@vertex[i]].length * @q
					index = ret[:v][position, current_length].index(1)
					time = index/ @U[ @vertex[i] ].length + 0
				end
				type = index% @U[@vertex[i]].length 
				error = ret[:v][err_position]
				schedule = schedule + [{:id => i + 1, :op => @vertex[i], :time => time, :type => type, :error => error, :delay => @d[ @vertex[i] ][ type ] }]				
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

	end
	require_relative 'ILP'
end
