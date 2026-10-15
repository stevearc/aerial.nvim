#version 450

struct Light {
  vec3 direction;
  vec3 color;
};

struct Material {
  vec3 diffuse;
} material;

layout(location = 0) in vec3 normal;
layout(location = 0) out vec4 fragment_color;
uniform Light light;

vec3 illuminate(in vec3 normal, in Light light) {
  return light.color * max(dot(normal, light.direction), 0.0);
}

void main() {
  vec3 color = illuminate(normalize(normal), light) * material.diffuse;
  fragment_color = vec4(color, 1.0);
}