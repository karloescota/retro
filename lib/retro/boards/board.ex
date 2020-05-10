defmodule Retro.Boards.Board do
  defstruct [:code, positive: [], negative: [], action: []]

  def new(code), do: %__MODULE__{code: code}

  def create_post(board, %{type: "positive"} = post) do
    %{board | positive: [post | board.positive]}
  end

  def create_post(board, %{type: "negative"} = post) do
    %{board | negative: [post | board.negative]}
  end

  def create_post(board, %{type: "action"} = post) do
    %{board | action: [post | board.action]}
  end

  def get_post(board, post_id, type) do
    board
    |> Map.get(type)
    |> Enum.find(&(&1.id == post_id))
  end

  def update_post(board, %{type: "positive"} = post) do
    put_in(board, [Access.key(:positive), Access.filter(&(&1.id == post.id))], post)
  end

  def update_post(board, %{type: "negative"} = post) do
    put_in(board, [Access.key(:negative), Access.filter(&(&1.id == post.id))], post)
  end

  def update_post(board, %{type: "action"} = post) do
    put_in(board, [Access.key(:action), Access.filter(&(&1.id == post.id))], post)
  end

  def delete_post(board, post_id, "positive") do
    %{board | positive: Enum.reject(board.positive, &(&1.id == post_id))}
  end

  def delete_post(board, post_id, "negative") do
    %{board | negative: Enum.reject(board.negative, &(&1.id == post_id))}
  end

  def delete_post(board, post_id, "action") do
    %{board | action: Enum.reject(board.action, &(&1.id == post_id))}
  end
end
