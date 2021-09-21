
// Webpack automatically bundles all modules in your entry points. Those entry
// points can be configured in "webpack.config.js".

// We need to import the CSS so that webpack will load it. The
// MiniCssExtractPlugin is used to separate it out into its own CSS file.
import "../css/app.css";

import Alpine from 'alpinejs';

window.Alpine = Alpine;

Alpine.store('game', {
  name: '',
  created: null,
  create() {
    fetch('/api/games', {
      method: 'POST',
      body: JSON.stringify({ data: this.name }),
      headers: {
        'Content-Type': 'application/json'
      }
    })
      .then(res => res.json())
      .then(({ data }) => {
        this.created = data;
        console.log('g@@', this.created);
      });
  }
});

Alpine.start();
