# defmodule Retro.BoardRegistry do
#   def lookup(code) do
#     Registry.lookup(__MODULE__, board_name(code))
#   end

#   defp board_name(code) do
#     {:via, Registry, {__MODULE__, code}}
#   end
# end
