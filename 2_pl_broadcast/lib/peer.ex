# Thibault Meunier (ttm17)

defmodule Peer do

def start system do
  IO.puts ["Client at ", DAC.self_string()]
  
  app = DAC.node_spawn("", 1, App, :start, [])
  pl = DAC.node_spawn("", 1, PL, :start, [ app ])

  IO.puts "Sending message to #{DAC.pid_string(system)}"
  send system, { :bind, pl }
end

end # module -------------
