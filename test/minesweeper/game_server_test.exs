defmodule Minesweeper.GameServerTest do
  use Minesweeper.DataCase

  import Minesweeper.Factory
  import Minesweeper.TestUtils

  alias Minesweeper.Game
  alias Minesweeper.GameServer
  alias Minesweeper.GameServer.State
  alias Minesweeper.Move

  test "play a move in an ongoing game", %{now: now} do
    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: [[1, 2], [2, 1], [2, 2]], moves: []],
        returning: [:id]
      )

    assert {:reply, {:ok, move}, %State{game: ^game}} =
             GameServer.handle_call({:play, [1, 1]}, self(), %State{game: game})

    assert %Move{id: id, played_at: played_at} = move
    assert id =~ uuid_regexp()
    assert DateTime.diff(now, played_at, :second) <= 1

    assert move == %Move{
             __meta__: move.__meta__,
             id: move.id,
             game: game,
             game_id: game.id,
             position: [1, 1],
             uncovered: [{[1, 1], 3}],
             played_at: played_at
           }
  end

  test "play a winning move", %{now: _now} do
    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: [[1, 2]], moves: []],
        returning: [:id]
      )

    insert(:move, game: game, position: [1, 1])

    assert :ok = GameServer.start_link(game.id)

    assert {:ok, %Move{game: %Game{state: :win}}} = GameServer.play(game.id, [3, 1])
  end
end
