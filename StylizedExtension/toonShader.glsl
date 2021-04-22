/* interface
outputs = ["Output"]

[[textures]]
name = "NormalTarget"

[[textures]]
name = "ColorTarget"

[[uniforms]]
name = "lightDir"
type = "vec3"

[[uniforms]]
name = "fraction"
type = "float"
*/
uniform sampler2D NormalTarget;
uniform sampler2D ColorTarget;
uniform vec3 lightDir;
uniform float fraction;
//https://stackoverflow.com/questions/5795829/using-opengl-toon-shader-in-glsl
out vec4 Output;

void main() {
    float intensity;
	vec4 color;
    vec4 target = texture(ColorTarget, f_texcoord);
    vec3 normal = texture(NormalTarget, f_texcoord).rgb;
	intensity = dot(lightDir,normalize(normal));

	if (intensity > pow(0.95, fraction))
		color = vec4(1.0,1.0,1.0,1.0);
	else if (intensity > pow(0.5, fraction))
		color = vec4(0.6,0.6,0.6,1.0);
	else if (intensity > pow(0.25, fraction))
		color = vec4(0.4,0.4,0.4,1.0);
	else
		color = vec4(0.2,0.2,0.2,1.0);
    
    Output = target*color;
}