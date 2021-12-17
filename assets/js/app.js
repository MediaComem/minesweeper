// Webpack automatically bundles all modules in your entry points. Those entry
// points can be configured in "webpack.config.js".
import '../css/app.css';

import Alpine from 'alpinejs';
import { DateTime } from 'luxon';

const storageKey = 'minesweeper';
const rawStoredData = localStorage.getItem(storageKey);
const storedData = rawStoredData ? JSON.parse(rawStoredData) : {};
const $previousGames = document.getElementById('previous-games');

Alpine.store('game', {
  id: storedData.gameId,
  state: storedData.gameId ? 'loading' : 'none',
  params: null,
  board: [],
  playing: false,
  startTime: null,
  elapsedTime: null,
  timer: null,

  init() {
    if (this.id) {
      fetch(`/api/games/${this.id}`)
        .then(res => res.json())
        .then(game => {
          if (game.state !== 'ongoing') {
            this.id = null;
            this.state = 'none';
            return;
          }

          this.state = 'ongoing';
          this.params = {
            width: game.width,
            height: game.height,
            number_of_bombs: game.number_of_bombs
          };

          hidePreviousGames();

          const flagged = storedData.flagged || [];
          const uncovered = game.moves.reduce(
            (memo, move) => [...memo, ...move.uncovered],
            []
          );

          this.board = Array(game.height)
            .fill()
            .map((_rowValue, rowIndex) =>
              Array(game.width)
                .fill()
                .map((_colValue, colIndex) => {
                  const data = uncovered.find(
                    ([[ucol, urow]]) =>
                      ucol === colIndex + 1 && urow === rowIndex + 1
                  );

                  return {
                    value: data ? data[1] : -1,
                    flagged: flagged.some(
                      ([fcol, frow]) =>
                        fcol === colIndex + 1 && frow === rowIndex + 1
                    )
                  };
                })
            );

          this.playing = false;
          this.startTime = DateTime.fromISO(game.created_at);
          this.elapsedTime = getElapsedTime(this.startTime);
          this.timer = setInterval(() => {
            this.elapsedTime = getElapsedTime(this.startTime);
          }, 1000);
        })
        .catch(err => {
          console.warn(err.stack);
          this.state = 'none';
        });
    }
  },

  configure(params) {
    this.params = params;
    this.board = Array(params.height)
      .fill()
      .map(() =>
        Array(params.width)
          .fill(-1)
          .map(() => ({ value: -1, flagged: false }))
      );
    this.state = 'configured';
    hidePreviousGames();
  },

  flag(col, row, event) {
    event.preventDefault();
    const cell = this.board[row - 1][col - 1];
    if (cell.value === -1) {
      cell.flagged = !cell.flagged;
    }

    this.persist();
  },

  play(col, row) {
    if (this.playing) {
      return;
    }

    this.playing = true;

    const action =
      this.state === 'configured'
        ? this.start(col, row)
        : this.uncover(col, row);

    action.finally(() => {
      this.playing = false;
    });
  },

  async start(col, row) {
    const res = await fetch('/api/games', {
      method: 'POST',
      body: JSON.stringify({ ...this.params, first_move: [col, row] }),
      headers: {
        'Content-Type': 'application/json'
      }
    });

    const {
      id,
      moves: [{ uncovered }]
    } = await res.json();

    this.id = id;
    this.state = 'ongoing';
    this.startTime = DateTime.now();
    this.elapsedTime = '00:00';
    this.timer = setInterval(() => {
      this.elapsedTime = getElapsedTime(this.startTime);
    }, 1000);

    hidePreviousGames();

    this.persist();
    this.reveal(uncovered);
  },

  async uncover(col, row) {
    const res = await fetch(`/api/games/${this.id}/moves`, {
      method: 'POST',
      body: JSON.stringify({ position: [col, row] }),
      headers: {
        'Content-Type': 'application/json'
      }
    });

    const {
      uncovered,
      game: { bombs, state }
    } = await res.json();

    this.state = state;

    if (this.state !== 'ongoing') {
      localStorage.removeItem(storageKey);

      if (this.timer) {
        clearInterval(this.timer);
      }
    }

    if (uncovered) {
      this.reveal(uncovered);
    }

    if (bombs) {
      this.revealBombs(bombs);
    }
  },

  get remainingBombs() {
    return (
      this.params.number_of_bombs -
      this.board.reduce(
        (rowMemo, row) =>
          rowMemo +
          row.reduce((colMemo, cell) => colMemo + (cell.flagged ? 1 : 0), 0),
        0
      )
    );
  },

  reveal(uncovered) {
    for (const [[col, row], bombs] of uncovered) {
      this.board[row - 1][col - 1] = { value: bombs, flagged: false };
    }
  },

  revealBombs(bombs) {
    for (const [col, row] of bombs) {
      this.board[row - 1][col - 1] = { value: '*', flagged: false };
    }
  },

  persist() {
    localStorage.setItem(
      storageKey,
      JSON.stringify({
        gameId: this.id,
        flagged: this.board.reduce(
          (memo, row, rowIndex) => [
            ...memo,
            ...row
              .reduce(
                (rowMemo, cell, colIndex) =>
                  cell.flagged ? [...rowMemo, colIndex + 1] : rowMemo,
                []
              )
              .map(col => [col, rowIndex + 1])
          ],
          []
        )
      })
    );
  },

  reset() {
    this.id = null;
    this.state = 'none';
    this.params = null;
    this.board = [];
    this.playing = false;
    this.startTime = null;
    this.elapsedTime = null;
  }
});

Alpine.start();

function hidePreviousGames() {
  if ($previousGames) {
    $previousGames.style.display = 'none';
  }
}

function getElapsedTime(start) {
  const elapsedSeconds = Math.floor(DateTime.now().diff(start).as('seconds'));
  return [Math.floor(elapsedSeconds / 60), elapsedSeconds % 60]
    .map(value => String(value).padStart(2, '0'))
    .join(':');
}
