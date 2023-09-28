import './app.css'
import App from './App.svelte'
declare global {
  interface Window { onSpotifyIframeApiReady: any; }
}

const app = new App({
  target: document.getElementById('app'),
})

export default app
