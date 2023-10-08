<script lang="ts">
    import Spectogram2 from "./Projects/Spectogram2/Spectogram2.svelte";
    import Spectogram from "./Projects/Spectogram/Spectogram.svelte";
    import SpectoTutorial from "./Projects/SpectoTutorial/SpectoTutorial.svelte";
    import ShaderTutorial from "./Projects/ShaderTutorial/ShaderTutorial.svelte";
    import BasicThree from "./Projects/BasicThree/BasicThree.svelte";
    import SpectoFinal from "./Projects/SpectoFinal/SpectoFinal.svelte";
    import Tuner from "./Projects/Tuner/Tuner.svelte";
    import RythmMaker from "./Projects/RythmMaker/RythmMaker.svelte";
    import FindTheKey from "./Projects/Spotify/FindTheKey.svelte";

  let currentPage = "FindTheKey";

</script>
<header>
  <nav>
   <button on:click={() => currentPage = "SpectoTutorial"}>SpectoTutorial</button>
   <!-- <button on:click={() => currentPage = "Spectogram"}>Spectogram</button>
   <button on:click={() => currentPage = "Empty2"}>Spectogram2</button> -->
    <button on:click={() => currentPage = "SpectoFinal"}>SpectoFinal</button>
   <button on:click={() => currentPage = "ShaderTutorial"}>ShaderTutorial</button>
   <button on:click={() => currentPage = "BasicThree"}>BasicThree</button>
   <button on:click={() => currentPage = "Tuner"}>Tuner</button>
   <button on:click={() => currentPage = "RythmMaker"}>Rythm Maker</button>
    <button on:click={() => currentPage = "FindTheKey"}>FindTheKey</button>

  </nav>
</header>
<main>
  {#if currentPage === "SpectoTutorial"}
  <SpectoTutorial/>
  {:else if currentPage === "Tuner"}
  <Tuner/>
  {:else if currentPage === "ShaderTutorial"}
  <ShaderTutorial/>
  {:else if currentPage === "BasicThree"}
  <BasicThree/>
  {:else if currentPage === "SpectoFinal"}
  <SpectoFinal/>
  {:else if currentPage === "BasicThree"}
  <BasicThree/>
  {:else if currentPage === "RythmMaker"}
  <RythmMaker/>
  {:else if currentPage === "FindTheKey"}
  <FindTheKey/>
  {:else}
  <Spectogram2/> 
  {/if}


</main>
