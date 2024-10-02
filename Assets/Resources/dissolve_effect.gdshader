shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0); // Controls dissolve effect
uniform sampler2D dissolve_texture;  // Noise texture for dissolve pattern
uniform vec4 dissolve_color : source_color; // Color during dissolve

void fragment() {
    vec4 card_texture = texture(TEXTURE, UV);  // Sample the card texture
    vec4 dissolve_pattern = texture(dissolve_texture, UV); // Sample dissolve texture
    
    // Compare dissolve amount with the dissolve texture
    if (dissolve_pattern.r < dissolve_amount) {
        // If dissolve texture is less than the dissolve_amount, dissolve the pixel
        discard;
    } else {
        // Mix the original card texture with dissolve color based on dissolve_amount
        COLOR = mix(card_texture, dissolve_color, dissolve_amount);
    }
}
