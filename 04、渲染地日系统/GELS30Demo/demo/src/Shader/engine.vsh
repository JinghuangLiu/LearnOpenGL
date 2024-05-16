#version 300 es
layout(location = 0) in vec3 aPos;
layout(location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;
uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_projection;

out vec4 vertexColor;
out vec2 TexCoord;

void main() {
    gl_Position = u_projection * u_view * u_model * vec4(aPos, 1.0);
    TexCoord = aTexCoord;
}
