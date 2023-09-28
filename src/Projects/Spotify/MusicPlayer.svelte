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
        } else if (!EmbedController) {
            console.log("EmbedController is not defined");
            const options = {
                uri: songUrl,
            };
            const callback = (EmbedControllerIns) => {
                EmbedController = EmbedControllerIns;
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
