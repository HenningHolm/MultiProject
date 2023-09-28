<script lang="ts">
    import { AMDF } from "pitchfinder";
    import * as tonal from "tonal";
    let running = false;
    let pitchDetector;
    let pitch = 0;
    let tick = 0;
    let prevNote = "";
    let closestNote = "";
    let closestNoteFrequency : number;
    let nextNote = "";
    let audioCtx;
    let analyser;
    let microphoneStream;
    let audioInput;

    let canvas;
    let ctx;

    async function init() {
        
        try {
            ctx = canvas.getContext("2d");
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

    function drawPendulum(pitchDifference) {
    if (!ctx) return;

    const centerX = canvas.width / 2;
    const centerY = canvas.height-30;
    const radius =  canvas.height/1.8;  // length of the pendulum
    const maxAngle = Math.PI / 4;  // 45 degrees max deviation
    const angle = pitchDifference * maxAngle;
    const endX = centerX + radius * Math.sin(angle);
    const endY = centerY - radius * Math.cos(angle);

    // Clear canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw pendulum
    ctx.beginPath();
    ctx.moveTo(centerX, centerY);
    ctx.lineTo(endX, endY);
    ctx.lineWidth = 4;
    ctx.strokeStyle = "white";
    ctx.stroke();

    for (let i = -1; i <= 1; i += 0.2) {
        i = Math.round(i * 10) / 10;
        let markerAngle = i * maxAngle;
        let markerStartY = centerY - (radius + 10) * Math.cos(markerAngle);
        let markerEndY = centerY - (radius + 15) * Math.cos(markerAngle);
        ctx.beginPath();
        ctx.moveTo(centerX + (radius + 10) * Math.sin(markerAngle), markerStartY);
        ctx.lineTo(centerX + (radius + 15) * Math.sin(markerAngle), markerEndY);
        ctx.lineWidth = i % 1 === 0 ? 4 : 1;
        ctx.stroke();
    }

    // Draw the note names
    ctx.fillStyle = "white";
    ctx.textAlign = "center";
    ctx.font = "bold 16px Arial";


    ctx.fillText(prevNote, centerX - radius, centerY - 90);
    ctx.fillText(nextNote, centerX + radius, centerY - 90);
    //set font to green if closest frequency is within 0.1% of pitch else red
    if(closestNoteFrequency > pitch*0.993 && closestNoteFrequency < pitch*1.003){
        ctx.fillStyle = "darkgreen";
    }else{
        ctx.fillStyle = "white";
    }
    


    

    ctx.fillText(closestNote, centerX, centerY - 134);
    ctx.fillText(closestNoteFrequency+"Hz", centerX, centerY -150);
    ctx.font = "bold 16px Arial";
    ctx.fillStyle = "white";
    ctx.fillText(pitch+"Hz" , centerX, centerY+20);
}

    function updatePitch() {
        if (running && tick % 5 == 0) {
            // console.log("tick", tick);
            if (audioCtx && analyser && microphoneStream) {
                const bufferLength = analyser.frequencyBinCount;
                const dataArray = new Float32Array(bufferLength);
                analyser.smoothingTimeConstant = 0.9;
                analyser.getFloatTimeDomainData(dataArray);
                console.log("analyser.smoothingTimeConstant", analyser.smoothingTimeConstant)
                // Use the created pitch detection function to detect the pitch
                const newPitch = pitchDetector(dataArray);
                if(newPitch){
                    pitch = toFixedNumb(smoothPitch(newPitch), 4);
                    detectNoteAndSuggest(pitch);
                } 
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
    closestNote = tonal.Note.fromFreq(frequency);
    closestNoteFrequency = toFixedNumb(tonal.Note.freq(closestNote),4);

    // noteSuggestion = closestNote + " " + closestNoteFrequency;

    // Finn indeksen til den oppdagede noten i skalaen (C, C#, D, D#, osv.)
    const noteIndex = tonal.Note.midi(closestNote);
    
    // Finn notene foran og etter den oppdagede noten
    prevNote = tonal.Note.fromMidi(noteIndex - 1);
    let prevNoteFrequency = toFixedNumb(tonal.Note.freq(prevNote), 4);
    // prevSuggestion = prevNote + " " + prevNoteFrequency;

    nextNote = tonal.Note.fromMidi(noteIndex + 1);
    let nextNoteFrequency = toFixedNumb(tonal.Note.freq(nextNote), 4);
    // nextSuggestion = nextNote + " " + nextNoteFrequency;
    
    const pitchDifference = 2 * (frequency - prevNoteFrequency) / (nextNoteFrequency - prevNoteFrequency) - 1;
    
    drawPendulum(pitchDifference);
}

function toFixedNumb(num : number, precision: number) {
    return parseFloat(num.toPrecision(precision));
}


let previousPitches = [];
    const MAX_PREVIOUS = 5;

    function smoothPitch(pitch) {
        // if pitch is more than 10% different from previous pitches, ignore it
        previousPitches.push(pitch);
        if (previousPitches.length > MAX_PREVIOUS) {
            previousPitches.shift();
        }
        return previousPitches.reduce((acc, curr) => acc + curr, 0) / previousPitches.length;
    }

    


</script>

<button on:click={init}>Start</button>
<button
    on:click={() => {
        running = false;
    }}>Stop</button
>
<br>

<canvas style="background-color: gray;" bind:this={canvas} width="400" height="200"></canvas>


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
