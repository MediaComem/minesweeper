
// Webpack automatically bundles all modules in your entry points. Those entry
// points can be configured in "webpack.config.js".

// We need to import the CSS so that webpack will load it. The
// MiniCssExtractPlugin is used to separate it out into its own CSS file.
import "../css/app.css";

import Alpine from 'alpinejs';

Alpine.store('game', {
  id: null,
  state: 'none',
  params: null,
  board: [],
  playing: false,

  configure(params) {
    this.params = params;
    this.board = Array(params.height).fill().map(() => Array(params.width).fill(-1));
    this.state = 'configured';
  },

  play(col, row) {
    if (this.playing) {
      return;
    }

    this.playing = true;

    const action = this.state === 'configured' ? this.start(col, row) : this.uncover(col, row);
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
    })

    const { id, moves: [ { uncovered } ] } = await res.json();

    this.id = id;
    this.state = 'ongoing';
    this.reveal(uncovered);
  },

  async uncover(col, row) {
    const res = await fetch(`/api/games/${this.id}/moves`, {
      method: 'POST',
      body: JSON.stringify({ position: [col, row] }),
      headers: {
        'Content-Type': 'application/json'
      }
    })

    const { uncovered, game: { bombs, state } } = await res.json();

    this.state = state;

    if (uncovered) {
      this.reveal(uncovered);
    }

    if (bombs) {
      this.revealBombs(bombs);
    }
  },

  reveal(uncovered) {
    for (const [[col, row], bombs] of uncovered) {
      this.board[row - 1][col - 1] = bombs;
    }
  },

  revealBombs(bombs) {
    for (const [col, row] of bombs) {
      this.board[row - 1][col - 1] = '*';
    }
  }
});

Alpine.start();
