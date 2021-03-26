/* interface
outputs = ["Output"]

[[textures]]
name = "ColorTarget"

[[textures]]
name = "AOVTarget"

[[textures]]
name = "DCoC"

[[uniforms]]
name = "SigmaS"
type = "float"
min = 1.0
max = 30.0

[[uniforms]]
name = "SigmaL"
type = "float"
min = 1.0
max = 30.0

[[uniforms]]
name = "FocusDistance"
type = "float"
min = 0.0
max = 1.0

*/

uniform sampler2D ColorTarget;
uniform sampler2D AOVTarget;
uniform sampler2D DCoC;

uniform int SigmaS;
uniform int SigmaL;
uniform float FocusDistance;

out vec4 Output;

//#define NORMALIZATIONFACTOR 0.39894;

float equationBilateral(float distanceBetweenPixels, float pixelDepth, float qPixelDepth){
    float s = exp(-(distanceBetweenPixels * distanceBetweenPixels) / (2.0 * SigmaS * SigmaS));
    float v = exp(-(pow(qPixelDepth - pixelDepth, 2) / (2.0 * SigmaL * SigmaL)));
    return s * v;
}

vec4 pixelColor(float CoC, vec4 pixel){
    vec4 sum = vec4(0);
    float NORMALIZATIONFACTOR = 0.39894;
    for (float x = -CoC; x <= CoC; x++) {
        for (float y = -CoC; y <= CoC; y++) {
            //ivec2 loc = ivec2(int(x), int(y));
            //vec4 qPixel = texelFetch(ColorTarget, loc, 0);
            vec4 qPixel = texture(ColorTarget, vec2(x / 10.0, y / 10.0));
            //remap the qPixel values to be between 0 and 1
            float distanceBetweenPixels = length(vec2(qPixel.x - pixel.x, qPixel.y - pixel.y));

            float Bilateral = equationBilateral(distanceBetweenPixels, pixel.z, qPixel.z)*NORMALIZATIONFACTOR;

            //float Sum = Bilateral.x + Bilateral.y + Bilateral.z;
            
            sum += qPixel * Bilateral;
        }
    }
    return sum;
}

void main(){

    vec4 pixel = vec4(0.0);
    //pixelDepth  
    float pDepth = texture(AOVTarget, f_texcoord).r;
    float pRemapedDepth = 1.0 / pDepth;
    // Pixel Circle of Confusion
    float CoC = texture(DCoC, f_texcoord).x;
    // Pixel color
    vec4 color = texture(ColorTarget, f_texcoord);
    
    if (pRemapedDepth > FocusDistance) {
        pixel = pixelColor(CoC * 10, color);
    } else {
        pixel = color;
    }
    Output = pixel;
}