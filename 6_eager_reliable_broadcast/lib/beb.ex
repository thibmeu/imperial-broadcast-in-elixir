# Thibault Meunier (ttm17)

defmodule BEB do

def start processes, pid do
  receive do
  { :bind, pl, component } ->
    next component, pl, processes
  end
end

defp next component, pl, nodes do
  receive do
  { :broadcast, message } ->
    for n <- nodes, do: send pl, { :send, n, message }
  { :deliver, from, message } ->
    send component, { :deliver, from, message }
  end
  next component, pl, nodes
end

end # module --------------
