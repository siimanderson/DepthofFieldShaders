/* interface
outputs = ["Output"]

[[textures]]
name = "sceneTex"


[[uniforms]]
name = "center"
type = "vec2"

[[uniforms]]
name = "distanceMult"
type = "float"
min = 0.0
max = 1.0

[[uniforms]]
name = "shockParams"
type = "vec3"
*/
//https://www.geeks3d.com/20091116/shader-library-2d-shockwave-post-processing-filter-glsl/

uniform sampler2D sceneTex; // 0
uniform vec2 center; // Mouse position
uniform float distanceMult; // effect elapsed distanceMult
uniform vec3 shockParams; // 10.0, 0.8, 0.1

out vec4 Output;
void main() 
{ 
  vec2 uv = f_texcoord;
  vec2 texCoord = uv;
  float distance = distance(uv, center);
  if ( (distance <= (distanceMult + shockParams.z)) && 
       (distance >= (distanceMult - shockParams.z)) ) 
  {
    float diff = (distance - distanceMult); 
    float powDiff = 1.0 - pow(abs(diff*shockParams.x), shockParams.y); 
    float diffTime = diff  * powDiff; 
    vec2 diffUV = normalize(uv - center); 
    texCoord = uv + (diffUV * diffTime);
  } 
  Output = texture(sceneTex, texCoord);
}