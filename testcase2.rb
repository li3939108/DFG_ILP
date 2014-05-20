#!/usr/bin/env ruby

require './DFG_ILP.rb'
g = DFG_ILP::GRAPH.new
g.IIR(4)
g.ASAP
g.ALAP
