<script lang="ts">
    import { AMDF } from "pitchfinder";
    import * as tonal from "tonal";
    let running = false;
    let pitchDetector;
    let pitch = 0;
    let tick = 0;
    let prevSuggestion= "";
    let noteSuggestion = "";
    let nextSuggestion = "";
    let audioCtx;
    let analyser;
    let microphoneStream;
    let audioInput;

    async function init() {
        try {
            running = true;
            audioCtx = new AudioContext();
            const constraints = { audio: true };
            microphoneStream = await navigator.mediaDevices.getUserMedia(constraints);
            audioInput = audioCtx.createMediaStreamSource(microphoneStream);

            // Create and configure AnalyserNode
            analyser = audioCtx.createAnalyser();
            analyser.fftSize = 4096;
            audioInput.connect(analyser);

            // Create the pitch detection function using YIN
            const detectPitchConfig = { sampleRate: audioCtx.sampleRate };
            pitchDetector = AMDF(detectPitchConfig);
            running = true;
            updatePitch();
        } catch (err) {
            console.error("Error accessing microphone:", err);
        }
    }

    function updatePitch() {
        if (running && tick % 5 == 0) {
            console.log("tick", tick);
            if (audioCtx && analyser && microphoneStream) {
                const bufferLength = analyser.frequencyBinCount;
                const dataArray = new Float32Array(bufferLength);
                analyser.getFloatTimeDomainData(dataArray);
                // Use the created pitch detection function to detect the pitch
                pitch = pitchDetector(dataArray);
                console.log("Detected Pitch:", pitch);  
                // Print the pitch in the console
                detectNoteAndSuggest(pitch);
            }
        }
        tick++;
        requestAnimationFrame(updatePitch);
    }

    function stopMicrophone() {
        if (microphoneStream) {
            const tracks = microphoneStream.getTracks();
            tracks.forEach((track) => track.stop());
            microphoneStream = null;
        }
    }

    function detectNoteAndSuggest(frequency) {
    // Finn noten som tilsvarer den gitte frekvensen
    let detectedNote = tonal.Note.fromFreq(frequency);
    noteSuggestion = detectedNote + " "+ tonal.Note.freq(detectedNote);
    
    // Finn indeksen til den oppdagede noten i skalaen (C, C#, D, D#, osv.)
    const noteIndex = tonal.Note.midi(detectedNote)
    
    // Finn notene foran og etter den oppdagede noten
    const prevNote = tonal.Note.fromMidi(noteIndex - 1);
    prevSuggestion = prevNote + " "+ tonal.Note.freq(prevNote);

    const nextNote = tonal.Note.fromMidi(noteIndex + 1);
    nextSuggestion = nextNote + " "+ tonal.Note.freq(nextNote);
}


</script>

<button on:click={init}>Start</button>
<button
    on:click={() => {
        running = false;
    }}>Stop</button
>
{#if (pitch != 0 && pitch != null)}
<h1>{pitch}</h1>
<div id="suggestionBox">
    <h2>{prevSuggestion}</h2>
    <h2>{noteSuggestion}</h2>
    <h2>{nextSuggestion}</h2>
</div>
{/if}

<style>
    #suggestionBox {
        display: flex;
        flex-direction: row;
        justify-content: space-evenly;
        align-items: center;
        height: 50px;
    }
    h2 {
        margin: 0 10px;

    }
</style>
