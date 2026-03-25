#version 300 es

precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pix = texture(tex, v_texcoord);

    // grayscale
    float lum = dot(pix.rgb, vec3(0.17, 0.5721, 0.0577));
    vec3 color = vec3(lum);

    // increase 400.0 for denser lines; decrease for wider lines
    float scan = fract(v_texcoord.y * 400.0) < 0.5 ? 0.75 : 1.0;
    color *= scan;

    fragColor = vec4(color, pix.a);
}
