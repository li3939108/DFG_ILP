require_relative 'DFG_ILP'
require_relative 'ext/Parser'

p = DFG_ILP::Parser.new

p.parse "/home/me/DFG_ILP/dot/hal.dot"
print "vertices: ", p.p[:v].length, "\n", p.p[:v], "\n"
print "edges: ", p.p[:e].length, "\n", p.p[:e], "\n"
print "----------------------\n"
print p.to_DFG, "\n----------------------\n"
print "vertices: ", p.to_DFG[:v].length, "\n", p.to_DFG[:v], "\n"
print "edges: ", p.to_DFG[:e].length, "\n", p.to_DFG[:e], "\n"
