# Thibault Meunier (ttm17)

defmodule RB do

def start processes, pid do
  receive do
  { :bind, beb, component } ->
    next component, beb, pid, 0, MapSet.new
  end
end

# An id is needed in order to identify messages which have the same content
defp next component, beb, pid, id, delivered do
  newDelivered =
    receive do
    { :broadcast, message } ->
      data = { :data, pid, id, message }
      send beb, { :broadcast, data }
      delivered
    { :deliver, _, data } ->
      { :data, sender, _, message } = data
      if not MapSet.member? delivered, data do
        send component, { :deliver, sender, message }
        send beb, { :broadcast, data }
        MapSet.put delivered, data
      else
        delivered
      end
    end

  next component, beb, pid, id + 1, newDelivered
end

end # module -------------
