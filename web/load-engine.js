// Keep the engine download small; the browser expands it before WebAssembly loads.
const fetchFile = window.fetch.bind(window);
window.fetch = async (input, options) => {
  const url = new URL(typeof input === 'string' ? input : input.url, location.href);
  if (!url.pathname.endsWith('/index.wasm')) return fetchFile(input, options);
  if (!('DecompressionStream' in window)) {
    throw new Error('Nettleseren er for gammel. Prøv en oppdatert nettleser.');
  }
  const file = await fetchFile(new URL('index.wasm.gz', url), options);
  if (!file.ok) throw new Error('Kunne ikke laste spillmotoren. Last siden på nytt.');
  return new Response(file.body.pipeThrough(new DecompressionStream('gzip')), {
    headers: { 'Content-Type': 'application/wasm' }
  });
};
