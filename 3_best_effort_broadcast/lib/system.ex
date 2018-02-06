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
  max_messages = 10_000_000
  timeout = 3000
  tPeers = 0..(npeers-1)

  # Code
  IO.puts ["System at ", DAC.self_string()]
 
  # Creating peers
  peers = for iPeer <- tPeers, do:
            DAC.node_spawn(name, iPeer, Peer, :start, [ self() ])

  for peer <- peers, do:
    send peer, { :bind, peers}

  # Receive pl for every peer
  pls = retrieve npeers

  if pls === nil do
    raise "System wasn't able to bind all peers"
  end

  for peer <- peers, do:
    send peer, { :bindPL, pls}

  # Start the system by asking each peer to broadcast
  for pl <- Map.values(pls), do:
    send pl, { :deliver, nil, { :broadcast, max_messages, timeout } }
end

defp retrieve npeers do
  retrieve 0, %{}, npeers
end

defp retrieve iPeer, pls, npeers do
  if iPeer == npeers do
    pls
  else
    receive do
    { :bind, peer, pl } ->
      retrieve iPeer + 1, Map.put(pls, peer, pl), npeers
    after
    5_000 ->
      nil
    end
  end
end

end # module ------------------
