#version 300 es

precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pixcolor = texture2D(tex, v_texcoord);
    
    // original rgb
    vec3 color = pixcolor.rgb;

#ifdef withquickanddirtyluminancepreservation
    color *= mix(1.0,
                 dot(color, vec3(0.2126, 0.7152, 0.0722)) / max(dot(color, vec3(0.2126, 0.7152, 0.0722)), 1e-5),
                 luminancepreservationfactor);
#endif
    
    const float strength = 0.28;

    // Matcha flavour
    vec3 regular = vec3(0.545, 0.809, 0.333);

    // pick your matcha tint color (soft earthy green, not neon)
    vec3 matcha = regular; // tweak to taste

    color = mix(color, color * matcha, strength);

    vec4 outcol = vec4(color, pixcolor.a);
    fragColor = outcol;
}

