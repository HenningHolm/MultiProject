uniform float uTime;
varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vUv;

void main() {
    vPosition = position;
    vNormal = normal;
    vUv = uv;

    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    vec4 projectedPosition = projectionMatrix * mvPosition;

    // Pass time as a varying variable to the fragment shader
    vUv.y = uTime;

    gl_Position = projectedPosition;
}