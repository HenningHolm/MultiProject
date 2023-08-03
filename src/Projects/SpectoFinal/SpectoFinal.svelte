<script>
    import { onDestroy, onMount } from "svelte";
    import { AMDF, YIN } from "pitchfinder";
  
    let audioCtx;
    let analyser;
    let microphoneStream;
    let audioInput;
  
    let detectPitch; // Declare the pitch detection function outside onMount
  
    onMount(async () => {
      try {
        audioCtx = new AudioContext();
        const constraints = { audio: true };
        microphoneStream = await navigator.mediaDevices.getUserMedia(constraints);
        audioInput = audioCtx.createMediaStreamSource(microphoneStream);
  
        // Create and configure AnalyserNode
        analyser = audioCtx.createAnalyser();
        analyser.fftSize = 2048;
        audioInput.connect(analyser);
  
        // Create the pitch detection function using YIN
        const detectPitchConfig = { sampleRate: audioCtx.sampleRate };
        detectPitch = AMDF(detectPitchConfig);
        console.log("audioCtx.sampleRate", audioCtx.sampleRate);
      } catch (err) {
        console.error("Error accessing microphone:", err);
      }
    });
  
    function updatePitch() {
      if (audioCtx && analyser && microphoneStream) {
        const bufferLength = analyser.frequencyBinCount;
        const dataArray = new Float32Array(bufferLength);
  
        analyser.getFloatTimeDomainData(dataArray);
  
        // Use the created pitch detection function to detect the pitch
        const pitch = detectPitch(dataArray);
  
        // Print the pitch in the console
        console.log("Detected Pitch:", pitch);
      }
  
      requestAnimationFrame(updatePitch);
    }
  
    function stopMicrophone() {
      if (microphoneStream) {
        const tracks = microphoneStream.getTracks();
        tracks.forEach((track) => track.stop());
        microphoneStream = null;
      }
    }
  
    // Call the stopMicrophone function when the component is destroyed
    onDestroy(stopMicrophone);
  
    // Start updating the pitch after audio initialization
    updatePitch();
  </script>