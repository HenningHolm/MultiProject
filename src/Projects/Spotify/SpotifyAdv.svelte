<script lang="ts">
  import { onDestroy, onMount } from "svelte";

  let EmbedController;
  let songContainer;
  let script;
  export let songUrl;
  export const parentsCalling = (message: string) =>
      console.log(`hi my child, ${message}, I just called render`);
  export const loadSong = (songUrl: string) => {
      if (EmbedController) {
      EmbedController.loadUri(songUrl);
  } else {
      console.error('EmbedController is not defined');
  }
  };
  export const playSong = () => {
      EmbedController.play();
  };
  export const pauseSong = () => {
      EmbedController.pause();
  };


  onMount(() => {

      if (!document.querySelector('script[src="https://open.spotify.com/embed-podcast/iframe-api/v1"]')
      ) {
          script = document.createElement("script");
          script.src = "https://open.spotify.com/embed-podcast/iframe-api/v1?" + new Date().getTime();
          script.async = true;
          document.head.appendChild(script);
          window.onSpotifyIframeApiReady=null;
      }

      console.log("onMount musicPlayer");
      window.onSpotifyIframeApiReady = (IFrameAPI) => {
          console.log("IframeAPI ready");
          const options = {
              uri: songUrl,
          };
          const callback = (EmbedControllerIns) => {
              EmbedController = EmbedControllerIns;
              console.log("EmbedController", EmbedController);
          };
          IFrameAPI.createController(songContainer, options, callback);
      };
      console.log("Window.onSpotifyIframeApiReady", window.onSpotifyIframeApiReady);
      return () => {
          try {
              EmbedController.destroy();
              EmbedController = null;
              document.head.removeChild(script);
              delete window.onSpotifyIframeApiReady; // Rens opp global hendelse
          console.log("Window.onSpotifyIframeApiReady", window.onSpotifyIframeApiReady);

              console.log("Destroy success");
          } catch {
              console.log("Destroy failed",)
          }
      };
  });
</script>

<div bind:this={songContainer} />
