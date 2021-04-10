/* interface
outputs = ["Output"]

[[textures]]
name = "CoCMap"
addressU = "clamp"
addressV = "clamp"
minFilter = "linear"
magFilter = "linear"

[[textures]]
name = "ColorTarget"
addressU = "clamp"
addressV = "clamp"
minFilter = "linear"
magFilter = "linear"

[[textures]]
name = "DepthSample"
addressU = "clamp"
addressV = "clamp"
minFilter = "linear"
magFilter = "linear"

[[uniforms]]
name = "angle"
type = "float"
min = 0.0
max = 90.0
*/
/* sampler2D CoCMap {
    "addressU": "CLAMP",
    "addressV": "CLAMP",
    "minFilter": "LINEAR",
	"magFilter": "LINEAR"
};

sampler2D ColorTarget {
    "addressU": "CLAMP",
    "addressV": "CLAMP",
    "minFilter": "LINEAR",
	"magFilter": "LINEAR"
};

sampler2D DepthSample {
    "addressU": "CLAMP",
    "addressV": "CLAMP",
    "minFilter": "LINEAR",
	"magFilter": "LINEAR"
};

float angle = 45.0 {
    "min": 0.0,
    "max": 180.0
};

out vec4 Output;

##GLSL */

uniform sampler2D CoCMap;
uniform sampler2D ColorTarget;
uniform sampler2D DepthSample;

uniform float angle;

out vec4 Output;

void OffSetData(float angle, inout vec2 vec2Array[13]){
    float aspectRatio = u_resolution.x / u_resolution.y;
    //vec2 vec2Array[13];
    float radius = 0.5;

    vec2 pt = vec2(radius * cos(angle), radius * sin(angle));

    pt.x = pt.x / aspectRatio;

    float numSamples = 13.0;
    for(int i = 0; i < numSamples; i++){
        float t = i / (numSamples - 1.0);
        vec2Array[i] = lerp(-pt, pt, t);
    }
    
}

void main(){
    vec2 Offsets[13];
    OffSetData(angle, Offsets);

    const float bleedingBias = 0.02;
    //const float bleedingBias = 5.0;
    const float bleedingMult = 30.0;

    vec4 centerPixel = texture(CoCMap, f_texcoord);
    float centerDepth = texture(DepthSample, f_texcoord).r;

    vec4 color = vec4(0.0);
    float totalWeight = 0.0;

    float numSamples = 13.0;
    for(int t = 0; t < numSamples; t++){
        vec2 offset = Offsets[t];

        vec2 sampleCoords = f_texcoord + offset * centerPixel.a;

        vec4 samplePixel = texture(CoCMap, sampleCoords);
        float sampleDepth = texture(DepthSample, sampleCoords).r;
        vec4 sampleColor = texture(ColorTarget, sampleCoords);

        float weight = sampleDepth < centerDepth ? samplePixel.a * bleedingMult : 1.0;
        weight = (centerPixel.a > samplePixel.a + bleedingBias) ? weight : 1.0;
        weight = saturate(weight);

        color += sampleColor * weight;
        totalWeight += weight;
    }

    Output = color / totalWeight;
}