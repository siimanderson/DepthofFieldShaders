/* interface
outputs = ["fragColor"]

[[textures]]
name = "Target"
*/

uniform sampler2D Target;

out vec4 fragColor;

vec2 complexMultiply(in vec2 a, in vec2 b)
{
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + b.x * a.y);
}

void main()
{
	vec2 uv = gl_FragCoord.xy / u_resolution;
    vec2 pixelUVSize = vec2(1.0, 1.0) / u_resolution;
    vec2 stepi = vec2(texture(Target, pixelUVSize * 0.5).r, 0.0);
    
    vec4 complexR = vec4(0.0);
    
    for(int i = -10; i <= 10; ++i)
    {
        vec4 samp = texture(Target, uv + float(i) * stepi);
        vec4 kernel = texture(Target, pixelUVSize * 0.5 + pixelUVSize * vec2(i+50, 0.0));
        complexR.xy += complexMultiply(vec2(samp.r * samp.a, 0.0), kernel.xy);
        complexR.zw += complexMultiply(vec2(samp.r * samp.a, 0.0), kernel.zw);
    }
    
	fragColor = complexR;
    //fragColor = vec4();
}
