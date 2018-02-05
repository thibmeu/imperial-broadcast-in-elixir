# Thibault Meunier (ttm17)

defmodule Peer do

def start do
  IO.puts ["Client at ", DAC.self_string()]
  
  receive do
  { :bind, neighbours } ->
    next(neighbours)
  end
end

defp next(nodes) do
  messages = Enum.reduce nodes, %{}, fn peer, acc ->
               Map.put(acc, peer, { 0, 0 })
             end

  receive do
  { :broadcast, max_messages, timeout} ->
    messages = broadcast(messages, nodes, max_messages)
    listen(messages, timeout)
  end
end

defp broadcast(messages, nodes, max_messages) do
  { sent, _} = messages[self()]

  if sent < max_messages do
    messages = Enum.reduce nodes, messages, fn peer, acc ->
                   (send peer, { :message, self() };
                   { sent, received } = messages[peer];
                   Map.put(acc, peer, { sent+1, received }))
                 end
    broadcast(messages, nodes, max_messages)
  else
    messages
  end
end

defp listen(messages, timeout) do
  receive do
    { :message, pid } ->
      { sent, received } = messages[pid]
      listen(Map.put(messages, pid, { sent, received+1 }), timeout)
  after
    timeout ->
      IO.puts "#{DAC.self_string()}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
  end
end

end # module -------------
