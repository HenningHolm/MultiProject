<script lang="ts">
    import * as THREE from "three";
    import { onMount } from "svelte";
    import vertexShader from "./Shaders/SpectoVertex.glsl";
    import fragmentShader from "./Shaders/SpectoFragment.glsl";
    import { GUI } from "three/examples/jsm/libs/lil-gui.module.min.js";
    import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

    let container: HTMLDivElement;
    
    let gui;
    let controls =  {
        zoom : 20,
        angle : 80,
        x: 0,
        y: 0,
        z: 0,
        samples: 1,
    };

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

    let audioCtx = new AudioContext();
    let analyser = audioCtx.createAnalyser();
    analyser.fftSize = freqency_samples *8;
    analyser.smoothingTimeConstant = 0.5;
    let source;


    // onMount(() => {
    //     init();
    // });

    function init() {

        gui = new GUI();
        gui.add(controls, 'zoom', 2, 100, 1);
        gui.add(controls, 'angle', 0, 360, 1);
        gui.add(controls, 'x', 0, 100, 1);
        gui.add(controls, 'y', 0, 100, 1);
        gui.add(controls, 'z', 0, 100, 1);
        gui.add(controls, 'samples', 1, 5, 1);
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
        let yPowMax = Math.log(ySize)
        let yBase = Math.E;

        // generate vertices for grid geometry, hight is currently random
        for (let i = 0; i <= xSegments; i++) {
            let x = i * xSegmentSize - xhalfSize; //midpoint of mesh is 0,0
            for (let j = 0; j <= ySegments; j++) {
                
                let powr = (ySegments - j) / ySegments*yPowMax;
                let y = -Math.pow(yBase, powr) + yhalfSize+1;
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


        const orbitControls = new OrbitControls( camera, renderer.domElement );
        orbitControls.minDistance = 8;
        orbitControls.maxDistance = 100;
        // orbitControls.maxPolarAngle = Math.PI / 2;

        animate();
    }

    function animate() {
        update();
        renderer.render(scene, camera);
        requestAnimationFrame(animate);
    }

    function update(){
        // camera.position.x = controls.x;
        // camera.position.y = controls.y;
        // camera.position.z = controls.z;
        // crypto.getRandomValues(DATA);

        // freqency_samples = 128*2**controls.samples;
        // console.log("freqency_samples", freqency_samples)
        analyser.getByteFrequencyData(DATA);
        let start_val = freqency_samples+1;
        let end_val = n_vertices-start_val;
        heights.copyWithin(0, start_val, n_vertices+1);
        heights.set(DATA, end_val-start_val);
        mesh.geometry.setAttribute("displacement", new THREE.Uint8BufferAttribute(heights, 1));
    }

</script>
<button on:click={init}>start</button>
<div bind:this={container} id="Spectrogram" />

<style>
    * {
        margin: 0;
        padding: 0;
        overflow: hidden;
    }
</style>
