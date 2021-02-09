sampler2D AOVTarget {
    "addressU": "MIRROR",
    "addressV": "MIRROR"
};

uint FocalLengthOfLens = 0.0 {
    "toggle": ["28mm", "50mm", "100mm"]
};

float FocalDistance = 0.0 {
    "min": 0.0,
    "max": 1.0
};

float ApertureSize = 0.5 {
    "min": 0.0,
    "max": 1.0
};

int MaximumCoCDiameter = 1 {
    "min": 1,
    "max": 30
};

out vec4 Output;

##GLSL

void main(){
    float focalLength = 0;

    if (FocalLengthOfLens == 0){
        focalLength = 0.28;
    }
    else if (FocalLengthOfLens == 1){
        focalLength = 0.50;
    }
    else {
        focalLength = 1.0;
    }

    float FarClipDistance = u_farClip;

    float SceneDepth = texture(AOVTarget, f_texcoord).r * FarClipDistance;

    float CoCDiameter = ApertureSize * (abs(SceneDepth - FocalDistance) / SceneDepth) * (focalLength / (FocalDistance - focalLength));

    float sensorHeight = 0.024;

    float percentOfSensor = CoCDiameter / sensorHeight;

    float blurFactor = clamp(percentOfSensor, 0.0, MaximumCoCDiameter);

    vec3 ModifiedOutput = texture(AOVTarget, f_texcoord).rgb;

    Output = vec4(ModifiedOutput, blurFactor);
}