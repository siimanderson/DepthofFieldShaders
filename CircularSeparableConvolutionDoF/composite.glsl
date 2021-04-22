/* interface

outputs = ["finalResult"]

[[textures]]
name = "blurredTexture"

[[textures]]
name = "ColorTarget"

[[textures]]
name = "AOVTarget"

[[uniforms]]
name = "blend"
type = "float"
min = 0.0
max = 1.0

[[uniforms]]
name = "FocusDistance"
type = "float"
min = 0.0
max = 1.0
*/

uniform sampler2D blurredTexture;
uniform sampler2D ColorTarget;
uniform sampler2D AOVTarget;

uniform float FocusDistance;

uniform float blend;

out vec4 finalResult;

void main(){
    vec4 color = vec4(0.0);

    vec4 colorTarget = texture(ColorTarget, f_texcoord);
    vec4 blur = texture(blurredTexture, f_texcoord);
    //pixelDepth  
    float pDepth = texture(AOVTarget, f_texcoord).r;
    float pRemapedDepth = remap(pDepth, 25.0, 300.0, 0.0, 1.0);

    if (pRemapedDepth > FocusDistance) {
        color = lerp(colorTarget, blur, blend);
    } else {
        color = colorTarget;
    }

    finalResult = color;
}