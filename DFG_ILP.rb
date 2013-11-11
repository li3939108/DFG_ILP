module DFG_ILP
	class GRAPH
		def initialize(graph)
			@edge = []
			@vertex = []
			@graph = graph
			@errB = 0 #error Bound on Primary Output
			set_node(@graph)
			set_edge(@graph)
		end
		
		def IIR_gen(order)
			vertex2 = ['x', '+', '+', '+', '+', 'D', 'x', 'x', 'D', 'x']
			edge2 = [[1,0],[1,6],[2,1],[2,9],[3,2],[3,7],[4,3],[5,2],[5,6],[5,7],[5,8],[8,9],[8,4]]
			vertex1 = ['x', '+', '+', 'D', 'x']
			edge1 = [[1,0],[1,4],[2,1],[3,1],[3,2],[3,4]]
			section2 = order / 2
			section1 = order % 2
			vertex = vertex2 * section2 + vertex1 * section1	
		end

		def set_node(graph)
			if @vertex.empty?
				graph['node'] = 1
			else
				graph['node'] = @vertex.last + 1
			end
			@vertex.push(graph['node'])
			if !graph['preceding'].empty?
				graph['preceding'].each {|g|
					set_node(g)
				}
			end
		end

		def set_edge(graph)
			if !graph['preceding'].empty?
				graph['preceding'].each {|g|
					@edge.push([g['node'],graph['node']])
					set_edge(g)
				}
			end
		end

		def v
			@vertex
		end
		def e
			@edge
		end

		
		public :initialize, :v, :e
		private :set_node, :set_edge
	end
	
	class ILP
		@Q = 0 #Longest Latency
		@U = {'+' => [0, 0], 'x' => [0, 0]} #Resource Bound
	end
end
