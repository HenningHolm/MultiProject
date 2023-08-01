<script lang="ts">
    import { onMount } from "svelte";
    import * as THREE from "three";
    import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
    import { GUI } from 'three/addons/libs/lil-gui.module.min.js';

    let camera, renderer, gui;
    let cube;
    let light, ambientLight;
    let scene;
    let container: HTMLDivElement;

    let controls =  {
        rotationSpeed : 0.02,
        zoom : 20,
        angle : 80,
        lightZ : 100,
    };
    
    onMount(() => {
        setScene();
        animate();
    });

    function setScene() {

        const canvasWidth = window.innerWidth;
        const canvasHeight = window.innerHeight;

        // RENDERER
        renderer = new THREE.WebGLRenderer({ antialias: true });
        renderer.setPixelRatio(window.devicePixelRatio);
        renderer.setSize(canvasWidth, canvasHeight);
        renderer.setClearColor(0x555);

        // CAMERA
        camera = new THREE.PerspectiveCamera(45, canvasWidth / canvasHeight, 1, 3000);
        camera.position.z = 50;

        // SCENE and CONTROLSs
        scene = new THREE.Scene();
        const orbitControls = new OrbitControls( camera, renderer.domElement );
        orbitControls.minDistance = 8;
        orbitControls.maxDistance = 50;
        orbitControls.maxPolarAngle = Math.PI / 2;

        // LIGHTS
        ambientLight = new THREE.AmbientLight( 0x7c7c7c, 1.0 );
        light = new THREE.DirectionalLight( 0x404040, 100.0 );
        light.position.set( 10, 10 , controls.lightZ );
        // light = new THREE.HemisphereLight( 0xffffbb, 0x080820, 1 );
        scene.add(ambientLight);
        scene.add(light);

        // OBJECT
        const geometry2 = new THREE.BoxGeometry(10, 10, 10);
        const material2 = new THREE.MeshStandardMaterial();
        cube = new THREE.Mesh(geometry2, material2);
        scene.add(cube);

        // GUI
        gui = new GUI();
        gui.add(controls, 'rotationSpeed', 0, 0.5);
        gui.add(controls, 'zoom', 2, 100);
        gui.add(controls, 'angle', 0, 360);
        gui.add(controls, 'lightZ', 0, 100)
        //close gui
        gui.close();
        container.appendChild(renderer.domElement);
    }

    function render() {
        renderer.render(scene, camera);
    }

    function animate() {
        requestAnimationFrame( animate );
        cube.rotation.x += 0.01;
        cube.rotation.y += 0.01;
        light.position.set( 10, 10 , controls.lightZ );
        render();
    }

</script>

<div bind:this={container} id="Spectrogram" />
