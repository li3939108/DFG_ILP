require '../DFG_ILP.rb'
require './Parser.so'

p = DFG_ILP::Parser.new
p.parse "../dot/hal.dot"
print "vertices: ", p.p[:v].length, "\n", p.p[:v], "\n"
print "edges: ", p.p[:e].length, "\n", p.p[:e], "\n"
