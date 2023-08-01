<script lang="ts">
    import { onMount } from "svelte";
    import chroma from "chroma-js";
    import * as dat from 'dat.gui';

    let canvas: HTMLCanvasElement; 
    let canvasCtx: CanvasRenderingContext2D;
    let tempCanvas = document.createElement("canvas");
    let tempCtx = tempCanvas.getContext("2d");

    let audioCtx = new AudioContext();
    let javascriptNode = audioCtx.createScriptProcessor(2048, 1, 1);
    javascriptNode.connect(audioCtx.destination);

    let analyser = audioCtx.createAnalyser();
    analyser.minDecibels = -55;
    analyser.maxDecibels = -25;
    // analyser.smoothingTimeConstant = 0.85;
    analyser.smoothingTimeConstant = 0;
    analyser.fftSize = 1024;
    // analyser.connect(javascriptNode);
    
    // let source = audioCtx.createMediaElementSource(audio);
    let source = audioCtx.createBufferSource();
    source.connect(analyser);
    source.connect(audioCtx.destination);

    let track = 'music.mp3';
    function start() {
        fetch(track)
            .then(response => response.arrayBuffer())
            .then(arrayBuffer => audioCtx.decodeAudioData(arrayBuffer))
            .then(audioBuffer => {
                source.buffer = audioBuffer;
                source.start();
                javascriptNode.onaudioprocess = function () {
                            var array = new Uint8Array(analyser.frequencyBinCount);
                            analyser.getByteFrequencyData(array);
                            drawSpectrogram(array);
                        };
            });
    }




    

    onMount(() => {
        canvasCtx = canvas.getContext("2d");
        canvasCtx.fillStyle = "red";
        canvasCtx.fillRect(0, 0, 100, 100);
        tempCanvas.width = canvas.width;
        tempCanvas.height = canvas.height;
    });

    function drawSpectrogram (array) {
                // copy the current canvas onto the temp canvas
                tempCtx.drawImage(canvas, 0, 0, canvas.width, canvas.height);
                console.log("array", array);
                for(var i = 0; i < array.length; i++) {
                    // var magnitude = Math.log(Math.abs(array[i])+1);
                    // canvasCtx.fillStyle = 'rgb(' + Math.round(magnitude*40) + ', ' + Math.round(magnitude*5) + ', 0)';
                    canvasCtx.fillStyle = getColor(array[i]).hex();
                    canvasCtx.fillRect(canvas.width - 1, canvas.height - i, 1, 1);
               }

                var landmarks = getLandmarks(array);
                for (var i = 0; i < landmarks.length; i++) {
                 canvasCtx.fillStyle = 'rgb(100, 200, 255)';
                 canvasCtx.fillRect(canvas.width - 1, canvas.height - landmarks[i], 1, 1);
                };

                // set translate on the canvas
                canvasCtx.translate(-1, 0);
                // draw the copied image
                canvasCtx.drawImage(tempCanvas, 0, 0, canvas.width, canvas.height, 0, 0, canvas.width, canvas.height);

                // reset the transformation matrix
                canvasCtx.setTransform(1, 0, 0, 1, 0, 0);
            }
 

            function getLandmarks (array) {
                var recordPoints = [0,0,0,0,0];
                var highscores = [0,0,0,0,0];
                for(var i = 0; i < array.length; i++) {
                    var magnitude = Math.log(Math.abs(array[i]) + 1);
                    var index = getIndex(array[i]);
                    if (magnitude > highscores[index]) {
                        highscores[index] = magnitude;
                        recordPoints[index] = array[i];
                    }
                }
                return recordPoints;
            }

            var RANGE = [40,80,120,180,300];

            function getIndex (value) {
                var i = 0;
                while(RANGE[i] < value) i++;
                return i;
            }

            var getColor = chroma.scale(['#000000', '#ff0000', '#ffff00', '#ffffff'], [0, .25, .75, 1]).domain([0, 300]);

            var gui = new dat.GUI();

            var f1 = gui.addFolder('Analyser');
            f1.open();
            f1.add(analyser, 'minDecibels', -100, 0);
            f1.add(analyser, 'maxDecibels', -100, 0);
            f1.add(analyser, 'smoothingTimeConstant', 0, 1).step(0.01);
            f1.add(analyser, 'fftSize', [32,64,128,256,512,1024,2048]);

</script>

<div>
    This is the Spectogram component
    <button on:click={start}>Start</button>
    <canvas bind:this={canvas} class="visualizer" width="800" height="512"></canvas>
</div>

<style>
    .visualizer {
        width: 100%;
        height: 100%;
        background-color: #000;
}
</style>
