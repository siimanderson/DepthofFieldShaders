/* interface 
outputs = ["fragColor"]

[[textures]]
name = "ColorTarget"

[[uniforms]]
name = "KernelSize"
type = "int"
min = 1
max = 10
*/

uniform sampler2D ColorTarget;

uniform int KernelSize;

out vec4 fragColor;

#define SAMP_BIAS 50.0
#define SAMP_DIVIDE 5.0

#define C0_F0 1.624835
#define C0_EXP_MULT0 -0.862325
#define C0_REAL0 1.1793828124
#define C0_IM0 -0.7895320249


vec4 complexKernel(float x)
{
	vec4 complexWeights = vec4((C0_REAL0*cos(x*x*C0_F0) - C0_IM0*sin(x*x*C0_F0)) * exp(C0_EXP_MULT0*x*x),
		(C0_IM0*cos(x*x*C0_F0) + C0_REAL0*sin(x*x*C0_F0)) * exp(C0_EXP_MULT0*x*x), 0, 0); 
    
    return complexWeights;

}


vec2 complexMultiply(vec2 a, vec2 b)
{
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + b.x * a.y);
}

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution;
    
    vec4 kernel = complexKernel((gl_FragCoord.x - SAMP_BIAS) / SAMP_DIVIDE);
	vec4 outColor = texture(ColorTarget, uv);
    outColor *= outColor * outColor * outColor * 3.0;
    
    vec4 kernelAccum = vec4(0.0);
    for(int i = -KernelSize; i <= KernelSize; ++i)
    {
        kernelAccum += complexKernel(float(i) / SAMP_DIVIDE);
    }
    

    if (int(gl_FragCoord.y) == 0)
        outColor = kernel;
    if (int(gl_FragCoord.y) == 1)
        outColor = vec4(
            complexMultiply(kernel.xy, kernelAccum.xy).x + 
            complexMultiply(kernel.zw, kernelAccum.zw).x, 0.0, 0.0, 0.0);    
    if (int(gl_FragCoord.y) == 0 && int(gl_FragCoord.x) == 0)
        outColor = vec4(1.0 / u_resolution, 0.0, 0.0);

    fragColor = outColor;
}