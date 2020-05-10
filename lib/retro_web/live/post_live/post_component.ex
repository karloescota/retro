defmodule RetroWeb.PostLive.PostComponent do
  use RetroWeb, :live_component

  alias Retro.Boards

  @impl true
  def render(assigns) do
    ~L"""
    <div class="post <%= not_owned_class(@user_id, @post) %>">
      <div class="content">
        <%= @post.body %>
      </div>

      <div class="cta">
        <%= if authorized?(@user_id, @post) do %>
          <%= live_patch "Edit", to: Routes.board_show_path(@socket, :edit_post, @code, @post, %{type: @post.type}), replace: true %>
          <%= link "Delete", to: "#", phx_click: "delete", phx_target: @myself, phx_value_id: @post.id, phx_value_type: @post.type, data: [confirm: "Are you sure?"] %>
        <% end %>
      </div>
      </div>
    """
  end

  @impl true
  def handle_event("delete", %{"id" => post_id, "type" => type}, socket) do
    board = Boards.delete_post(socket.assigns.code, String.to_integer(post_id), type)

    Phoenix.PubSub.broadcast(
      Retro.PubSub,
      "boards:#{socket.assigns.code}",
      {:post_deleted, board, type}
    )

    {:noreply, socket}
  end

  defp not_owned_class(user_id, post) do
    if authorized?(user_id, post) do
      ""
    else
      "not-owned"
    end
  end

  defp authorized?(user_id, %{user_id: post_owner}), do: user_id == post_owner
end
