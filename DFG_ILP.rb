module DFG_ILP
	#load the C implemented extension ,i.e., ILP.bundle in MAC or ILP.so in others
	#note that this file can only be loaded after the module declaration of DFG_ILP
	LE = 1#constant for less than or equal in lp_solve
	GE = 2#constant for greater than or equal in lp_solve
	EQ = 3#constant for equal in lp_solve
	MIN = true#constant for minimum linear programming
	MAX = false#constant for maximum linear programming
	class GRAPH
		def dot(out)
			out.puts "digraph g {", "node [fontcolor=white,style=filled,color=blue2];"
			[*0..@vertex.length - 1].each{|v| out.puts "node_#{v+1} [label = \"#{@vertex[v]}#{v + 1}\"];"}
			@edge.each{|e| out.puts "node_#{e[1] + 1} -> node_#{e[0] + 1} ;"}
			out.puts "}"
		end
		def self.vs(sch, l)
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
				self.vs(sch, l + 1)
			end
		end
		def initialize()
			@edge = []
			@vertex = []
			@vertex_without_D = []
			@PI = []
			@PO = []

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
			q =                     nil,
			delay =                 {'+' => [1, 2],         'x' => [2, 3],          'D' => [1]}, #delay for every implementation of every operation types
			resource_bound =        {'+' => [1, 1],         'x' => [1, 1],          'D' => [400]} ,
			dynamic_energy =        {'+' => [200, 500],     'x' => [1000, 2000],    'D' => [100]}, #dynamic energy for every implementation of every operation types
			static_power =          {'+' => [10, 30],       'x' => [50, 100],       'D' => [3]}, #static power for every implementation of every operation types
			error =                 {'+' => [1, 0],         'x' => [1, 0],          'D' => [0]}, #error for every implementation of every operation types
			error_bound =           10, #error Bound on Primary Output
			mobility_constrainted = true)
			if q == nil
				@asap = g.ASAP(delay)				
				@alap = g.ALAP(delay)
				@mobility = [*0..@asap.length - 1].map{|i| @alap[i] - @asap[i] }
				alap_endtime = [*0..@alap.length - 1].map{|i| @alap[i] + delay[ g.p[:v][i] ].max }
				q = alap_endtime.max
				@q = q
			else
				@q = q
			end
			@U = resource_bound 
			@d = delay 
			@g = dynamic_energy
			@p = static_power
			@err = error
			@errB = error_bound
			@end = [*0..g.p[:v].length-1].map{|i| !g.p[:e].map{|e| e[1]}.include?(i)}#get the vertices without vertices depending on
			@end_vertex = [*0..@end.length - 1].select{|i| @end[i] == true}
			@PI_vertex = [*0..g.p[:PI].length - 1].select{|i| g.p[:PI][i] == true}
			@PO_vertex = [*0..g.p[:PO].length - 1].select{|i| g.p[:PO][i] == true}
			@Nrow =	
				g.p[:v].length +
				g.p[:v].length + 
				g.p[:e].length + 
				@end.count(true) +
				g.p[:v].count{|v| v != 'D'} + #error in D operation is ignored
				g.p[:PO].count(true) +
				q * @U.values.flatten.length +
				@U.values.flatten.length
			@Nx = g.p[:v].map{|v| @U[v].length * q}.reduce(:+) 
			@Nerr = g.p[:v].length
			@Nu = @U.values.flatten.length 
			@Ns = g.p[:v].length
			@Ncolumn = @Nx + @Nerr + @Nu + @Ns
			@A = 
			[*0..g.p[:v].length-1].map{|i|		#Formula (2)  
				start_point = [*0..i-1].map{|j| @U[g.p[:v][j]].length * q }.reduce(0,:+) 
				ntail = @Ncolumn - start_point - @U[g.p[:v][i]].length * q
				Array.new(start_point, 0) + Array.new(@U[g.p[:v][i]].length * q, 1) + Array.new(ntail, 0)
			} +
			[*0..g.p[:v].length - 1].map{|i|	#Formula (3)  
				start_point = [*0..i-1].map{|j| @U[g.p[:v][j]].length * q }.reduce(0,:+) 
				ntail = @Nx - start_point - @U[g.p[:v][i]].length * q
				sArray = Array.new(g.p[:v].length,0)
				sArray[i] = -1
				Array.new(start_point, 0) + [*0..q-1].map{|t| Array.new(@U[g.p[:v][i]].length, t)}.reduce([], :+) + Array.new(ntail, 0) + Array.new(@Nerr, 0) + Array.new(@Nu, 0) + sArray
			} +
			g.p[:e].map{|e|	#Formula (4)  41
				start_point = [*0..e[1]-1].map{|j| @U[g.p[:v][j]].length * q }.reduce(0,:+) 
				ntail = @Nx - start_point - @U[g.p[:v][e[1]]].length * q
				xArray = [*0..@U[g.p[:v][e[1]]].length * q - 1].map{|i| @d[g.p[:v][e[1]]][i % @U[g.p[:v][e[1]]].length] }
				sArray = Array.new(g.p[:v].length,0)
				sArray[e[0]] = -1
				sArray[e[1]] = 1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)  + Array.new(@Nu, 0)+ sArray
			} +
			[*0..@end_vertex.length - 1].map{|v|	#Formula (5)
				start_point = [*0..@end_vertex[v]-1].map{|j| @U[g.p[:v][j]].length * q }.reduce(0,:+) 
				ntail = @Nx - start_point - @U[g.p[:v][@end_vertex[v]]].length * q
				xArray = [*0..@U[g.p[:v][@end_vertex[v]]].length * q - 1].map{|i| @d[g.p[:v][@end_vertex[v]]][i % @U[g.p[:v][@end_vertex[v]]].length] }
				sArray = Array.new(g.p[:v].length,0)
				sArray[@end_vertex[v]] = 1
				Array.new(start_point, 0) + xArray + Array.new(ntail, 0) + Array.new(@Nerr, 0)  + Array.new(@Nu, 0)+ sArray
			} +
			[*0..g.p[:v].length - 1].map{|v|			#Formula (6) (7)
				start_point = [*0..v-1].map{|j| @U[g.p[:v][j]].length * q }.reduce(0,:+) 
				ntail = @Nx - start_point - @U[g.p[:v][v]].length * q
				errArray = Array.new(@Nerr, 0)
				errArray[v] = -1
				if g.p[:PI][v] == false
					g.p[:e].select{|e| e[0] == v}.each{|e| errArray[e[1] ] = 1}	
				end
				Array.new(start_point, 0) + [*0..q-1].map{|t| Array.new(@err[g.p[:v][v]])}.reduce([], :+) + Array.new(ntail, 0) + errArray + Array.new(@Nu, 0) + Array.new(@Ns, 0)
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
				xArray = 
				[*0..g.p[:v].length - 1].map{|xi|
					[*0..q - 1].map{|xt|
						[*0..@U[g.p[:v][xi]].length - 1].map{|m|
							if g.p[:v][xi] == type and xt <= t and t <= xt + d - 1 and m == implementation
								1
							else
								0
							end
						}
					}.reduce([],:+)
				}.reduce([],:+)
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
				Array.new(g.p[:v].length, EQ)				+		#Formula (2)
				Array.new(g.p[:v].length, EQ)				+		#Formula (3)
				Array.new(g.p[:e].length, LE)				+		#Formula (4)	
				Array.new(@end_vertex.length, LE )			+		#Formula (5)
				Array.new(g.p[:v].length, EQ)				+
				Array.new(@PO_vertex.length, LE)			+		#Formula (8)
				Array.new(q * @U.values.flatten.length, LE)	+		#Formula (9)
				Array.new(@U.values.flatten.length, LE)
			@b 	=
				Array.new(g.p[:v].length, 1)				+		#Formula (2)
				Array.new(g.p[:v].length, 0)				+		#Formula (3)
				Array.new(g.p[:e].length, 0)				+		#Formula (4)	
				Array.new(@end_vertex.length, q)			+		#Formula (5)
				Array.new(g.p[:v].length , 0)				+		#Formula (6) (7)							
				Array.new(@PO_vertex.length, @errB)			+		#Formula (8)
				Array.new(q * @U.values.flatten.length, 0)		+		#Formula (9)
				@U.values.flatten
			@c	=
				[*0..g.p[:v].length - 1].map{|xi|
					[*0..q - 1].map{|xt|
						@g[g.p[:v][xi]]
					}.reduce([], :+)
				}.reduce([], :+)					+		#xArray
				Array.new(@Nerr, 0)					+		#errArray
				@p.values.flatten.map{|p| p * (1 + q) }		+		#uArray
				Array.new(@Ns, 0)							#sArray
		end

		def p
			{
				:A => @A, 
				:op => @op, 
				:b => @b,
				:c => @c
			}
		end
		def compute(g)
			ret = DFG_ILP::cplex(@A, @op, @b, @c, true)
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
			for i in [*0..g.p[:v].length-1]	do
				current_length = @U[g.p[:v][i]].length * @q
				index = ret[:v][position, current_length].index(1)
				time = index/ @U[ g.p[:v][i] ].length 
				type = index% @U[g.p[:v][i]].length 
				error = ret[:v][err_position]
				schedule = schedule + [{:id => i + 1, :op => g.p[:v][i], :time => time, :type => type, :error => error, :delay => @d[ g.p[:v][i] ][ type ] }]				
				position = position + current_length
				err_position = err_position + 1
			end
			print	"\n", "optimal value: ", ret[:o], "\n", "number of constraints: ", ret[:c].length, "\n", "number of variables: ", ret[:v].length, "\n", 
				"allocation: ", allocation, "\n"
			return {:opt => ret[:o], :sch => schedule}
		end
	end
	require './ILP.so'
end
