# Thibault Meunier (ttm17)

defmodule PL do

def start processes do
  receive do
  { :bind, pls, component } ->
    peers = Enum.reduce Map.keys(pls), %{}, fn proc, acc ->
              Map.put(acc, pls[proc], proc)
            end
    next peers, pls, component
  end
end

defp next peers, pls, component do
  receive do
  { :send, to, message } ->
    if pls[to] === nil do IO.puts "-------------- #{inspect to} - #{inspect peers[self()]}" end
    send pls[to], { :deliver, peers[self()], message }
  { :deliver, from,  message } ->
    send component, { :deliver, from, message }
  end
  next peers, pls, component
end

end # module -------------
