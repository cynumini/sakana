@vs vs
#version 430 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 ourColor;
out vec2 TexCoord;

uniform mat4 model;
uniform mat4 projection;

void main()
{
	gl_Position = projection * model * vec4(aPos, 1.0);
	// gl_Position = projection * vec4(aPos, 1.0);
    ourColor = aColor;
	TexCoord = aTexCoord;
}
@end

@fs fs
#version 430 core

out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

uniform vec4 color;
uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{
	// FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.5);
	FragColor = color;
}
@end

@program basic vs fs
