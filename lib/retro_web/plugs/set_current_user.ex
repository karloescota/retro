defmodule RetroWeb.Plugs.SetCurrentUser do
  import Plug.Conn

  def init(opts \\ %{}), do: opts

  def call(conn, _) do
    set_current_user(conn, get_session(conn, :user_id))
  end

  defp set_current_user(conn, nil) do
    put_session(conn, :user_id, generate_user_id())
  end

  defp set_current_user(conn, _user_id) do
    conn
  end

  def generate_user_id do
    12
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end
