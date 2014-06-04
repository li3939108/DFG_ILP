require_relative 'DFG_ILP'
require_relative 'ext/Parser'

p = DFG_ILP::Parser.new

p.parse "/home/me/DFG_ILP/dot/hal.dot"
print "vertices: ", p.p[:v].length, "\n", p.p[:v], "\n"
print "edges: ", p.p[:e].length, "\n", p.p[:e], "\n"
print "----------------------\n"
g = p.to_DFG
print "vertices: ", g.p[:v].length, "\n", g.p[:v], "\n"
print "edges: ", g.p[:e].length, "\n", g.p[:e], "\n"
