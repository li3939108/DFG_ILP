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
