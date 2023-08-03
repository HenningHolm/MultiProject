varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vUv;

// Function to define the palette
vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);

    return a + b * cos(6.28318 * (c * t + d));
}

void main() {
    float d = length(vPosition);
    d -= 0.5;
    d = abs(d);
    
    // Use the palette function to define the color
    vec3 col = palette(length(vUv) + d * 0.4 + vUv.x * 0.4);

    // Apply some modifications to d
    d = sin(d * 8.0 + vUv.y) / 8.0;
    d = abs(d);
    d = pow(0.01 / d, 0.9);

    gl_FragColor = vec4(col * d, 1.0);
}