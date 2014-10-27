module DFG_ILP
	class Vertex
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
		def arf
			@vertex_list.push(AST_Vertex.new(       ) )
			@vertex_list.push(AST_Vertex.new(1  ,'x') )
			@vertex_list.push(AST_Vertex.new(2  ,'x') )
			@vertex_list.push(AST_Vertex.new(3  ,'x') )
			@vertex_list.push(AST_Vertex.new(4  ,'x') )
			@vertex_list.push(AST_Vertex.new(5  ,'x') )
			@vertex_list.push(AST_Vertex.new(6  ,'x') )
			@vertex_list.push(AST_Vertex.new(7  ,'x') )
			@vertex_list.push(AST_Vertex.new(8  ,'x') )
			@vertex_list.push(AST_Vertex.new(9  ,'+') )
			@vertex_list.push(AST_Vertex.new(10 ,'+') )
			@vertex_list.push(AST_Vertex.new(11 ,'+') )
			@vertex_list.push(AST_Vertex.new(12 ,'+') )
			@vertex_list.push(AST_Vertex.new(13 ,'+') )
			@vertex_list.push(AST_Vertex.new(14 ,'+') )
			@vertex_list.push(AST_Vertex.new(15 ,'x') )
			@vertex_list.push(AST_Vertex.new(16 ,'x') )
			@vertex_list.push(AST_Vertex.new(17 ,'x') )
			@vertex_list.push(AST_Vertex.new(18 ,'x') )
			@vertex_list.push(AST_Vertex.new(19 ,'+') )
			@vertex_list.push(AST_Vertex.new(20 ,'+') )
			@vertex_list.push(AST_Vertex.new(21 ,'x') )
			@vertex_list.push(AST_Vertex.new(22 ,'x') )
			@vertex_list.push(AST_Vertex.new(23 ,'x') )
			@vertex_list.push(AST_Vertex.new(24 ,'x') )
			@vertex_list.push(AST_Vertex.new(25 ,'+') )
			@vertex_list.push(AST_Vertex.new(26 ,'+') )
			@vertex_list.push(AST_Vertex.new(27 ,'+') )
			@vertex_list.push(AST_Vertex.new(28 ,'+') )
			@vertex_list[27].children = [@vertex_list[9], @vertex_list[25] ]
			@vertex_list[9].children =  [@vertex_list[1], @vertex_list[2]  ]
			@vertex_list[25].children = [@vertex_list[21], @vertex_list[22]]
			@vertex_list[1].children =  [                                  ]
			@vertex_list[2].children =  [                                  ]
			@vertex_list[21].children = [@vertex_list[19],                 ]
			@vertex_list[22].children = [@vertex_list[20],                 ]
			@vertex_list[28].children = [@vertex_list[12], @vertex_list[26]]
			@vertex_list[12].children = [@vertex_list[7],  @vertex_list[8] ]
			@vertex_list[26].children = [@vertex_list[23], @vertex_list[24]]
			@vertex_list[7].children =  [                                  ]
			@vertex_list[8].children =  [                                  ]
			@vertex_list[23].children = [@vertex_list[19],                 ]
			@vertex_list[24].children = [@vertex_list[20],                 ]
			@vertex_list[19].children = [@vertex_list[15],@vertex_list[16] ]
			@vertex_list[20].children = [@vertex_list[17],@vertex_list[18] ]
			@vertex_list[15].children = [@vertex_list[13],                 ]
			@vertex_list[16].children = [@vertex_list[14],                 ]
			@vertex_list[17].children = [@vertex_list[13],                 ]
			@vertex_list[18].children = [@vertex_list[14],                 ]
			@vertex_list[13].children = [@vertex_list[10],                 ]
			@vertex_list[14].children = [@vertex_list[11],                 ]
			@vertex_list[10].children = [@vertex_list[3], @vertex_list[4]  ]
			@vertex_list[11].children = [@vertex_list[5], @vertex_list[6]  ]
			@vertex_list[3].children =  [                                  ]
			@vertex_list[4].children =  [                                  ]
			@vertex_list[5].children =  [                                  ]
			@vertex_list[6].children =  [                                  ]
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
				@vertex_adjacency_list = @vertex.map.with_index{|v,i|
					DFG_ILP::Vertex.new(i+1, v)
				}
				@edge.each{|e|
					@vertex_adjacency_list[ e[1] ].adj_push(
						@vertex_adjacency_list[ e[0] ] )
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
	
		def p
			{
				:v => @vertex, 
				:e => @edge, 
				:PI => @PI, 
				:PO => @PO, 
				:vNoD => @vertex_without_D, 
				:name => @name,
				:adj => @vertex_adjacency_list,
			}
		end
	end
end
