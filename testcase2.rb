#!/usr/bin/env ruby

require './DFG_ILP.rb'
g = DFG_ILP::GRAPH.new
g.IIR(4)
ret = g.ASAP
DFG_ILP::GRAPH.vs(ret, 0)
ret = g.ALAP
DFG_ILP::GRAPH.vs(ret, 0)
