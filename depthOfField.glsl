
/* interface
outputs = ["Output"]

[[textures]]
name = "ColorTarget"

[[textures]]
name = "AOVTarget"

[[uniforms]]
name= "blurDepth"
type = "float"
min = 0.01
max = 1.0

[[uniforms]]
name = "Radius"
type = "int"
min = 1
max = 20
*/

uniform sampler2D ColorTarget;
uniform sampler2D AOVTarget;

uniform float blurDepth;
uniform int Radius;

out vec4 Output;

vec4 box(int radius) {
    vec4 sum = vec4(0);

    for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            sum += texture(ColorTarget, f_texcoord + u_texel*vec2(x,y));
        }
    }
    return sum / pow(radius * 2 + 1, 2);
}

void main () {

    //vec3 viewDir = viewDirection(f_texcoord);
    float DepthInMayaU = texture(AOVTarget, f_texcoord).r;
    float depthRemaped = saturate(remap(DepthInMayaU, 25.0, 300.0, 0.0, 1.0));
    vec4 color = vec4(0.0);
    

    if (depthRemaped >= blurDepth){
        color = box(Radius);
    }
    /* else if (depth >= Background){
        Output = box(Radius);
    } */
    else {
        color = texture(ColorTarget, f_texcoord);
    }

    Output = color;

}