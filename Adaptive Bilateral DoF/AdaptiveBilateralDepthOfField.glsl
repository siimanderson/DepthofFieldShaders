sampler2D ColorTarget {
    "addressU": "MIRROR",
    "addressV": "MIRROR"
};

sampler2D AOVTarget {
    "addressU": "MIRROR",
    "addressV": "MIRROR"
};

int LensDiameter = 3 {
    "min": 1,
    "max": 20
};

int StandardDeviation1 = 1 {
    "min" = 1,
    "max" = 300
};

int StandardDeviation2 = 1 {
    "min" = 1,
    "max" = 300
};

uint FocalLengthOfLens = 0 {
    "toggle": ["28mm", "50mm", "100mm"]
};

float BlurDistance = 1.0 {
	"min": 0.01,
	"max": 1.0
}; 

uniform vec2 DepthRange = vec2(0.01, 100.0);

out vec4 Output;

##GLSL

float CirceOfConfusion(vec2 pixelCoordinate, float FocalLength){
    float depthInMayaUnits = texture(AOVTarget, pixelCoordinate).r;
    float remapedDepth = remap(depthInMayaUnits, DepthRange.x, DepthRange.y, 0.0, 1.0);

    float topPartOfEquation = LensDiameter * FocalLength * (BlurDistance - remapedDepth);
    float lowerPartOfEquation = BlurDistance * (remapedDepth - FocalLength);

    return abs(topPartOfEquation / lowerPartOfEquation);
}

vec3 equationBilateral(float distance, float depthCenterPixel, float depthOtherPixel){
    return vec3(exp(-(pow(distance, 2) / 2 * pow(StandardDeviation1, 2))) * exp(-(pow(depthOtherPixel - depthCenterPixel, 2) / 2 * pow(StandardDeviation2, 2))));
}

vec4 pixelColor(float CoC, vec4 pixel){
    vec4 sum = vec4(0);
    for (float x = -CoC; x <= CoC; x++) {
        for (float y = -CoC; y <= CoC; y++) {
            vec4 qTexel = texture(ColorTarget, f_texcoord + u_texel*vec2(x,y));
            float distanceBetweenPixels = length(vec2(qTexel.x - pixel.x, qTexel.y - pixel.y));
            vec3 Bilateral = equationBilateral(distanceBetweenPixels, pixel.z, qTexel.z);
            sum += texture(ColorTarget, f_texcoord + u_texel * vec2(x, y) * Bilateral.xy);
        }
    }
    return sum;
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

    vec4 pixel = vec4(0);
    //pixelDepth
    
    float pDepth = texture(AOVTarget, f_texcoord).r;
    float pRemapedDepth = remap(pDepth, DepthRange.x, DepthRange.y, 0.0, 1.0);

    if(pRemapedDepth > BlurDistance){
        pixel = pixelColor(CoC, texture(ColorTarget, f_texcoord + u_texel));
    }
    else {
        pixel = texture(ColorTarget, f_texcoord + u_texel); 
    }   

    Output = pixel;
}