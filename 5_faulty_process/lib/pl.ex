# Thibault Meunier (ttm17)

defmodule LPL do

def start processes do
  # Internal variables
  reliability = 50

  # Wait from binding with components and other PLs
  receive do
  { :bind, pls, component } ->
    peers = Enum.reduce Map.keys(pls), %{}, fn proc, acc ->
              Map.put(acc, pls[proc], proc)
            end
    next peers, pls, component, reliability
  end
end

defp next peers, pls, component, reliability do
  receive do
  { :send, to, message } ->
    if random_failure reliability do
      send pls[to], { :deliver, peers[self()], message }
    end
  { :deliver, from,  message } ->
    send component, { :deliver, from, message }
  end
  next peers, pls, component, reliability
end

defp random_failure reliability do
  DAC.random(100) <= reliability
end

end # module -------------
