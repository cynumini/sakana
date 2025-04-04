@vs vs
#version 430 core

layout (location = 0) in vec4 vertex;

out vec2 TexCoord;

uniform mat4 model;
uniform mat4 projection;

void main()
{
	gl_Position = projection * model * vec4(vertex.xy, 0, 1.0);
	TexCoord = vertex.zw;
}
@end

@fs fs
#version 430 core

out vec4 FragColor;

in vec2 TexCoord;

uniform vec4 color;
uniform sampler2D texture0;
uniform bool isTexture;

void main()
{
	if (isTexture) {
		FragColor = color * texture(texture0, TexCoord);
	} else {
		FragColor = color;
	}
}
@end

@program basic vs fs
