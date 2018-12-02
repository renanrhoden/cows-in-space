#version 330 core

// Atributos de v�rtice recebidos como entrada ("in") pelo Vertex Shader.
// Veja a fun��o BuildTrianglesAndAddToVirtualScene() em "main.cpp".
layout (location = 0) in vec4 model_coefficients;
layout (location = 1) in vec4 normal_coefficients;
layout (location = 2) in vec2 texture_coefficients;

// Matrizes computadas no c�digo C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec4 light_position;

// Atributos de v�rtice que ser�o gerados como sa�da ("out") pelo Vertex Shader.
// ** Estes ser�o interpolados pelo rasterizador! ** gerando, assim, valores
// para cada fragmento, os quais ser�o recebidos como entrada pelo Fragment
// Shader. Veja o arquivo "shader_fragment.glsl".
out vec4 position_world;
out vec4 position_model;
out vec4 normal;
out vec2 texcoords;
out vec3 cor_ball_gourad;

void main()
{
    // A vari�vel gl_Position define a posi��o final de cada v�rtice
    // OBRIGATORIAMENTE em "normalized device coordinates" (NDC), onde cada
    // coeficiente est� entre -1 e 1.  (Veja slides 144 e 150 do documento
    // "Aula_09_Projecoes.pdf").
    //
    // O c�digo em "main.cpp" define os v�rtices dos modelos em coordenadas
    // locais de cada modelo (array model_coefficients). Abaixo, utilizamos
    // opera��es de modelagem, defini��o da c�mera, e proje��o, para computar
    // as coordenadas finais em NDC (vari�vel gl_Position). Ap�s a execu��o
    // deste Vertex Shader, a placa de v�deo (GPU) far� a divis�o por W. Veja
    // slide 189 do documento "Aula_09_Projecoes.pdf").

    gl_Position = projection * view * model * model_coefficients;

    // Como as vari�veis acima  (tipo vec4) s�o vetores com 4 coeficientes,
    // tamb�m � poss�vel acessar e modificar cada coeficiente de maneira
    // independente. Esses s�o indexados pelos nomes x, y, z, e w (nessa
    // ordem, isto �, 'x' � o primeiro coeficiente, 'y' � o segundo, ...):
    //
    //     gl_Position.x = model_coefficients.x;
    //     gl_Position.y = model_coefficients.y;
    //     gl_Position.z = model_coefficients.z;
    //     gl_Position.w = model_coefficients.w;
    //

    // Posi��o do v�rtice atual no sistema de coordenadas global (World).
    position_world = model * model_coefficients;

    // Posi��o do v�rtice atual no sistema de coordenadas local do modelo.
    position_model = model_coefficients;

    // Normal do v�rtice atual no sistema de coordenadas global (World).
    // Veja slide 94 do documento "Aula_07_Transformacoes_Geometricas_3D.pdf".
    normal = inverse(transpose(model)) * normal_coefficients;
    normal.w = 0.0;

    // Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
    texcoords = texture_coefficients;

    	// Obtemos a posi��o da c�era utilizando a inversa da matriz que define o
    // sistema de coordenadas da c�era.
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

    vec3 I = vec3(1.0,1.0,1.0); // Espectro da fonte de ilumina��o
    vec3 Ia = vec3(0.2,0.2,0.2); // Espectro da luz ambiente
    vec3 lambert_diffuse_term = Kd * I * lambert;
	vec3 ambient_term = Ka * Ia;

	// Termo especular utilizando o modelo de ilumina��o de Blinn-Phong
    vec4 h = normalize(v + l);
    vec3 phong_specular_term  = Ks * I * pow(max(0, dot(n, h)), q);

  	cor_ball_gourad = lambert_diffuse_term + ambient_term + phong_specular_term;
}
