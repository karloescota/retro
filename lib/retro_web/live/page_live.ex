defmodule RetroWeb.PageLive do
  use RetroWeb, :live_view

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    {:ok, assign_new(socket, :user_id, fn -> user_id end)}
  end

  @impl true
  def handle_event("create_board", _, socket) do
    create_board(socket)
  end

  defp create_board(socket) do
    {:ok, %{board: board}} = Retro.Boards.create_board()
    {:noreply, push_redirect(socket, to: Routes.board_show_path(socket, :show, board.code))}
  end
end
