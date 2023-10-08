<script lang="ts">
    import { onMount } from "svelte";
    import { get } from "svelte/store";
    import { SpotifyStore, initalizeSpotifyIFrameAPI } from "./SpotifyStore";

    let EmbedController;
    let songContainer;
    let IFrameAPI;
    export const loadSong = (songUrl: string) => {
        IFrameAPI = get(SpotifyStore).IFrameAPI;
        if (EmbedController && IFrameAPI) {
            EmbedController.loadUri(songUrl);
        } else if (!EmbedController && IFrameAPI) {
            console.log("EmbedController is not defined");
            const options = {
                uri: songUrl,
            };
            const callback = (EmbeddedCtrl) => {
                EmbedController = EmbeddedCtrl;
            };
            IFrameAPI.createController(songContainer, options, callback);
        } else {
            console.log("IFrameAPI not ready");
        }
    };
    export const playSong = () => {
        EmbedController.play();
    };
    export const pauseSong = () => {
        EmbedController.pause();
    };

    onMount(() => {
        initalizeSpotifyIFrameAPI();
        return () => {
            try {
                EmbedController.destroy();
                console.log("Destroy success");
            } catch {
                console.log("No EmbedController to destroy");
            }
        };
    });
</script>

<div bind:this={songContainer} />

<!-- Add this to prevent cheating and maybe delay time if slow internet

    EmbedController.addListener('playback_update', e => {
    document.getElementById('progressTimestamp').innerText = `${parseInt(e.data.position / 1000, 10)} s`;
    }); 

EmbedController.addListener('ready', () => {
  console.log('The Embed has initialized');
  });

-->
