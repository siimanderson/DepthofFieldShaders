
uniform sampler2D ColorTarget;
uniform sampler2D AOVTarget;

float maxDepth = 1.0 {
	"min": 0.01,
	"max": 1.0
}; 

int Radius = 3 {
    "min": 0,
    "max": 40,
    "step": 1
};

out vec4 Output;

##GLSL 

vec4 box(int radius, float zStart, float zEnd) {
    vec4 sum = vec4(0);
    
    float oneThirdOfTheWay = zEnd / 5;
    float twoThirdsOfTheWay = (zEnd / 5) * 10;

    for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            float zCoordinate = texture(ColorTarget, f_texcoord + u_texel*vec2(x,y)).z;
            if (zCoordinate <= oneThirdOfTheWay){
                sum += texture(ColorTarget, f_texcoord + u_texel*vec2(x,y));
            }
            else if (zCoordinate >= twoThirdsOfTheWay){
                sum += texture(ColorTarget, f_texcoord + u_texel*vec2(x,y));
            }
            else {
                sum += texture(ColorTarget, f_texcoord);
            }

        }
    }


/*     for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            sum += texture(ColorTarget, f_texcoord + u_texel*vec2(x,y));
   
        }
    } */

    
    return sum / pow(radius * 2 + 1, 2);
}

vec3 viewDirection(vec2 texcoord)
{
	// Get x/w and y/w from the viewport position
	float x = texcoord.x * 2 - 1;
	float y = (1.0 - texcoord.y) * 2 - 1;
	vec4 p_ndc = vec4(x,y,0.0,1); 
	
	return normalize(p_ndc.xyz);
}

void main () {

    vec3 viewDir = viewDirection(f_texcoord);
	vec3 viewPos = texture(AOVTarget, f_texcoord).r * viewDir;

    vec4 depthStart = vec4(viewPos,1.0);
    vec4 depthEnd = vec4(viewPos + maxDepth, 1.0);
	float zStart = depthStart.z;
	float zEnd = depthEnd.z;


    Output = box(Radius, zStart, zEnd);

}