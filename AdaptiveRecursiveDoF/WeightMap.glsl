/* interface
outputs = ["WeightMap"]

[[textures]]
name = "CoCMap"

[[textures]]
name = "BlurredDepthMap"

[[uniforms]]
name = "Cmin"
type = "float"
min = 0.1
max = 0.8

[[uniforms]]
name = "FocalLength"
type = "float"
min = 0.01
max = 1.0
*/

uniform sampler2D CoCMap;
uniform sampler2D BlurredDepthMap;

uniform float Cmin;
//uniform float Scale;
uniform float FocalLength;
#define Scale 1.0

out vec4 WeightMap;

float ForeGroundOutOfFocusRegion(){
    return Scale * FocalLength / (Scale + Cmin);
}

float BackGroundOutOfFocusRegion(){
    return Scale * FocalLength / (Scale - Cmin);
}

float case1(float pixelValue, float neighbour) {

    float SIGMA_THRESHOLD = 0.00001;
    if((pixelValue + neighbour) * 0.5 > SIGMA_THRESHOLD) {

        return exp(-(1.0 / ((pixelValue + neighbour) * 0.5)));
    } else {

        float zero = 0.0;
        return zero;
    }
}

float case2(float pixel, float neighbour) {
    float SIGMA_THRESHOLD = 0.00001;
    if (max(pixel, neighbour) > SIGMA_THRESHOLD) {
        return exp(-(1.0 / max(pixel, neighbour)));
    } else {
        return 0.0;
    }
}

float case3(float pixelValue, float neighbour) {
    float SIGMA_THRESHOLD = 0.00001;
    if (min(pixelValue, neighbour) > SIGMA_THRESHOLD) {
        return exp(-(1.0 / min(pixelValue, neighbour)));
    } else {
        return 0.0;
    }
}

float case4(float pixel, float neighbour) {
    return case2(pixel, neighbour);
}

void main() {
    float D1 = ForeGroundOutOfFocusRegion();
    float D2 = BackGroundOutOfFocusRegion();

    float alpha = 0.0;

    float pixelValue = texelFetch(CoCMap, ivec2(gl_FragCoord.xy), 0).r;
    float neighbour = texelFetch(CoCMap, ivec2(gl_FragCoord.x + 1.0, gl_FragCoord.y), 0).r;
    float pinholePixelValue = texelFetch(BlurredDepthMap, ivec2(u_resolution.x - gl_FragCoord.x, u_resolution.y - gl_FragCoord.y), 0).r;
    float pinholeNeighbour = texelFetch(BlurredDepthMap, ivec2(u_resolution.x - (gl_FragCoord.x + 1.0), u_resolution.y - gl_FragCoord.y), 0).r;
    /*
    
[[uniforms]]
name = "Scale"
type = "float"
min = 0.1
max = 2.0
*/

    // Weights are computed based on cases
    // 1. p, q ∈ IR or FOR or BOR
    // 2. p ∈ IR, q ∈ FOR or p ∈ FOR, q ∈ IR
    // 3. p ∈ IR, q ∈ BOR or p ∈ BOR, q ∈ IR
    // 4. p ∈ FOR, q ∈ BOR or p ∈ BOR, q ∈ FOR
    // IR - In focus region, FOR - Foreground out of focus region, BOR - background out of focus region

    // case 1
    if (D1 >= pixelValue && D1 >= neighbour) {
        alpha = case1(pixelValue, neighbour);
    }
    if (D2 > pixelValue && D2 > neighbour) {
        alpha = case1(pixelValue, neighbour);
    }
    if(pixelValue > D1 && pixelValue < D2 && neighbour > D1 && neighbour < D2) {
        alpha = case1(pixelValue, neighbour);
    }
    // case2
    if ((pixelValue > D1 && pixelValue < D2 && neighbour < D1) || (pixelValue < D1 && neighbour > D1 && neighbour < D2)) {
        alpha = case2(pinholePixelValue, pinholeNeighbour);
    }
    // case3
    if ((pixelValue > D1 && pixelValue < D2 && neighbour > D2) || (neighbour > D1 && neighbour < D2 && pixelValue > D2)) {
        alpha = case3(pixelValue, neighbour);
    }
    // case4
    if ((pixelValue < D1 && neighbour > D2) || (neighbour < D1 && pixelValue > D2)) {
        alpha = case4(pinholePixelValue, pinholeNeighbour);
    }
    
    WeightMap = vec4(alpha);
}