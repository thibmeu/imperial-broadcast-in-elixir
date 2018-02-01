# Thibault Meunier (ttm17)

defmodule Flooding do

def main do
  npeers = hd(DAC.int_args())
  # Variables
  max_messages = 1000
  timeout = 3000
  tPeers = 0..npeers

  # Code
  IO.puts ["Flooding at ", DAC.self_string()]
  
  # Creating peers
  peers = for iPeer <- tPeers, do:
            DAC.node_spawn("", 1, Peer, :start, [])

  for iPeer <- tPeers, do:
    bind(peers, iPeer, tPeers)
  
  for peer <- peers, do:
    send peer, { :broadcast, max_messages, timeout }
end

def main_net do
  npeers = hd(DAC.int_args())
  # Variables
  max_messages = 1000
  timeout = 3000
  tPeers = 0..npeers

  # Code
  IO.puts ["Flooding at ", DAC.self_string()]
  
  # Creating peers
  peers = for iPeer <- tPeers, do:
            DAC.node_spawn("peer", iPeer, Peer, :start, [])

  for iPeer <- tPeers, do:
    bind(peers, iPeer, tPeers)
  
  for peer <- peers, do:
    send peer, { :broadcast, max_messages, timeout }
end

defp bind(peers, iPeer, neighbours) do
  peer = Enum.at(peers, iPeer)
  pNeighbours = for index <- neighbours, do:
                  Enum.at(peers, index)
  send peer, { :bind, pNeighbours }
end

end # module ------------------
