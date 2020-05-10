defmodule RetroWeb.BoardLive.Show do
  use RetroWeb, :live_view

  alias Retro.Boards
  alias Retro.Boards.Post

  @impl true
  def mount(%{"code" => code}, %{"user_id" => user_id}, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Retro.PubSub, "boards:#{code}")

    case Boards.get_state(code) do
      {:ok, %{board: board, reveal_posts: reveal_posts}} ->
        socket =
          socket
          |> assign(:code, code)
          |> assign(:positive, board.positive)
          |> assign(:negative, board.negative)
          |> assign(:action, board.action)
          |> assign(:reveal_posts, reveal_posts)
          |> assign_new(:user_id, fn -> user_id end)

        {:ok, socket}

      _ ->
        {:ok, push_redirect(socket, to: Routes.page_path(socket, :index), replace: true)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, socket.assigns.code)
  end

  defp apply_action(socket, :new_post, %{"type" => type}) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{type: type})
  end

  defp apply_action(socket, :edit_post, %{"code" => code, "id" => post_id, "type" => type})
       when type in ["positive", "negative"] do
    post = Boards.get_post(code, String.to_integer(post_id), String.to_atom(type))

    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
  end

  @impl true
  def handle_info({:post_created, %{type: "positive"} = post}, socket) do
    {:noreply, update(socket, :positive, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:post_created, %{type: "negative"} = post}, socket) do
    {:noreply, update(socket, :negative, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:post_created, %{type: "action"} = post}, socket) do
    {:noreply, update(socket, :action, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:post_updated, %{type: "positive"}}, socket) do
    {:ok, %{board: board}} = Boards.get_state(socket.assigns.code)
    {:noreply, assign(socket, :positive, board.positive)}
  end

  @impl true
  def handle_info({:post_updated, %{type: "negative"}}, socket) do
    {:ok, %{board: board}} = Boards.get_state(socket.assigns.code)
    {:noreply, assign(socket, :negative, board.negative)}
  end

  @impl true
  def handle_info({:post_updated, %{type: "action"}}, socket) do
    {:ok, %{board: board}} = Boards.get_state(socket.assigns.code)
    {:noreply, assign(socket, :action, board.action)}
  end

  @impl true
  def handle_info({:post_deleted, board, "positive"}, socket) do
    {:noreply, assign(socket, :positive, board.positive)}
  end

  @impl true
  def handle_info({:post_deleted, board, "negative"}, socket) do
    {:noreply, assign(socket, :negative, board.negative)}
  end

  @impl true
  def handle_info({:post_deleted, board, "action"}, socket) do
    {:noreply, assign(socket, :action, board.action)}
  end

  @impl true
  def handle_info(:posts_revealed, socket) do
    {:noreply, assign(socket, :reveal_posts, true)}
  end

  @impl true
  def handle_info(:posts_blurred, socket) do
    {:noreply, assign(socket, :reveal_posts, false)}
  end

  @impl true
  def handle_event("toggle_reveal_posts", %{"value" => "true"}, socket) do
    Boards.toggle_reveal_posts(socket.assigns.code, true)
    Phoenix.PubSub.broadcast(Retro.PubSub, "boards:#{socket.assigns.code}", :posts_revealed)
    {:noreply, assign(socket, :reveal_posts, true)}
  end

  @impl true
  def handle_event("toggle_reveal_posts", _value, socket) do
    Boards.toggle_reveal_posts(socket.assigns.code, false)
    Phoenix.PubSub.broadcast(Retro.PubSub, "boards:#{socket.assigns.code}", :posts_blurred)
    {:noreply, assign(socket, :reveal_posts, false)}
  end
end
