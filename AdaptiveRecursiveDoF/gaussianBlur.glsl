/* interface
outputs = ["Output"]

[[textures]]
name = "AOVTarget"

[[uniforms]]
name = "Radius"
type = "int"
min = 1
max = 15
*/

uniform sampler2D AOVTarget;

uniform int Radius;

out vec4 Output;


vec4 gaussian(int radius, float sigma) {
    vec4 sum = vec4(0.0);
    if (radius > 0) {
        float norm = 0.0;
        float twoSigma2 = 2.0 * sigma * sigma;
        for (int x = -radius; x <= radius; x++) {
            for (int y = -radius; y <= radius; y++) {
                // proper formula
                // float kernelWeight = 1/(sqrt(2*PI)*sigma) * exp(-(x * x) / (2 * sigma * sigma));  // proper formula
                // float kernelWeight = 0.15915 / (sigma * sigma) * exp(-(x*x + y+y) / (2 * sigma * sigma));

                // sacrifice some accuracy by removing the factor
                float d = length(vec2(x, y));
                float kernelWeight = exp(-(d * d) / twoSigma2);

                vec4 c = texture(AOVTarget, f_texcoord + (vec2(x, y) * u_texel));
                norm += kernelWeight;
                sum += kernelWeight * c;
            }
        }
        sum /= norm;
    } else {
        sum = texture(AOVTarget, f_texcoord);
    }
    return sum;
}


void main() {
    float sigma = Radius/2.0;

    Output = gaussian(Radius, sigma);
}