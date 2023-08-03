<script lang="ts">
    import { YIN } from "pitchfinder";
    import type { GUI } from "three/examples/jsm/libs/lil-gui.module.min.js";


    let fundamental: string;
    let running = true;
    let tick = 0;
    //fftDefault = 2048
    // const detectPitch = Pitchfinder.YIN();
    // let freqency_samples = 512;
    let time_sample = 200;
    // let ySegments = freqency_samples;
    // let xSegments = time_sample;
    
let source;
let DATA;
let audioCtx = new AudioContext();
let analyser = audioCtx.createAnalyser();
let detectPitch;

// You should define and set freqency_samples to a valid value here

function init() {
  navigator.mediaDevices.getUserMedia({ audio: true }).then((stream) => {
    source = audioCtx.createMediaStreamSource(stream);
    source.connect(analyser);

    // Set up the analyser properties
    analyser.fftSize = 2048; // You can adjust this value according to your requirements
    analyser.smoothingTimeConstant = 0.5;

    // Initialize DATA with the correct length
    const bufferLength = analyser.frequencyBinCount;
    DATA = new Float32Array(bufferLength/2);
    console.log("DATA", DATA, "DATA.length", DATA.length);

    // Initialize the YIN pitch detection with the sample rate
    detectPitch = YIN();

    // Start the animation loop once everything is set up
    animate();
  }).catch((err) => {
    console.error("Error accessing the microphone:", err);
  });
}

function animate() {
  // Only run the update loop if the audio context is in a "running" state
  if (audioCtx.state === "running") {
    update();
  }
  requestAnimationFrame(animate);
}

function update() {
  analyser.getFloatTimeDomainData(DATA);

  if(tick%60 == 0){
  // Use YIN from "Pitchfinder" to get the fundamental frequency
  console.log("DATA on update", DATA, "DATA.length", DATA.length);
  }
  
  const fundamentalFrequency = detectPitch(DATA);
  console.log("Fundamental Frequency:", fundamentalFrequency/1024);
  tick++;
}

// Call the init function to start the audio context and get user media

</script>

<button on:click={init}>Start</button>
<button on:click={()=>{running=false;}}>Stop</button>
