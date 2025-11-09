import axios from 'axios';

const pingUrl = 'https://evolution-api-nl1d.onrender.com/healthz';

export async function doPing() {
  try {
    await axios.get(pingUrl);
    // Sucesso: sem log
  } catch (err: any) {
    console.error(`[PING] Erro: ${err.message}`);
  }
}

export function startPing() {
  // Executa um ping imediato e depois repete a cada 14 minutos
  doPing();
  setInterval(doPing, 14 * 60 * 1000);
}
