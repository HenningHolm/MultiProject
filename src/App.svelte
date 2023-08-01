<script lang="ts">
    import Spectogram2 from "./Projects/Spectogram2/Spectogram2.svelte";
    import Spectogram from "./Projects/Spectogram/Spectogram.svelte";
    import SpectoTutorial from "./Projects/SpectoTutorial/SpectoTutorial.svelte";
    import ShaderTutorial from "./Projects/ShaderTutorial/ShaderTutorial.svelte";
    import BasicThree from "./Projects/BasicThree/BasicThree.svelte";
    import SpectoFinal from "./Projects/SpectoFinal/SpectoFinal.svelte";

  let currentPage = "SpectoFinal";

</script>
<header>
  <nav>
   <button on:click={() => currentPage = "SpectoTutorial"}>SpectoTutorial</button>
   <!-- <button on:click={() => currentPage = "Spectogram"}>Spectogram</button>
   <button on:click={() => currentPage = "Empty2"}>Spectogram2</button> -->
    <button on:click={() => currentPage = "SpectoFinal"}>SpectoFinal</button>
   <button on:click={() => currentPage = "ShaderTutorial"}>ShaderTutorial</button>
   <button on:click={() => currentPage = "BasicThree"}>BasicThree</button>


  </nav>
</header>
<main>
  {#if currentPage === "SpectoTutorial"}
  <SpectoTutorial/>
  {:else if currentPage === "ShaderTutorial"}
  <ShaderTutorial/>
  {:else if currentPage === "BasicThree"}
  <BasicThree/>
  {:else if currentPage === "SpectoFinal"}
  <SpectoFinal/>
  {:else if currentPage === "BasicThree"}
  <BasicThree/>
  {:else}
  <Spectogram2/> 
  {/if}


</main>
