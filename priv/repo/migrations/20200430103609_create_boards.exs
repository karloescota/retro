defmodule Retro.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :body, :string

      timestamps()
    end

  end
end
