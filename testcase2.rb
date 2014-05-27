#!/usr/bin/env ruby

require './DFG_ILP.rb'
delay =       {'+' => [1, 2],         'x' => [2, 3],          'D' => [1]} #delay for every implementation of every operation types
g = DFG_ILP::GRAPH.new
g.IIR(4)
ret = g.ASAP(delay)
print "ASAP: ",ret,"\n"
#DFG_ILP::GRAPH.vs(ret, 0)
ret = g.ALAP(delay)
print "ALAP: ",ret,"\n"
#DFG_ILP::GRAPH.vs(ret, 0)
ret = g.M(delay)
print "Mobility: ", ret, "\n"
