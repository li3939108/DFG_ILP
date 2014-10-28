module DFG_ILP
	class Vertex_precedence
		def initialize(n = 0, t = '@', adj_list = [] )
			@number = n
			@adjacency_list = adj_list 
			@type = t
		end
		def n
			@number
		end
		def adj
			@adjacency_list
		end
		def adj_push(v)
			@adjacency_list.push(v)
		end
		def inspect
			[@number, @type, 
				@adjacency_list.map{|v| v.n } ]
		end
	end

	class AST_Vertex
		def initialize(n = 0, t = '@', children = [])
			@number = n
			@type = t
			@children = children
		end
		def children_push(v)
			@children.push(v)
		end
		def inspect
			[@number, @type, 
				@children.map{|v| v.n} ]
		end
	end
	class AST
		def initialize(p = nil)
			@vertex_list = []
		end

	end
	class GRAPH
		def write_dot(out)
			out.puts "digraph g {", "node [fontcolor=white,style=filled,color=blue2];"
			[*0..@vertex.length - 1].each{|v| out.puts "node_#{v+1} [label = \"#{@vertex[v]}#{v + 1}\"];"}
			@edge.each{|e| out.puts "node_#{e[1] + 1} -> node_#{e[0] + 1} ;"}
			out.puts "}"
		end
		def initialize(p = nil)
			if p != nil and p[:e] != nil then @edge = p[:e]
			else @edge = [] end
			if p != nil and p[:v] != nil then @vertex = p[:v] 
			else @vertex = [] end
			if p != nil and p[:name] != nil then @name = p[:name] 
			else @name = nil end
			if @edge.length != 0 and @vertex.length != 0
				@PI = @vertex.map.with_index{|v,i| !@edge.map{|e| e[0]}.include?(i) and v != 'D'}
				@PO = @vertex.map.with_index{|v,i| 
				@edge.select{|e| e[1] == i}.select{|e| 
					@vertex[e[0]] != 'D'}.empty? and v != 'D'}
				@vertex_without_D = [*0..@vertex.length - 1].select{|i| @vertex[i] != 'D'}
				@vertex_adj_precedence = @vertex.map.with_index{|v,i|
					DFG_ILP::Vertex_precedence.new(i+1, v)
				}
				@vertex_AST = []
				@edge.each{|e|
					@vertex_adj_precedence[ e[1] ].adj_push(
						@vertex_adj_precedence[ e[0] ] )
				}
				
			else
				@PI = []
				@PO = []
				@vertex_without_D = [] 
			end
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
			[*0..section1-1].map{|x| edge1.map{|edge|
				edge.map{|v|
					v + vertex1.count * x + vertex2.count * section2} }
			}.flatten(1) +
			[*1..section2-1].map{|x|
				[x * vertex2.count, x * vertex2.count - 6]
			} +
			(section1 == 0 ? [] : [[section2 * vertex2.count, section2 * vertex2.count - 6]])
			@PI = [*0..@vertex.length-1].map{|i| 
				!@edge.map{|e| e[0]}.include?(i) and @vertex[i] != 'D'}
			@PO = [*0..@vertex.length-1].map{|i| @edge.select{|e| 
				e[1] == i}.select{|e| 
					@vertex[e[0]] != 'D'}.empty? and @vertex[i] != 'D'}
			@vertex_without_D = [*0..@vertex.length - 1].select{|i| @vertex[i] != 'D'}
			@name = "IIR4"
		end
		def arf_AST
			randgen = Random.new(Time.new.to_i)
			@vertex_AST.push(AST_Vertex.new(       ) )
			@vertex_AST.push(AST_Vertex.new(1  ,'x') )
			@vertex_AST.push(AST_Vertex.new(2  ,'x') )
			@vertex_AST.push(AST_Vertex.new(3  ,'x') )
			@vertex_AST.push(AST_Vertex.new(4  ,'x') )
			@vertex_AST.push(AST_Vertex.new(5  ,'x') )
			@vertex_AST.push(AST_Vertex.new(6  ,'x') )
			@vertex_AST.push(AST_Vertex.new(7  ,'x') )
			@vertex_AST.push(AST_Vertex.new(8  ,'x') )
			@vertex_AST.push(AST_Vertex.new(9  ,'+') )
			@vertex_AST.push(AST_Vertex.new(10 ,'+') )
			@vertex_AST.push(AST_Vertex.new(11 ,'+') )
			@vertex_AST.push(AST_Vertex.new(12 ,'+') )
			@vertex_AST.push(AST_Vertex.new(13 ,'+') )
			@vertex_AST.push(AST_Vertex.new(14 ,'+') )
			@vertex_AST.push(AST_Vertex.new(15 ,'x') )
			@vertex_AST.push(AST_Vertex.new(16 ,'x') )
			@vertex_AST.push(AST_Vertex.new(17 ,'x') )
			@vertex_AST.push(AST_Vertex.new(18 ,'x') )
			@vertex_AST.push(AST_Vertex.new(19 ,'+') )
			@vertex_AST.push(AST_Vertex.new(20 ,'+') )
			@vertex_AST.push(AST_Vertex.new(21 ,'x') )
			@vertex_AST.push(AST_Vertex.new(22 ,'x') )
			@vertex_AST.push(AST_Vertex.new(23 ,'x') )
			@vertex_AST.push(AST_Vertex.new(24 ,'x') )
			@vertex_AST.push(AST_Vertex.new(25 ,'+') )
			@vertex_AST.push(AST_Vertex.new(26 ,'+') )
			@vertex_AST.push(AST_Vertex.new(27 ,'+') )
			@vertex_AST.push(AST_Vertex.new(28 ,'+') )
			@vertex_AST.push(AST_Vertex.new(29 ,'i') )
			@vertex_AST.push(AST_Vertex.new(30 ,'i') )
			@vertex_AST.push(AST_Vertex.new(31 ,'i') )
			@vertex_AST.push(AST_Vertex.new(32 ,'i') )
			@vertex_AST.push(AST_Vertex.new(33 ,'i') )
			@vertex_AST.push(AST_Vertex.new(34 ,'i') )
			@vertex_AST.push(AST_Vertex.new(35 ,'i') )
			@vertex_AST.push(AST_Vertex.new(36 ,'i') )
			@vertex_AST.push(AST_Vertex.new(37 ,'i') )
			@vertex_AST.push(AST_Vertex.new(38 ,'i') )
			@vertex_AST.push(AST_Vertex.new(39 ,'i') )
			@vertex_AST.push(AST_Vertex.new(40 ,'i') )
			@vertex_AST.push(AST_Vertex.new(41 ,'i') )
			@vertex_AST.push(AST_Vertex.new(42 ,'i') )
			@vertex_AST.push(AST_Vertex.new(43 ,'i') )
			@vertex_AST.push(AST_Vertex.new(44 ,'i') )
			@vertex_AST.push(AST_Vertex.new(45 ,'i') )
			@vertex_AST.push(AST_Vertex.new(46 ,'i') )
			@vertex_AST.push(AST_Vertex.new(47 ,'i') )
			@vertex_AST.push(AST_Vertex.new(48 ,'i') )
			@vertex_AST.push(AST_Vertex.new(49 ,'i') )
			@vertex_AST.push(AST_Vertex.new(50 ,'i') )
			@vertex_AST.push(AST_Vertex.new(51 ,'i') )
			@vertex_AST.push(AST_Vertex.new(52 ,'i') )
			@vertex_AST.push(AST_Vertex.new(53 ,'i') )
			@vertex_AST.push(AST_Vertex.new(54 ,'i') )
			@vertex_AST[27].children = [@vertex_AST[9], @vertex_AST[25] ]
			@vertex_AST[9].children =  [@vertex_AST[1], @vertex_AST[2]  ]
			@vertex_AST[25].children = [@vertex_AST[21], @vertex_AST[22]]
			@vertex_AST[1].children =  [@vertex_AST[29], @vertex_AST[30]]
			@vertex_AST[2].children =  [@vertex_AST[31], @vertex_AST[32]   ]
			@vertex_AST[21].children = [@vertex_AST[19], @vertex_AST[33]   ]
			@vertex_AST[22].children = [@vertex_AST[20],  @vertex_AST[34]  ]
			@vertex_AST[28].children = [@vertex_AST[12], @vertex_AST[26]]
			@vertex_AST[12].children = [@vertex_AST[7],  @vertex_AST[8] ]
			@vertex_AST[26].children = [@vertex_AST[23], @vertex_AST[24]]
			@vertex_AST[7].children =  [ @vertex_AST[35], @vertex_AST[36] ]
			@vertex_AST[8].children =  [ @vertex_AST[37], @vertex_AST[38]]
			@vertex_AST[23].children = [@vertex_AST[19], @vertex_AST[39]]
			@vertex_AST[24].children = [@vertex_AST[20], @vertex_AST[40]]
			@vertex_AST[19].children = [@vertex_AST[15],@vertex_AST[16] ]
			@vertex_AST[20].children = [@vertex_AST[17],@vertex_AST[18] ]
			@vertex_AST[15].children = [@vertex_AST[13],@vertex_AST[41]    ]
			@vertex_AST[16].children = [@vertex_AST[14], @vertex_AST[42]   ]
			@vertex_AST[17].children = [@vertex_AST[13],  @vertex_AST[43]  ]
			@vertex_AST[18].children = [@vertex_AST[14],  @vertex_AST[44]  ]
			@vertex_AST[13].children = [@vertex_AST[10],  @vertex_AST[45]  ]
			@vertex_AST[14].children = [@vertex_AST[11],   @vertex_AST[46] ]
			@vertex_AST[10].children = [@vertex_AST[3], @vertex_AST[4]  ]
			@vertex_AST[11].children = [@vertex_AST[5], @vertex_AST[6]  ]
			@vertex_AST[3].children =  [@vertex_AST[47], @vertex_AST[48] ]
			@vertex_AST[4].children =  [ @vertex_AST[49], @vertex_AST[50] ]
			@vertex_AST[5].children =  [  @vertex_AST[51], @vertex_AST[52] ]
			@vertex_AST[6].children =  [@vertex_AST[53], @vertex_AST[54]        ]
			@vertex_AST 
		end
		def p
			{
				:v => @vertex, 
				:e => @edge, 
				:PI => @PI, 
				:PO => @PO, 
				:vNoD => @vertex_without_D, 
				:name => @name,
				:adj => @vertex_adj_precedence,
			}
		end
	end
end
