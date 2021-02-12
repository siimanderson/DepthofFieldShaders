sampler2D AOVTarget {
    "addressU": "MIRROR",
    "addressV": "MIRROR"
};

uint FocalLengthOfLens = 0 {
    "toggle": ["28mm", "50mm", "100mm"]
};

float BlurDistance = 1.0 {
	"min": 0.01,
	"max": 1.0
}; 

int LensDiameter = 3 {
    "min": 1,
    "max": 20
};

out vec4 Output;

#GLSL

float CirceOfConfusion(vec2 pixelCoordinate, float FocalLength){
    float depthInMayaUnits = texture(AOVTarget, pixelCoordinate).r;
    float remapedDepth = remap(depthInMayaUnits, DepthRange.x, DepthRange.y, 0.0, 1.0);

    float topPartOfEquation = LensDiameter * FocalLength * (BlurDistance - remapedDepth);
    float lowerPartOfEquation = BlurDistance * (remapedDepth - FocalLength);

    return abs(topPartOfEquation / lowerPartOfEquation);
}

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

    //Circle of Confusion calculations
    float CoC = CirceOfConfusion(f_texcoord, focalLength);

    vec4 AOVoutput = texture(AOVTarget, f_texcoord);
    AOVoutput.a = CoC;

    Output = AOVoutput;
}