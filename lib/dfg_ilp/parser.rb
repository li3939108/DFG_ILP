module DFG_ILP
	class Parser
		def parse(path = nil )
			if path == nil then self.parse(@target) 
			else self._parse(path) end
		end 
		def initialize(t = nil)
			@target = t if t != nil
			@id = {}
			@result = {}
			@vertex = []
			@edge = []
			@name = nil
		end
		def p
			v = @vertex.map{|vertex| vertex[1] }
			{:v => v, :e => @edge, :name => @name }
		end
		def to_DFG
			v = self.p[:v].map{|attri|
				if attri["label"].include?("add") or
					attri["label"].include?("ADD") or 
					attri["label"].include?("sub") or 
					attri["label"].include?("SUB") or 
					attri["label"].include?("+") or 
					attri["label"].include?("les") or 
					attri["label"].include?("LES") or
					attri["label"].include?("LE") or 
					attri["label"].include?("le") or 
					attri["label"].include?("<") then "ALU"
				elsif attri["label"].include?("MUL") or	
					attri["label"].include?("mul") or 
					attri["label"].include?("x") then "x"
				else "@"
				end
			}
			e = @edge.map{|edge| edge.reverse }
			DFG_ILP::GRAPH.new( { :v => v, :e => e, :name => @name} )
		end
		require 'dfg_ilp/parser_ext'
	end
end
