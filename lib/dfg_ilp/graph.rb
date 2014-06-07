module DFG_ILP
	class GRAPH
		def read_dot(input)
			
		end
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
			if @edge.length != 0 and @vertex.length != 0
				@PI = @vertex.map.with_index{|v,i| !@edge.map{|e| e[0]}.include?(i) and v != 'D'}
				@PO = @vertex.map.with_index{|v,i| 
				@edge.select{|e| e[1] == i}.select{|e| 
					@vertex[e[0]] != 'D'}.empty? and v != 'D'}
				@vertex_without_D = [*0..@vertex.length - 1].select{|i| @vertex[i] != 'D'}
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
end
