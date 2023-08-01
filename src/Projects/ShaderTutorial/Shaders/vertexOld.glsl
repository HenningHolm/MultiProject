attribute vec3 position;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix; // equals viewMatrix * modelMatrix

// uniform mat4 modelMatrix;
// uniform mat4 viewMatrix;

varying vec3 vPosition;

void main() {
	vPosition = position;
	// modelMatrix => transformation of the model
	// viewMatrix => transformation of the camera
	// projectionMatrix => projects the object to the screen
	
	//MVP order matters
	vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
	vec4 projectedPosition = projectionMatrix * mvPosition;

	gl_Position = projectedPosition;
}
