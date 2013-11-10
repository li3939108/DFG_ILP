section1 = {"preceding"=>[{"preceding"=>[{"preceding"=>[{"preceding"=>[{"preceding"=>[], "type"=>"x"}, {"preceding"=>[], "type"=>"x"}], "type"=>"+"}, {"preceding"=>[], "type"=>"x"}], "type"=>"+"}, {"preceding"=>[], "type"=>"x"}], "type"=>"+"}], "type"=>"+"}
section2 = {"preceding"=>[{"preceding"=>[{"preceding"=>[{"preceding"=>[{"preceding"=>[], "type"=>"x"}, {"preceding"=>[], "type"=>"x"}], "type"=>"+"}, {"preceding"=>[], "type"=>"x"}], "type"=>"+"}, {"preceding"=>[], "type"=>"x"}], "type"=>"+"}], "type"=>"+"} 
section3 = {"preceding"=>[{"preceding"=>[{"preceding"=>[{"preceding"=>[{"preceding"=>[], "type"=>"x"}, {"preceding"=>[], "type"=>"x"}], "type"=>"+"}, {"preceding"=>[], "type"=>"x"}], "type"=>"+"}, {"preceding"=>[], "type"=>"x"}], "type"=>"+"}], "type"=>"+"} 
section3['preceding'][0]['preceding'][0]['preceding'][0]['preceding'][0]['preceding'] = [section2]
section2['preceding'][0]['preceding'][0]['preceding'][0]['preceding'][0]['preceding'] = [section1]
fullgraph  = section3 
