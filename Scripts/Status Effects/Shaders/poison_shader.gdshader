shader_type canvas_item;

uniform float time; // tiempo en segundos desde que se aplicó el efecto

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Oscila entre 0 y 1 cada segundo
    float pulse = abs(sin(time * 3.14159)); // 3.14159 ≈ π → 1 ciclo por segundo

    // Aplica tinte verde con intensidad variable
    vec3 green_tint = vec3(0.0, 1.0, 0.0);
    COLOR = vec4(mix(tex_color.rgb, green_tint, pulse * 0.5), tex_color.a);
}
