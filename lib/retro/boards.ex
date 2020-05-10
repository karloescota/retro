defmodule Retro.Boards do
  alias Retro.Boards.{BoardServer, Post}
  alias Retro.BoardRegistry

  def get_state(code) do
    case Registry.lookup(BoardRegistry, code) do
      [{_pid, _value} | _] -> {:ok, BoardServer.get_state(code)}
      _ -> {:error, :not_found}
    end
  end

  def toggle_reveal_posts(code, value), do: BoardServer.toggle_reveal_posts(code, value)

  def create_board(_attrs \\ %{}) do
    code = generate_code()
    {:ok, _pid} = DynamicSupervisor.start_child(Retro.BoardSupervisor, {BoardServer, code})
    {:ok, BoardServer.get_state(code)}
  end

  defp generate_code, do: ?a..?z |> Enum.take_random(6) |> List.to_string()

  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def create_post(code, user_id, attrs \\ %{}) do
    changeset = Post.changeset(%Post{user_id: user_id}, attrs)

    if changeset.valid? do
      {:ok, BoardServer.create_post(code, Ecto.Changeset.apply_changes(changeset))}
    else
      {:error, :todo_error}
    end
  end

  def get_post(code, post_id, type) do
    BoardServer.get_post(code, post_id, type)
  end

  def update_post(code, post, attrs) do
    changeset = Post.changeset(post, attrs)

    if changeset.valid? do
      {:ok, BoardServer.update_post(code, Ecto.Changeset.apply_changes(changeset))}
    else
      {:error, changeset.errors}
    end
  end

  def delete_post(code, post_id, type) do
    BoardServer.delete_post(code, post_id, type)
  end
end
