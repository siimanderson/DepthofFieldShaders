/* interface
outputs = ["Output"]

[[textures]]
name = "ColorTargetA"
addressU = "clamp"
addressV = "clamp"
minFilter = "linear"
magFilter = "linear"

[[textures]]
name = "ColorTargetB"
addressU = "clamp"
addressV = "clamp"
minFilter = "linear"
magFilter = "linear"
*/

uniform sampler2D ColorTargetA;
uniform sampler2D ColorTargetB;

out vec4 Output;


void main(){
    vec4 colorMapA = texture(ColorTargetA, f_texcoord);
    vec4 colorMapB = texture(ColorTargetB, f_texcoord);

    Output = max(colorMapA, colorMapB);
}