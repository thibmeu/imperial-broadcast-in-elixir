# Thibault Meunier (ttm17)

defmodule PL do

def start app do
  receive do
  { :bind, nodes } ->
    send app, { :bind, self(), nodes}
    next app
  end
end

defp next app do
  receive do
  { :send, to, message } ->
    send to, { :deliver, self(), message }
  { :deliver, from,  message } ->
    send app, { :deliver, from, message }
  end
  next app
end

end # module -------------
