const frame = document.querySelector('#frame');
const cover = document.querySelector('#cover');
const status = document.querySelector('#status');
document.querySelector('#play').addEventListener('click', () => {
  status.textContent = 'Laster spillet … Dette kan ta litt tid første gang.';
  frame.src = 'game/index.html';
  frame.hidden = false;
  cover.hidden = true;
  cover.style.display = 'none';
  frame.addEventListener('load', () => {
    status.textContent = 'Klikk inne i spillet for å bruke tastaturet. Esc åpner pausemenyen.';
    frame.focus();
  }, { once: true });
});
document.querySelector('#fullscreen').addEventListener('click', async () => {
  try {
    if (document.fullscreenElement) await document.exitFullscreen();
    else await document.querySelector('#game').requestFullscreen();
  } catch {
    status.textContent = 'Fullskjerm er ikke tilgjengelig her. Bruk «Åpne separat».';
  }
});
