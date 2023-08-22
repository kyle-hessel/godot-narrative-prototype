shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset;

uniform float albedo_energy : hint_range(0.5, 2.0) = 1.2;
uniform float frequency : hint_range(0.0, 1920.0) = 330.0;
uniform float radius_weight : hint_range(0.1, 10.0) = 2.0;
uniform float shade_bias : hint_range(0.1, 10.0) = 2.0;
uniform float shade_amount : hint_range(0.0, 1.0) = 0.7;

float aastep(float threshold, float value) {
	float afwidth = 0.7 * length(vec2(dFdx(value), dFdy(value)));
	return smoothstep(threshold-afwidth, threshold+afwidth, value);
}

// AUTHOR: Room204 Studios. Small changes by me.

void vertex() {
	 UV= UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
 	vec4 albedo_tex = texture(texture_albedo,base_uv);
 	ALBEDO = albedo.rgb * albedo_tex.rgb * albedo_energy;
}

void light() {
	vec2 halftone_coord = mat2(vec2(0.707, -0.707), vec2(0.707, 0.707)) * (FRAGCOORD.xy * frequency / VIEWPORT_SIZE.x);
	
	// get distance to center of next circle
	vec2 nearest = 2.0 * fract(halftone_coord) - 1.0;
	float dist = length(nearest);
	
	// get size based on the lighting
	float shading = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float radius = sqrt(max(1.0 - shading * shade_bias, 0.0)) * radius_weight;

	// pick black or white based on radius
	vec3 white = vec3(1.0, 1.0, 1.0);
	vec3 black = vec3(0.0, 0.0, 0.0);
	vec3 spots = mix(white, black, aastep(radius, dist)); // reversed to shaded in white
	
	DIFFUSE_LIGHT = ALBEDO - (ALBEDO * spots * shade_amount);
}