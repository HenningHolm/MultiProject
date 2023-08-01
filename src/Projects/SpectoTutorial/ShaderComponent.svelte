
  
  <!-- Add the vertex shader code here -->
  <script type="x-shader/x-vertex" id="vertexshader">
      export let projectionMatrix;
    export let modelViewMatrix;
    export let position;
    // void main() {
    //   gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    // }
  </script>
  
<!-- 

  <script type="x-shader/x-vertex" id="vertexShaderGlow">
      uniform vec3 viewVector;
      uniform float c;
      uniform float p;
      varying float intensity;
      void main()
      {
          vec3 vNormal = normalize( normalMatrix * normal );
          vec3 vNormel = normalize( normalMatrix * viewVector );
          intensity = pow( c - dot(vNormal, vNormel), p );
          gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
      }
  </script> -->