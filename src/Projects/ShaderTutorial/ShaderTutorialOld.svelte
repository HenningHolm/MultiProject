<script lang="ts">
    import { onMount } from "svelte";
    import * as THREE from "three";
    import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
    import vertexShader from "./Shaders/vertex.glsl"
    import fragmentShader from "./Shaders/fragment.glsl";


    let camera, renderer;
    let light, ambientLight;
    let scene;
    let container: HTMLDivElement;
    const myShader = new THREE.RawShaderMaterial({
    vertexShader: vertexShader,
    fragmentShader: fragmentShader,
    
})
    
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
        renderer.setClearColor(0x000);

        // CAMERA
        camera = new THREE.PerspectiveCamera(45, canvasWidth / canvasHeight, 1, 3000);
        camera.position.z = 3;

        // SCENE and CONTROLSs
        scene = new THREE.Scene();
        const orbitControls = new OrbitControls( camera, renderer.domElement );
        orbitControls.minDistance = 2;
        orbitControls.maxDistance = 50;
        orbitControls.maxPolarAngle = Math.PI / 2;

        // LIGHTS
        // ambientLight = new THREE.AmbientLight( 0x7c7c7c, 1.0 );
        // light = new THREE.DirectionalLight( 0x404040, 100.0 );
        // light.position.set( 10, 10 , 10);
        // scene.add(ambientLight);
        // scene.add(light);

        // OBJECT
        const geometry = new THREE.IcosahedronGeometry(1, 5);
        // const material = new THREE.ShaderMaterial(myShader);
        const pGeometry = new THREE.PlaneGeometry( 2, 2, 3, 3 );
        const material = new THREE.ShaderMaterial({
            vertexShader: vertexShader,
            fragmentShader: fragmentShader,
            wireframe: true,
        });
        const material2 = new THREE.MeshPhongMaterial({color: 0x00ff00});
        const ico = new THREE.Mesh(pGeometry, material);
        scene.add(ico);

        container.appendChild(renderer.domElement);
        renderer.render(scene, camera);
    }

    function render() {
        renderer.render(scene, camera);
    }

    function animate() {
        requestAnimationFrame( animate );
        render();
    }

</script>

<div bind:this={container} id="Spectrogram" />
