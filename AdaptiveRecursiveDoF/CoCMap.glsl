/* interface 
outputs = ["CoCMap"]

[[textures]]
name = "AOVTarget"

[[uniforms]]
name = "Scale"
type = "float"
min = 0.1
max = 1.5

[[uniforms]]
name = "FocalLength"
type = "float"
min = 0.01
max = 1.0
*/

uniform sampler2D AOVTarget;

uniform float Scale;
uniform float FocalLength;

out vec4 CoCMap;

void main() {
    float pixelDepth = texture(AOVTarget, f_texcoord).r;
    float remaped = remap(pixelDepth, 0.0, 100.0, 0.0, 1.0);
    //float remaped = 1.0 / pixelDepth;
    float CoC = abs(1.0 - FocalLength / remaped);
    float ScaledCoC = Scale * CoC;
    

    CoCMap = vec4(ScaledCoC);
}