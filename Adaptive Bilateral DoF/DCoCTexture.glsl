/* interface
outputs = ["DCoC"]

[[textures]]
name = "ColorTarget"

[[textures]]
name = "AOVTarget"

[[uniforms]]
name = "FocalLength"
type = "float"
min = 0.01
max = 0.1

[[uniforms]]
name = "LensDiameter"
type = "float"
min = 0.1
max = 1.0

[[uniforms]]
name = "FocusRegionDepth"
type = "float"
min = 0.0
max = 1.0
*/

uniform sampler2D ColorTarget;
uniform sampler2D AOVTarget;

uniform float FocalLength;
uniform float LensDiameter;
uniform float FocusRegionDepth;

out vec4 DCoC;

float CirceOfConfusion(vec2 pixelCoordinate, float focalLength){
    float depthInMayaUnits = texture(AOVTarget, pixelCoordinate).r;
    float remapedDepth = 1.0 / depthInMayaUnits;

    float topPartOfEquation = LensDiameter * focalLength * (FocusRegionDepth - remapedDepth);
    float lowerPartOfEquation = FocusRegionDepth * (remapedDepth - focalLength);

    return abs(topPartOfEquation / lowerPartOfEquation);
}

void main(){

    //Circle of Confusion calculations
    float CoC = CirceOfConfusion(f_texcoord, FocalLength);

    DCoC = vec4(CoC);
}