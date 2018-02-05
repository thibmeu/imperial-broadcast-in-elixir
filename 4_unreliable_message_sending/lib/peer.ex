# Thibault Meunier (ttm17)

defmodule Peer do

def start system do
  IO.puts ["------------- Client at ", DAC.self_string()]
  
  receive do
  { :bind, peers } ->
    next system, peers
  end
end

defp next system, peers do
  app = DAC.node_spawn("", 1, App, :start, [ peers ])
  beb = DAC.node_spawn("", 1, BEB, :start, [ peers ])
  pl  = DAC.node_spawn("", 1, LPL,  :start, [ peers ])

  IO.puts "Sending message to #{DAC.pid_string(system)}"
  send system, { :bind, self(), pl }
  
  receive do
  { :bindPL, pls } ->
    peers = Map.keys pls
    send app, { :bind, beb }
    send beb, { :bind, pl, app }
    send pl, { :bind, pls, beb }
  end
end

end # module -------------
