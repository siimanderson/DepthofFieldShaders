/* interface 
outputs = ["fragColor"]

[[textures]]
name = "ColorTarget"

[[uniforms]]
name = "KernelSize"
type = "int"
min = 1
max = 20
*/

uniform sampler2D ColorTarget;

uniform int KernelSize;

out vec4 fragColor;

#define SAMP_BIAS 50.0
#define SAMP_DIVIDE 5.0

#define C1_F0 5.268909
#define C1_EXP_MULT0 -0.886528
#define C1_REAL0 -0.7406246191
#define C1_IM0 -0.3704940302

#define C1_F1 1.558213
#define C1_EXP_MULT1 -1.960518
#define C1_REAL1 1.5973700402
#define C1_IM1 -1.4276936105


vec4 complexKernel(float x)
{
	vec4 complexWeightsTwo = vec4(
        (C1_REAL0*cos(x*x*C1_F0) - C1_IM0*sin(x*x*C1_F0))   * exp(C1_EXP_MULT0*x*x),
		(C1_IM0*cos(x*x*C1_F0)   + C1_REAL0*sin(x*x*C1_F0)) * exp(C1_EXP_MULT0*x*x),
		(C1_REAL1*cos(x*x*C1_F1) - C1_IM1*sin(x*x*C1_F1))   * exp(C1_EXP_MULT1*x*x),
		(C1_IM1*cos(x*x*C1_F1)   + C1_REAL1*sin(x*x*C1_F1)) * exp(C1_EXP_MULT1*x*x));
    
    return complexWeightsTwo;

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
    //outColor *= outColor * outColor * outColor * 3.0;
    
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