# Thibault Meunier (ttm17)

defmodule SystemD do

def main do
  main_aux ""
end

def main_net do
  main_aux "peer"
end

defp main_aux name do
  npeers = hd(DAC.int_args())
  # Variables
  max_messages = 1000
  timeout = 3000
  tPeers = 0..npeers

  # Code
  IO.puts ["System at ", DAC.self_string()]
  
  # Creating peers
  for iPeer <- tPeers, do:
    DAC.node_spawn(name, iPeer, Peer, :start, [self()])

  # Receive pl for every peer
  pls = retrieve npeers

  for pl <- pls, do:
    send pl, { :bind, pls }

  # Start the system by asking each peer to broadcast
  for pl <- pls, do:
    send pl, { :deliver, nil, { :broadcast, max_messages, timeout } }
end

defp retrieve npeers do
  retrieve 0, [], npeers
end

def retrieve iPeer, pls, npeers do
  if iPeer == npeers do
    pls
  else
    receive do
    { :bind, pl } ->
      retrieve iPeer + 1, pls ++ [ pl ], npeers
    after
    5000 ->
      IO.puts "System wasn't able to bind all peers"
      nil
    end
  end
end

end # module ------------------
