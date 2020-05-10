defmodule RetroWeb.PostLive.FormComponent do
  use RetroWeb, :live_component

  alias Retro.Boards

  @impl true
  def update(assigns, socket) do
    changeset = Boards.change_post(assigns.post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  defp save_post(socket, :new_post, post_params) do
    {:ok, post} = Boards.create_post(socket.assigns.code, socket.assigns.user_id, post_params)
    Phoenix.PubSub.broadcast(Retro.PubSub, "boards:#{socket.assigns.code}", {:post_created, post})
    {:noreply, socket |> push_redirect(to: socket.assigns.return_to, replace: true)}
  end

  defp save_post(socket, :edit_post, post_params) do
    {:ok, post} = Boards.update_post(socket.assigns.code, socket.assigns.post, post_params)
    Phoenix.PubSub.broadcast(Retro.PubSub, "boards:#{socket.assigns.code}", {:post_updated, post})
    {:noreply, socket |> push_redirect(to: socket.assigns.return_to, replace: true)}
  end
end
