require 'ILP'
module DFG_ILP
	class GRAPH
		def initialize()
			@edge = []
			@vertex = []
			@errB = 0 #error Bound on Primary Output
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
				[x * vertex2.count, x * vertex2.count - 1]
			} +
			[[section2 * vertex2.count, section2 * vertex2.count - 1]]
		end


		def v
			@vertex
		end
		def e
			@edge
		end

		
		public :initialize, :v, :e, :IIR
	end
	
	class ILP
		@Q = 0 #Longest Latency
		@U = {'+' => [0, 0], 'x' => [0, 0]} #Resource Bound
	end
end
