<script lang="ts">
import * as Tone from "tone";


const synthA = new Tone.PolySynth().toDestination();
const synthB = new Tone.FMSynth().toDestination();
const synthC = new Tone.AMSynth().toDestination();


    //play a note every sixteenth-note
    const loopA = new Tone.Loop(time => {
    synthA.triggerAttackRelease("C1", "8n", time);
}, "8n").start(0);

//play another note every off quarter-note, starting it "2n"
const loopB = new Tone.Loop(time => {
    synthB.triggerAttackRelease("D1", "8n", time);
}, "4n").start("2n");

//play another note every off half-note,by starting it "2n"
const loopC = new Tone.Loop(time => {
    synthC.triggerAttackRelease("E1", "8n", time);
}, "2n").start("2n");


function play(){


Tone.Transport.start()
}



</script>

<h1>

    Lets make some rythm!
</h1>
<button on:click={play}>Play</button>