require '../DFG_ILP.rb'
require './Parser.so'

p = DFG_ILP::Parser.new
p.parse "../dot/simple.dot"

