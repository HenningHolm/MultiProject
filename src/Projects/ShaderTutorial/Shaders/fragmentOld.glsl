void main() {
	vec3 color = vec3( 1, 0, 1 );
	
	// swizzle
	// color.rg = color.xy
	color.rg = vec2( 0, 1 );
	color.zyx = vec3( 0, 1, 0 );

	color += vec3( .5, 0, .5 );
	//vec2 myVector = color.xx/vec2( 1, 2 );
	// clamp(-5, 0, -0.1 ) == -0.1
	// bvec3 comparedVector = equal(vec3(0), vec3(1));
	// comparedVector = (false, false, false) = (0, 0, 0) 

	gl_FragColor = vec4( color.xyx, 1 );
}
// functions
// abs, sin, cos, tan, asin, acos, atan, 
// pow, exp, log, exp2, log2, sqrt, inversesqrt, 
// sign, floor, ceil, fract, mod, min, max, 
// clamp, mix, step, smoothstep, length, distance, dot, cross, 
// normalize, faceforward, reflect, refract, matrixCompMult, 
// lessThan, lessThanEqual, greaterThan, greaterThanEqual, equal, notEqual, 
// any, all, not, dFdx, dFdy, fwidth, 
// texture2D, texture2DProj, texture2DLod, texture2DProjLod, textureCube, textureCubeLod
// x%10 = mod(x, 10.0)


void main(){
	gl_FragColor = vec4( 1, 0, 0, 1 );
}

