# Thibault Meunier (ttm17)

defmodule App do

def start processes, pid do
  receive do
  { :bind, component} ->
    next processes, component
  end
end

defp next processes, component do
  messages = Enum.reduce processes, %{}, fn proc, acc ->
               Map.put acc, proc, { 0, 0 }
             end

  receive do
  { :deliver, _, { :broadcast, max_messages, timeout } } ->
    listen messages, 0, max_messages, timeout, component
  end
end

defp broadcast messages, component do
  send component, { :broadcast, { :message } }
  Enum.reduce Map.keys(messages), messages, fn peer, acc ->
    (
      { sent, received } = messages[peer];
      Map.put(acc, peer, { sent+1, received })
    ) 
  end 
end

defp listen messages, timeout, max_messages, max_timeout, component do
  receive do
    { :deliver, from, { :message } } ->
      { sent, received } = messages[from]
      listen Map.put(messages, from, { sent, received+1 }), timeout, max_messages, max_timeout, component
  after
    timeout ->
      if sent(messages) < max_messages do
        messages = broadcast messages, component
        timeout = if sent(messages) == max_messages, do: max_timeout, else: timeout
        listen messages, timeout, max_messages, max_timeout, component
      else
        IO.puts "#{DAC.self_string()}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
      end
  end
end

defp sent messages do
  { sent, _ } = hd Map.values(messages)
  sent
end


end # module ----------------
