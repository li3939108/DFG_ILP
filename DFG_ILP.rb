module DFG_ILP
	require './ILP.so'#load the C implemented extension ,i.e., ILP.bundle in MAC or ILP.so in others
	LE = 1#constant for less than or equal in lp_solve
	GE = 2#constant for greater than or equal in lp_solve
	EQ = 3#constant for equal in lp_solve
	MIN = true#constant for minimum linear programming
	MAX = false#constant for maximum linear programming
	class GRAPH
		def initialize()
			@edge = []
			@vertex = []
			@PI = []
			@PO = []
			@errB = 10 #error Bound on Primary Output
			@Q = 60 #Longest Latency
			@U = {'+' => [1, 1], 'x' => [1, 1], 'D' => 4} #Resource Bound
			@d = {'+' => [1, 2], 'x' => [2, 3], 'd' => [1]} #delay for every implementation of every operation types
			@g = {'+' => [2, 5], 'x' => [10, 20], 'D' => [1]} #dynamic energy for every implementation of every operation types
			@p = {'+' => [1, 3], 'x' => [10, 20], 'D' => [0]} #static power for every implementation of every operation types
			@e = {'+' => [1, 0], 'x' => [1, 0], 'D' => [0]} #error for every implementation of every operation types
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
		end

		def p
			{:v => @v, :e => vertex, :PI => @PI, :PO => @PO, :U => @U, :Q =>@Q}
		end
	end
	
	class ILP
		def initialize(g)
			@end = [*0..g.v.length-1].map{|i| !g.e.map{|e| e[1]}.include?(i)}#get the vertices without vertices depending on
			@Nrow =	1 +
				g.v.length + 
				g.e.length + 
				@end.count(true) +
				g.p[:v].count{|v| v != 'D'} + #error in D operation is ignored
				g.p[:PO].count(true) +
				g.p[:Q] * g.p[:U].values.flatten.length +
				g.p[:U].values.flatten.length
			@Nx = g.p[:v].map{|v| g.p[:U][v].length}.reduce(:+) * g.p[:Q]
			@Ne = g.p[:v]
			@Nu = g.p[:U].values.flatten.length 
			@Ncolumn = @Nx + @Ne + @Nu
		end
	end
end
