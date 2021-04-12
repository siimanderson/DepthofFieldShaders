/* interface
outputs = ["Output"]

[[textures]]
name = "ColorTarget"

[[textures]]
name = "WeightMap"

*/

uniform sampler2D ColorTarget;
uniform sampler2D WeightMap;

out vec4 Output;

void main() {
    float redChannel = 0.0;
    float greenChannel = 0.0;
    float blueChannel = 0.0;

    //float alpha = texelFetch(WeightMap, ivec2(gl_FragCoord.xy), 0).r;
    float alpha = texture(WeightMap, f_texcoord).r;

    vec4 color = texelFetch(ColorTarget, ivec2(gl_FragCoord.xy), 0);
    vec4 leftColor = texelFetch(ColorTarget, ivec2(gl_FragCoord.x + 1.0, gl_FragCoord.y), 0);

    redChannel = (1.0 - alpha) * color.r + alpha * leftColor.r;
    greenChannel = (1.0 - alpha) * color.g + alpha * leftColor.g;
    blueChannel = (1.0 - alpha) * color.b + alpha * leftColor.b;

    Output = vec4(redChannel, greenChannel, blueChannel, 1.0);
}