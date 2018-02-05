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
  app = DAC.node_spawn("", 1, App, :start, [ peers, self ])
  rb  = DAC.node_spawn("", 1, RB,  :start, [ peers, self ])
  beb = DAC.node_spawn("", 1, BEB, :start, [ peers, self ])
  pl  = DAC.node_spawn("", 1, LPL, :start, [ peers, self ])

  IO.puts "Sending message to #{DAC.pid_string(system)}"
  send system, { :bind, self, pl }
  
  receive do
  { :bindPL, pls } ->
    peers = Map.keys pls
    send app, { :bind, rb }
    send rb,  { :bind, beb, app }
    send beb, { :bind, pl, rb }
    send pl,  { :bind, pls, beb }
  end

  shutdown [ app, rb, beb, pl ]
end

defp shutdown components do
  receive do
    { :shutdown } ->
      for component <- components, do: Process.exit(component, :kill)
  end
  Process.exit(self, :kill)
end

end # module -------------
