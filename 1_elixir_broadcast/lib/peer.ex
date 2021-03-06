# Thibault Meunier (ttm17)

defmodule Peer do

def start do
  IO.puts ["Client at ", DAC.self_string()]
  
  receive do
  { :bind, neighbours } ->
    next neighbours
  end
end

defp next nodes do
  messages = Enum.reduce nodes, %{}, fn peer, acc ->
               Map.put(acc, peer, { 0, 0 })
             end

  receive do
  { :broadcast, max_messages, timeout} ->
listen messages, nodes, 0, max_messages, timeout, (DAC.time + timeout)
  end
end

defp broadcast messages, nodes do
  Enum.reduce nodes, messages, fn peer, acc ->
    (send peer, { :message, self() };
    { sent, received } = messages[peer];
    Map.put(acc, peer, { sent+1, received }))
  end
end

defp listen messages, nodes, timeout, max_messages, max_timeout, max_time do
  receive do
    { :message, pid } ->
      { sent, received } = messages[pid]
      listen Map.put(messages, pid, { sent, received+1 }), nodes, timeout, max_messages, max_timeout, max_time
  after
    timeout ->
      if timeout == 0  do
        messages = if DAC.time < max_time do
                     broadcast(messages, nodes)
                   else
                     messages
                   end
        timeout = if sent(messages) == max_messages or DAC.time >= max_time, do: max_timeout, else: timeout
        listen messages, nodes, timeout, max_messages, max_timeout, max_time
      else
        IO.puts "#{DAC.self_string()}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
      end
  end
end

defp sent messages do
  { sent, _ } = messages[self]
  sent
end

end # module -------------
