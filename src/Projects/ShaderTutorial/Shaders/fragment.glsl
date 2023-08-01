// flat varying vec3 vPosition;
varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vUv;

void main(){
	float d = length( vPosition );
	d -= 0.5;
	d = abs( d );
	gl_FragColor = vec4( d, vPosition.yz, 1 );
}

