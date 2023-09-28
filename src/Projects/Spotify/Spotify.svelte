<script lang="ts">
    import { onDestroy, onMount } from "svelte";

    let EmbedController;
    let timerValue = 0; 
    let songContainer;
    let currentIndex = 0;
    let embeddedArray =[
        "spotify:track:50nfwKoDiSYg8zOCREWAm5",
        "spotify:track:7qiZfU4dY1lWllzX7mPBI3",
        "spotify:track:34gCuhDGsG4bRPIf9bb02f",
    ]

    onMount(() => {
        const script = document.createElement("script");
        script.src = "https://open.spotify.com/embed-podcast/iframe-api/v1";
        // script.src = "https://open.spotify.com/embed-track/iframe-api/v1";
        script.async = true;
        document.head.appendChild(script);

        window.onSpotifyIframeApiReady = (IFrameAPI) => {
            const options = {
                uri: "spotify:track:50nfwKoDiSYg8zOCREWAm5",
            };
            const callback = (EmbedControllerIns) => {
                EmbedController = EmbedControllerIns;
            };
             IFrameAPI.createController(songContainer, options, callback);
        };

        return () => {
            EmbedController.destroy();
            document.head.removeChild(script);
            delete window.onSpotifyIframeApiReady; // Rens opp global hendelse
        };
    });

</script>
 <button on:click={()=>{
    
    EmbedController.play();
    }}>
    Start
 </button>
 <button on:click={()=>{
    console.log(EmbedController);
    currentIndex++;
    EmbedController.loadUri(embeddedArray[currentIndex%3]);
    EmbedController.play();
    }}>
    Next
 </button>
<div bind:this={songContainer} />
