require "rake"

Gem::Specification.new do |s|
  s.name        = 'dft_ilp'
  s.version     = '0.0.1pre'
  s.summary     = "Using Integer Linear Programming to do Scheduling, binding and allocation"
  s.description = s.summary + ", including ruby interface to CPLEX, Gurobi and lp_solve"
  s.license     = "MIT"
  s.date        = '2014-05-06'
  s.authors     = ["Chaofan Li"]
  s.email       = "chaof@tamu.edu"
  s.files       = FileList["lib/*/*", "lib/*", "ext/*", "ext/*/*", "ext/include/*", "Rakefile"].to_a
  s.extensions << "ext/ilp/extconf.rb"<<"ext/parser/extconf.rb"
end
