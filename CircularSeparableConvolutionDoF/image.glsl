/* interface
outputs = ["fragColor"]

[[textures]]
name = "bufferA"

[[textures]]
name = "bufferB"

[[textures]]
name = "bufferC"

[[textures]]
name = "bufferD"
*/

uniform sampler2D bufferA;
uniform sampler2D bufferB;
uniform sampler2D bufferC;
uniform sampler2D bufferD;

out vec4 fragColor;

float complexMag(in vec2 c)
{
    return sqrt(c.x * c.x + c.y * c.y);
}

vec2 complexMultiply(in vec2 a, in vec2 b)
{
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + b.x * a.y);
}

void main()
{
	vec2 uv = gl_FragCoord.xy / u_resolution;
    
    vec2 pixelUVSize = vec2(1.0, 1.0) / u_resolution;
    vec2 step = vec2(0.0, texture(bufferA, pixelUVSize * 0.5).g);
    
    vec4 rgba = vec4(0.0);
    
    for(int i = -10; i <= 10; ++i)
    {
        vec4 samp = texture(bufferB, uv + float(i) * step);
        vec4 samp2 = texture(bufferC, uv + float(i) * step);
        vec4 samp3 = texture(bufferD, uv + float(i) * step);
        vec4 sampKernel = texture(bufferA, pixelUVSize * 0.5 + pixelUVSize * vec2(i+50,0));
        vec4 sampKernelW = texture(bufferA, pixelUVSize * 0.5 + pixelUVSize * vec2(i+50,1));

        rgba.r += complexMultiply(samp.xy, sampKernel.xy).x;
        rgba.r += complexMultiply(samp.zw, sampKernel.zw).x;

        rgba.g += complexMultiply(samp2.xy, sampKernel.xy).x;
        rgba.g += complexMultiply(samp2.zw, sampKernel.zw).x;

        rgba.b += complexMultiply(samp3.xy, sampKernel.xy).x;
        rgba.b += complexMultiply(samp3.zw, sampKernel.zw).x;
        
        rgba.a += sampKernelW.r;
    }
    
    float complexNormalization = 1.0 / rgba.a;

    vec4 outColor = rgba * complexNormalization;   
    
    fragColor = outColor;
}