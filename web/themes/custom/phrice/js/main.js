(function () {
  'use strict';

  function initGenomeGrid() {
    const grid = document.getElementById('genome-grid');
    if (!grid) return;

    for (let i = 0; i < 64; i++) {
      const cell = document.createElement('div');
      const r = Math.random();
      cell.className = 'genome-cell' + (r > 0.85 ? ' active' : r > 0.5 ? ' mid' : '');
      grid.appendChild(cell);
    }

    setInterval(function () {
      const cells = grid.querySelectorAll('.genome-cell');
      const idx = Math.floor(Math.random() * cells.length);
      const r = Math.random();
      cells[idx].className = 'genome-cell' + (r > 0.85 ? ' active' : r > 0.5 ? ' mid' : '');
    }, 300);
  }

  document.addEventListener('DOMContentLoaded', initGenomeGrid);
})();
