/* interface
outputs = ["COCMap"]

[[textures]]
name = "ColorTarget"
addressU = "clamp"
addressV = "clamp"
minFilter = "linear"
magFilter = "linear"

[[textures]]
name = "AOVTarget"
addressU = "clamp"
addressV = "clamp"
minFilter = "linear"
magFilter = "linear"

[[uniforms]]
name = "FocalLength"
type = "float"
min = 0.01
max = 0.05

[[uniforms]]
name = "FocalDistance"
type = "float"
min = 0.1
max = 5.0

[[uniforms]]
name = "ApertureSize"
type = "float"
min = 0.001
max = 0.14

[[uniforms]]
name = "MaximumCoCDiameter"
type = "float"
min = 0.0
max = 0.04
*/

uniform sampler2D ColorTarget;
uniform sampler2D AOVTarget;

uniform float FocalLength;
uniform float FocalDistance;
uniform float ApertureSize;
uniform float MaximumCoCDiameter;

out vec4 COCMap;

void main(){
    
    float FarClipDistance = u_farClip;

    float SceneDepth = texture(AOVTarget, f_texcoord).r;
    float remaped = remap(SceneDepth, 25.0, 100.0, 0.0, 1.0);

    float CoCDiameter = ApertureSize * (abs(remaped - FocalDistance) / remaped) * (FocalLength / (FocalDistance - FocalLength));

    float sensorHeight = 0.024;

    float percentOfSensor = CoCDiameter / sensorHeight;

    float blurFactor = clamp(percentOfSensor, 0.0, MaximumCoCDiameter);

    vec3 Color = texture(ColorTarget, f_texcoord).xyz;

    COCMap = vec4(Color, blurFactor);
}