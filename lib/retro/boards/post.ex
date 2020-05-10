defmodule Retro.Boards.Post do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :user_id, :string
    field :type, :string
    field :body, :string
    field :likes, :integer, default: 0
  end

  @valid_types ["positive", "negative", "action"]

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:user_id, :type, :body])
    |> validate_required([:user_id, :type, :body])
    |> validate_inclusion(:type, @valid_types)
  end
end
