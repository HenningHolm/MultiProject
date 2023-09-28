import { writable } from 'svelte/store';

export const SpotifyStore=  writable({IFrameAPI: null});
interface SpotifyStore {IFrameAPI: any};
export const initalizeSpotifyIFrameAPI = () => {
    console.log("createAndGetSpotifyIframe");
    let Iframe;
    const script = document.createElement("script");
    script.src = "https://open.spotify.com/embed-podcast/iframe-api/v1";
    script.async = true;
    document.head.appendChild(script); 
    window.onSpotifyIframeApiReady = (IFrameAPI) => {
        SpotifyStore.update(store => {
            store.IFrameAPI = IFrameAPI;
            Iframe = IFrameAPI;
            return store;
            });
        };
}

