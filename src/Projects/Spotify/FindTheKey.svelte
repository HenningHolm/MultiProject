<script lang="ts">
    import { onDestroy, onMount } from 'svelte';
    import MusicPlayer from './MusicPlayer.svelte';
    import * as songsCollection from "./songsArray.json"
    import type { FindKeySong } from './FindTheKeyDependencies';
    import { start } from 'tone';
    // import MusicPlayer from './MusicPlayer.svelte'; // Husk å opprette denne filen
    
    let time = 0;
    let prevTime = 0;
    let guessRightMessage : string = "";
    let guessQuestionTime = 0;
    let started = false;
    let countdown : any = 3;
    let startButtonPressed = false;
    let listOfSongs: FindKeySong[] = songsCollection.dictonary;
    let currentSong : FindKeySong = listOfSongs[9];
    let currentSongIndex = 90;
    let progress = -1;
    let MusicComponent;
    let clockId;
    onDestroy(() => {
      clearInterval(clockId);
      console.log("destroyed find the key");
    })

    function guessKey(scaleGuess: string){
      console.log("currentSong.scale", currentSong.scale)
      if(scaleGuess === currentSong.scale){
        if(progress === 100){
          clearInterval(clockId);
          progress = -1;
          startButtonPressed = false;
          countdown = "Done!";
          MusicComponent.pauseSong();
          return;
        }
        currentSongIndex++;
        checkQuickness(time-prevTime);
        nextSong();
      } else {
        console.log("Wrong key");
        time += 3;
      }
    }

    const keys = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    
    function nextSong() {
      console.log("nextSong called");
      try{
        clearInterval(clockId);
      }
      catch{
        console.log("clockId not defined");
      }
      progress++;
      currentSong = listOfSongs[currentSongIndex];
      MusicComponent.loadSong(currentSong.embedded);
      countdown = 3;
      const countDownId = setInterval(() => {
            if (countdown === 1) {
              clearInterval(countDownId);
              startTimer();
              MusicComponent.playSong();
              prevTime = time;
              countdown = "Go!";
            } else {
              countdown--;
            }
          }, 1000);

    }

    function startGame() {
      started = true;
      nextSong();
      startButtonPressed = true;
    }
    
    function startTimer() {
      clockId = setInterval(() => {
        time += 0.01;
      }, 10);
    }


    function checkQuickness(quickness: number){
      guessQuestionTime = quickness
     if(quickness< 5){
      guessRightMessage ="Insane🤯";
     } 
     else if(quickness<10){
      guessRightMessage ="Wow, that was fast😲";
     }
     else if(quickness<15){
      guessRightMessage ="Great😃";
     }
     else{
      guessRightMessage ="You did it👍";
     }
    }
  </script>
  
  <main>
    <h1>Find the Key</h1>
    {#if started}
    <button>Back</button>
    {/if}
    <div>
      
      <span>Time: {time.toFixed(2)}</span>
      {#if started}
      <span>Song: {progress+1}/10</span>
      {/if}
    </div>
    {#if startButtonPressed}    
    <h2>{countdown}</h2>
    <!-- {#if countdown == 3}
    <h2>{guessRightMessage}</h2>
    {/if} -->
    {/if}
    {#if !started}
    <button on:click={startGame}>Start</button>
    {/if}
    <div class='keys'>
      {#each keys as key (key)}
        <button on:click={()=>guessKey(key)}>{key}</button>
      {/each}
    </div>
    {#if countdown === 3}
      <!-- <MusicPlayer bind:this={MusicComponent} bind:update={updateChild}/> -->
    {/if}
    <div class:hidden={!started}><MusicPlayer bind:this={MusicComponent}/></div>
  </main>
  <style>
    /* Tilpass stiler her etter dine behov */
    main {
      text-align: center;
    }
    .keys {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      justify-content: center;
      margin-top: 20px;
    }
    .hidden {
    display: none;
  }
    
  </style>