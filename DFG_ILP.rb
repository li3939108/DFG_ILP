module DFG_ILP
	class GRAPH
		def initialize(graph)
			@edge = []
			@vertex = []
			set_node(graph)
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
			else
				return
			end
		end
		
		def print_node
			@vertex
		end

	#	def get_edge(edge_list, graph)
	#		if !graph['preceding'].empty?
	#			edge_list.push(
	#		end
	#	end
		
		public :initialize
		private :set_node
	end
end
			
	
