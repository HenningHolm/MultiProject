<script lang="ts">
    import * as THREE from "three";
    import { onMount } from "svelte";
    import vertexShader from "./Shaders/SpectoVertex.glsl";
    import fragmentShader from "./Shaders/SpectoFragment.glsl";
    import { GUI } from "three/examples/jsm/libs/lil-gui.module.min.js";
    import { OrbitControls } from "three/addons/controls/OrbitControls.js";

    let running = true;
    let container: HTMLDivElement;
    let header: string;
    let gui;
    let controls = {
        zoom: 20,
        angle: 80,
        x: 0,
        y: 0,
        z: 0,
        samples: 1,
    };
    
    let tick = 0;
    let freqency_samples = 512;
    let time_sample = 200;
    let ySegments = freqency_samples;
    let xSegments = time_sample;

    let DATA = new Uint8Array(freqency_samples);
    let camera, scene, renderer;
    let heights, mesh;

    let n_vertices = (freqency_samples + 1) * (time_sample + 1);

    let xSize = 35;
    let ySize = 20;
    let xSegmentSize = xSize / xSegments;
    let ySegmentSize = ySize / ySegments;

    let xhalfSize = xSize / 2;
    let yhalfSize = ySize / 2;

    //new (window.AudioContext || window.webkitAudioContext)();
    let audioCtx = new AudioContext();
    let analyser = audioCtx.createAnalyser();
    analyser.fftSize = freqency_samples * 8;
    analyser.smoothingTimeConstant = 0.5;
    analyser.minDecibels = -60; //default : -100
    analyser.maxDecibels = -25; //default : -30
    let source;

    // onMount(() => {
    //     init();
    // });

    function init() {
        gui = new GUI();
        gui.add(controls, "zoom", 2, 100, 1);
        gui.add(controls, "angle", 0, 360, 1);
        gui.add(controls, "x", 0, 100, 1);
        gui.add(controls, "y", 0, 100, 1);
        gui.add(controls, "z", 0, 100, 1);
        gui.add(controls, "samples", 1, 5, 1);
        navigator.mediaDevices.getUserMedia({ audio: true }).then((stream) => {
            source = audioCtx.createMediaStreamSource(stream);
            source.connect(analyser);
        });

        camera = new THREE.PerspectiveCamera(27, window.innerWidth / window.innerHeight, 1, 100);
        camera.position.z = 72;

        scene = new THREE.Scene();

        // create a custome 2d grid geometry.
        // vertices are the existing coordinates in the grid
        // indeces are the order to draw the triangles, six values per square
        // height is the height of each vertex
        let geometry = new THREE.BufferGeometry();
        let vertices = [];
        let indices = [];
        heights = [];
        // for log
        let yPowMax = Math.log(ySize);
        let yBase = Math.E;

        // generate vertices for grid geometry, hight is currently random
        for (let i = 0; i <= xSegments; i++) {
            let x = i * xSegmentSize - xhalfSize; //midpoint of mesh is 0,0
            for (let j = 0; j <= ySegments; j++) {
                let powr = ((ySegments - j) / ySegments) * yPowMax;
                let y = -Math.pow(yBase, powr) + yhalfSize + 1;
                // let y = j * ySegmentSize - yhalfSize;
                vertices.push(x, y, 0);
                heights.push(0); // for now our mesh is flat, so heights are zero
            }
        }

        heights = new Uint8Array(heights);

        // Add the position data to the geometry buffer
        geometry.setAttribute("position", new THREE.Float32BufferAttribute(vertices, 3));

        // generate indices (data for element buffer). This says where each triangle goes
        // the code might look complex, but it is essentially the way you tile the plane with
        // triangles. Each square segment has 4 vertices, a, b, c, d. Which make 2 triangles.
        // a  b
        // d  c
        // Looking above, we can make a triangle by connecting a b d
        // and similarly for b c d. These make the two faces of our mesh segment.

        for (let i = 0; i < xSegments; i++) {
            for (let j = 0; j < ySegments; j++) {
                let a = i * (ySegments + 1) + (j + 1);
                let b = i * (ySegments + 1) + j;
                let c = (i + 1) * (ySegments + 1) + j;
                let d = (i + 1) * (ySegments + 1) + (j + 1);
                // generate two faces (triangles) per iteration
                indices.push(a, b, d); // face one
                indices.push(b, c, d); // face two
            }
        }
        geometry.setIndex(indices);
        // This bit of code defines a lookup table (LUT) for our colors.
        // Right now we are only providing one color in this "string" value below (Red).
        // This will be useful later on when we want a variety of colors to work with
        // We will just add colors to this string and send them to the shader

        //If I want to define lut in the shader, I need to pass it as a uniform

        // let rgb = [[1, 0, 0]];  // red
        // var lut = [];
        // for (let n=0; n<1; n++) {
        //     lut.push(new THREE.Vector3(rgb[n][0], rgb[n][1], rgb[n][2]));
        // }
        // let uniforms = {
        //     vLut: { type : "v3v", value: [new THREE.Vector3(1, 0, 0)] },
        // }

        // Bind the shaders and uniforms to the material
        let material = new THREE.ShaderMaterial({
            vertexShader: vertexShader,
            fragmentShader: fragmentShader,
            // uniforms: uniforms,
        });

        // Initialize the renderer and connect it to the DIV
        renderer = new THREE.WebGLRenderer({ antialias: true });
        renderer.setPixelRatio(window.devicePixelRatio);
        renderer.setSize(window.innerWidth, window.innerHeight);
        container.appendChild(renderer.domElement);

        // Give the mesh a material with color (Purple)
        mesh = new THREE.Mesh(geometry, material);
        scene.add(mesh);

        // add attribute that is accessible to the shader
        geometry.setAttribute("displacement", new THREE.Uint8BufferAttribute(heights, 1));
        mesh.geometry.computeVertexNormals();

        // Render the scene!
        // renderer.render(scene, camera);

        const orbitControls = new OrbitControls(camera, renderer.domElement);
        orbitControls.minDistance = 8;
        orbitControls.maxDistance = 100;
        // orbitControls.maxPolarAngle = Math.PI / 2;

        animate();
    }

    function animate() {
        if(running){
      
            update();
            renderer.render(scene, camera);
            requestAnimationFrame(animate);
        }
    }

    function update() {
        //  console.log("tick", tick);x
        // camera.position.x = controls.x;
        // camera.position.y = controls.y;
        // camera.position.z = controls.z;
        // crypto.getRandomValues(DATA);

        // freqency_samples = 128*2**controls.samples;
        // console.log("freqency_samples", freqency_samples)

        // Find the fundamental frequency using HPS
        analyser.getByteFrequencyData(DATA);
        if (tick % 60 == 0) {
            console.log("START PRINT");
            // console.table(DATA);

            printmyData(DATA);
            // DATA.forEach((element, i) => {
            //     if(element>170){
            //         console.log("index:",i,"value:", element);
            //     }
            // });
            console.log("END PRINT");
            // const fundamental = findFundamentalFrequencyHPS(DATA);
            // header = fundamental.toString();
        }

        //     const frequencyData = {
        //     fundamental: fundamental, // Index of the fundamental frequency in the spectrum array
        //     temp1: DATA[fundamental] / 255, // Intensity of the fundamental frequency (between 0 and 1)
        //     temp2: DATA[Math.floor(fundamental * 2)] / 255, // Intensity of the first overtone (between 0 and 1)
        //     temp3: DATA[Math.floor(fundamental * 3)] / 255, // Intensity of the second overtone (between 0 and 1)
        //     temp4: DATA[Math.floor(fundamental * 4)] / 255, // Intensity of the third overtone (between 0 and 1)
        //     temp5: DATA[Math.floor(fundamental * 5)] / 255, // Intensity of the fourth overtone (between 0 and 1)
        //     temp6: (DATA[Math.floor(fundamental * 6)] / 255 + DATA[Math.ceil(fundamental * 6)] / 255) / 2, // Intensity of the fifth overtone (between 0 and 1)
        // };

        // console.log("frequencyData.temp1", frequencyData.temp1);
        // console.log("frequencyData.temp2", frequencyData.temp2);
        // console.log("frequencyData.temp3", frequencyData.temp3);
        // console.log("frequencyData.temp4", frequencyData.temp4);
        // console.log("frequencyData.temp5", frequencyData.temp5);
        // console.log("frequencyData.temp6", frequencyData.temp6);

        let start_val = freqency_samples + 1;
        let end_val = n_vertices - start_val;
        heights.copyWithin(0, start_val, n_vertices + 1);
        heights.set(DATA, end_val - start_val);
        mesh.geometry.setAttribute("displacement", new THREE.Uint8BufferAttribute(heights, 1));
        tick++;
    }

    function printmyData(spectrumData) {
        // Terskelverdi for å filtrere ut toppunktene (overtonene)
        const thresholdValue = 150;

        // Finn alle indekser over terskelverdien
        const overThresholdIndices = spectrumData.reduce((indices, value, index) => {
            if (value > thresholdValue) {
                indices.push(index);
            }
            return indices;
        }, []);

        // Grupper nærliggende overtoner sammen
        const groupedOvertones = [];
        let currentGroup = [];

        overThresholdIndices.forEach((index, i) => {
            if (i === 0 || index === overThresholdIndices[i - 1] + 1) {
                currentGroup.push(index);
            } else {
                groupedOvertones.push(currentGroup);
                currentGroup = [index];
            }
        });

        if (currentGroup.length > 0) {
            groupedOvertones.push(currentGroup);
        }

        // Skriv ut de grupperte overtonene
        groupedOvertones.forEach((group) => {
            const intensities = group.map((index) => spectrumData[index]);
            const averageIntensity =
                intensities.reduce((total, value) => total + value, 0) / intensities.length;
            console.log(`Group: ${group}, Average Intensity: ${averageIntensity}`);
        });
        let fundamentalEstimation = null;
        let sumOfDistances = 0;

        if (overThresholdIndices.length >= 2) {
        for (let i = 0; i < overThresholdIndices.length - 1; i++) {
            const distance = overThresholdIndices[i + 1] - overThresholdIndices[i];
            sumOfDistances += distance;
        }

        const averageDistance = sumOfDistances / (overThresholdIndices.length - 1);
        fundamentalEstimation = overThresholdIndices[0] + averageDistance / 2;
        }

        if (fundamentalEstimation !== null) {
        console.log(`Estimated Fundamental Frequency: ${fundamentalEstimation}`);
        } else {
        console.log("Unable to estimate the Fundamental Frequency.");
        }
    }


// Estimer fundamentalfrekvensen som gjennomsnittet av avstanden mellom oppdagede toppunktene




    function findFundamentalFrequencyHPS(spectrum) {
        const hps = new Array(spectrum.length).fill(1);

        // Compute HPS
        for (let harmonic = 2; harmonic <= 7; harmonic++) {
            for (let i = 0; i < spectrum.length; i++) {
                hps[i] *= spectrum[Math.floor(i / harmonic)];
            }
        }

        // Find the peak in the HPS spectrum, which corresponds to the fundamental frequency
        let maxAmplitude = 0;
        let fundamental = 0;
        for (let i = 1; i < hps.length; i++) {
            if (hps[i] > maxAmplitude) {
                maxAmplitude = hps[i];
                fundamental = i;
            }
        }

        return fundamental;
    }
</script>

<button on:click={init}>Start</button>
<button on:click={()=>{running=false;}}>Stop</button>
<h4>{header}</h4>
<div bind:this={container} id="Spectrogram" />

<style>
    * {
        margin: 0;
        padding: 0;
        overflow: hidden;
    }
</style>
