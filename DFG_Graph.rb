module DFG_Graph
	class GRAPH
		def initialize(graph)
			@edge = []
			@vertex = []
			
		end
		
		def set_node( graph)
			if @vertex.empty?
				graph['node'] = 1
			else
				graph['node'] = @vertex.last + 1
				@vertex.push(graph['node'])
			end
			if !graph['preceding'].empty?
				graph['preceding'].each {|graph|
					set_node(@vertex, graph)
				}
			end
		end

		def get_edge(edge_list, graph)
			if !graph['preceding'].empty?
				edge_list.push(
			end
		end
		
		public :initialize
		private :get_edge, :set_node
	end
end
			
	
