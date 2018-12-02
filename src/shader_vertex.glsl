#version 330 core

// Atributos de vértice recebidos como entrada ("in") pelo Vertex Shader.
// Veja a função BuildTrianglesAndAddToVirtualScene() em "main.cpp".
layout (location = 0) in vec4 model_coefficients;
layout (location = 1) in vec4 normal_coefficients;
layout (location = 2) in vec2 texture_coefficients;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec4 light_position;

// Atributos de vértice que serão gerados como saída ("out") pelo Vertex Shader.
// ** Estes serão interpolados pelo rasterizador! ** gerando, assim, valores
// para cada fragmento, os quais serão recebidos como entrada pelo Fragment
// Shader. Veja o arquivo "shader_fragment.glsl".
out vec4 position_world;
out vec4 position_model;
out vec4 normal;
out vec2 texcoords;
out vec3 cor_ball_gourad;

void main()
{
    // A variável gl_Position define a posição final de cada vértice
    // OBRIGATORIAMENTE em "normalized device coordinates" (NDC), onde cada
    // coeficiente está entre -1 e 1.  (Veja slides 144 e 150 do documento
    // "Aula_09_Projecoes.pdf").
    //
    // O código em "main.cpp" define os vértices dos modelos em coordenadas
    // locais de cada modelo (array model_coefficients). Abaixo, utilizamos
    // operações de modelagem, definição da câmera, e projeção, para computar
    // as coordenadas finais em NDC (variável gl_Position). Após a execução
    // deste Vertex Shader, a placa de vídeo (GPU) fará a divisão por W. Veja
    // slide 189 do documento "Aula_09_Projecoes.pdf").

    gl_Position = projection * view * model * model_coefficients;

    // Como as variáveis acima  (tipo vec4) são vetores com 4 coeficientes,
    // também é possível acessar e modificar cada coeficiente de maneira
    // independente. Esses são indexados pelos nomes x, y, z, e w (nessa
    // ordem, isto é, 'x' é o primeiro coeficiente, 'y' é o segundo, ...):
    //
    //     gl_Position.x = model_coefficients.x;
    //     gl_Position.y = model_coefficients.y;
    //     gl_Position.z = model_coefficients.z;
    //     gl_Position.w = model_coefficients.w;
    //

    // Posição do vértice atual no sistema de coordenadas global (World).
    position_world = model * model_coefficients;

    // Posição do vértice atual no sistema de coordenadas local do modelo.
    position_model = model_coefficients;

    // Normal do vértice atual no sistema de coordenadas global (World).
    // Veja slide 94 do documento "Aula_07_Transformacoes_Geometricas_3D.pdf".
    normal = inverse(transpose(model)) * normal_coefficients;
    normal.w = 0.0;

    // Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
    texcoords = texture_coefficients;

    	// Obtemos a posição da câera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_pos = inverse(view) * origin;

    vec4 l = normalize(vec4(4.5,7.0,0.0,0.0) - position_world);
	vec4 n = normalize(normal);
    vec4 v = normalize(camera_pos - position_world);
    vec4 r = -l + 2 * n * (dot(l, v));
	float lambert = max(0,dot(n,l));

	vec3 Kd = vec3(0.08,0.0,0.0);
	vec3 Ks = vec3(0.8,0.8,0.8);
    vec3 Ka = vec3(0.04,0.2,0.4);
    float q = 20.0;

    vec3 I = vec3(1.0,1.0,1.0); // Espectro da fonte de iluminação
    vec3 Ia = vec3(0.2,0.2,0.2); // Espectro da luz ambiente
    vec3 lambert_diffuse_term = Kd * I * lambert;
	vec3 ambient_term = Ka * Ia;

	// Termo especular utilizando o modelo de iluminação de Blinn-Phong
    vec4 h = normalize(v + l);
    vec3 phong_specular_term  = Ks * I * pow(max(0, dot(n, h)), q);

  	cor_ball_gourad = lambert_diffuse_term + ambient_term + phong_specular_term;
}
