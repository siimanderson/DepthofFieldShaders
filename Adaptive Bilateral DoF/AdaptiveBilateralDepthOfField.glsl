/* interface
outputs = ["Output"]

[[textures]]
name = "ColorTarget"

[[textures]]
name = "AOVTarget"

[[textures]]
name = "DCoC"

[[uniforms]]
name = "SharpeningFactor"
type = "int"
min = 1
max = 20

[[uniforms]]
name = "FocusDistance"
type = "float"
min = 0.0
max = 1.0

*/

uniform sampler2D ColorTarget;
uniform sampler2D AOVTarget;
uniform sampler2D DCoC;

uniform int SharpeningFactor;
uniform float FocusDistance;

#define DepthFactor 20

out vec4 Output;

float equationBilateral(float distanceBetweenPixels, float pixelDepth, float qPixelDepth){
    float s = exp(-(distanceBetweenPixels * distanceBetweenPixels) / (2.0 * SharpeningFactor * SharpeningFactor));
    float v = exp(-(pow(qPixelDepth - pixelDepth, 2) / (2.0 * DepthFactor * DepthFactor)));
    return s * v;
}

vec4 pixelColor(float CoC, vec4 pixel){
    vec4 sum = vec4(0);
    float bilateralValues = 0.0;
    
    for (float x = -CoC; x <= CoC; x++) {
        for (float y = -CoC; y <= CoC; y++) {
            vec4 qPixel = texture(ColorTarget, f_texcoord + vec2(x, y)* u_texel);
            float distanceBetweenPixels = length(vec2(qPixel.x - pixel.x, qPixel.y - pixel.y));

            float Bilateral = equationBilateral(distanceBetweenPixels, pixel.z, qPixel.z);

            float normalise = 1.0/(sqrt(2*PI)*SharpeningFactor);
            
            sum += qPixel * Bilateral;
            bilateralValues += Bilateral;
        }
    }
    return sum / bilateralValues;
}

float meanDepth(float CoC) {
    float sum = 0.0;
    int numberOfValues = 0;

    for (float x = -CoC; x <= CoC; x++) {
        for (float y = -CoC; y <= CoC; y++) {
            sum += texture(AOVTarget, f_texcoord + vec2(x, y)* u_texel).r;
            numberOfValues++;
        }
    }
    return sum / numberOfValues;
}

void main(){

    vec4 pixel = vec4(0.0);
    //pixelDepth  
    float pDepth = texture(AOVTarget, f_texcoord).r;
    float pRemapedDepth = remap(pDepth, 0.0, 300.0, 0.0, 1.0);
    // Pixel Circle of Confusion
    float CoC = texture(DCoC, f_texcoord).x * 5.0;
    // Pixel color
    vec4 color = texture(ColorTarget, f_texcoord);

    if (pRemapedDepth > FocusDistance) {
        //float offset = meanDepth(CoC*5.0) - pRemapedDepth;
        pixel = pixelColor(CoC, color);
    } else {
        pixel = color;
    }
    //float offset = meanDepth(CoC*5.0) - color.z;
    //pixel = pixelColor(CoC, color, 0);
    Output = pixel;
}