module DFG_ILP
	LE = 1#constant for less than or equal in lp_solve
	GE = 2#constant for greater than or equal in lp_solve
	EQ = 3#constant for equal in lp_solve
	MIN = true#constant for minimum linear programming
	MAX = false#constant for maximum linear programming
	class GRAPH
		def initialize()
			@edge = []
			@vertex = []
			@errB = 10 #error Bound on Primary Output
			@Q = 100 #Longest Latency
			@U = {'+' => [1, 1], 'x' => [1, 1], 'D' => 4} #Resource Bound
			@d = {'+' => [1, 2], 'x' => [2, 3], 'd' => [1]} #delay for every implementation of every operation types
			@g = {'+' => [2, 5], 'x' => [10, 20], 'D' => [1]} #dynamic energy for every implementation of every operation types
			@p = {'+' => [1, 3], 'x' => [10, 20], 'D' => [0]} #static power for every implementation of every operation types
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
	end
end

require 'ILP'#load the C implemented extension ILP.bundle in mac or ILP.so 
