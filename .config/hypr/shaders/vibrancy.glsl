#version 320 es

// Tuned for: Chimei Innolux 15.6" FHD Matte
// 62.5% sRGB, 250 nits -- boost sat + contrast
// Lower SATURATION to 1.20 if colors feel too vivid

precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

const float SATURATION = 1.30;
const float CONTRAST   = 1.06;
const float BRIGHTNESS = 1.00;

const vec3 W = vec3(0.2126, 0.7152, 0.0722);

void main() {
    vec4 pixel = texture(tex, v_texcoord);
    vec3 c = pixel.rgb;

    // saturation boost
    float luma = dot(c, W);
    c = mix(vec3(luma), c, SATURATION);

    // contrast
    c = clamp((c - 0.5) * CONTRAST + 0.5, 0.0, 1.0);

    // brightness
    c *= BRIGHTNESS;

    fragColor = vec4(clamp(c, 0.0, 1.0), pixel.a);
}
