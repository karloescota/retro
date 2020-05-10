defmodule Retro.Boards.BoardServer do
  defstruct [:board, next_post_id: 1, reveal_posts: false]

  use GenServer, restart: :temporary

  alias Retro.Boards.Board

  def start_link(code) do
    GenServer.start_link(__MODULE__, Board.new(code), name: board_name(code))
  end

  defp board_name(code) do
    {:via, Registry, {Retro.BoardRegistry, code}}
  end

  def get_state(code) do
    GenServer.call(board_name(code), :get_state)
  end

  def toggle_reveal_posts(code, value) do
    GenServer.call(board_name(code), {:toggle_reveal_posts, value})
  end

  def get_post(code, post_id, type) do
    GenServer.call(board_name(code), {:get_post, post_id, type})
  end

  def update_post(code, post) do
    GenServer.call(board_name(code), {:update_post, post})
  end

  def create_post(code, post) do
    GenServer.call(board_name(code), {:create_post, post})
  end

  def delete_post(code, post_id, type) do
    GenServer.call(board_name(code), {:delete_post, post_id, type})
  end

  @impl true
  def init(board) do
    {:ok, %__MODULE__{board: board}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:toggle_reveal_posts, value}, _from, state) do
    {:reply, state, %{state | reveal_posts: value}}
  end

  @impl true
  def handle_call({:get_post, post_id, type}, _from, %{board: board} = state) do
    post = Board.get_post(board, post_id, type)
    {:reply, post, state}
  end

  @impl true
  def handle_call({:update_post, post}, _from, %{board: board} = state) do
    board = Board.update_post(board, post)
    {:reply, post, %{state | board: board}}
  end

  @impl true
  def handle_call({:create_post, post}, _from, state) do
    post = %{post | id: state.next_post_id}
    board = Board.create_post(state.board, post)
    {:reply, post, %{state | board: board, next_post_id: state.next_post_id + 1}}
  end

  @impl true
  def handle_call({:delete_post, post_id, type}, _from, state) do
    board = Board.delete_post(state.board, post_id, type)
    {:reply, board, %{state | board: board}}
  end
end
