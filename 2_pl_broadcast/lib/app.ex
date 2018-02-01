# Thibault Meunier (ttm17)

defmodule App do

def start do
  receive do
  { :bind, pl, nodes} ->
    next pl, nodes
  end
end

defp next pl, nodes do
  messages = Enum.reduce nodes, %{}, fn peer, acc ->
               Map.put(acc, peer, { 0, 0 })
             end

  receive do
  { :deliver, _, { :broadcast, max_messages, timeout } } ->
    listen(messages, nodes, 0, max_messages, timeout, pl)
  end
end

defp broadcast messages, nodes, pl do
  Enum.reduce nodes, messages, fn peer, acc ->
    (send pl, { :send, peer, { :message } };
    { sent, received } = messages[peer];
    Map.put(acc, peer, { sent+1, received })) 
  end 
end

defp listen messages, nodes, timeout, max_messages, max_timeout, pl do
  receive do
    { :deliver, from, { :message } } ->
      { sent, received } = messages[from]
      listen Map.put(messages, from, { sent, received+1 }), nodes, timeout, max_messages, max_timeout, pl
  after
    timeout ->
      if sent(messages, pl) < max_messages do
        messages = broadcast messages, nodes, pl
        timeout = if sent(messages, pl) == max_messages, do: max_timeout, else: timeout
        listen messages, nodes, timeout, max_messages, max_timeout, pl
      else
        IO.puts "#{DAC.self_string()}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
      end
  end
end

defp sent messages, pl do
  { sent, _ } = messages[pl]
  sent
end


end # module ----------------
