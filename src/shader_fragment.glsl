#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpola��o da cor de cada v�rtice, definidas em "shader_vertex.glsl" e
// "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posi��o do v�rtice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no c�digo C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto est� sendo desenhado no momento
#define SPHERE 0
#define BUNNY  1
#define PLANE  2
#define COW 3
#define GAMEOVER 4
#define HEART 5
uniform int object_id;

// Par�metros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Vari�veis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;
uniform sampler2D TextureImage3;
uniform sampler2D TextureImage4;
uniform sampler2D TextureImage5;

// O valor de sa�da ("out") de um Fragment Shader � a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // Obtemos a posi��o da c�mera utilizando a inversa da matriz que define o
    // sistema de coordenadas da c�mera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual � coberto por um ponto que percente � superf�cie de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posi��o no
    // sistema de coordenadas global (World coordinates). Esta posi��o � obtida
    // atrav�s da interpola��o, feita pelo rasterizador, da posi��o de cada
    // v�rtice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada v�rtice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em rela��o ao ponto atual.
    vec4 l = normalize(vec4(1.0,1.0,0.0,0.0));

    // Vetor que define o sentido da c�mera em rela��o ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflex�o especular ideal.
    vec4 r = normalize(-l + 2*n*(dot(n,l))); // PREENCHA AQUI o vetor de reflex�o especular ideal

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    // Par�metros que definem as propriedades espectrais da superf�cie
    vec3 Kdif; // Reflet�ncia difusa
    vec3 Ks; // Reflet�ncia especular
    vec3 Ka; // Reflet�ncia ambiente
    float q; // Expoente especular para o modelo de ilumina��o de Phong

    if ( object_id == SPHERE )
    {
        // PREENCHA AQUI as coordenadas de textura da esfera, computadas com
        // proje��o esf�rica EM COORDENADAS DO MODELO. Utilize como refer�ncia
        // o slide 139 do documento "Aula_20_e_21_Mapeamento_de_Texturas.pdf".
        // A esfera que define a proje��o deve estar centrada na posi��o
        // "bbox_center" definida abaixo.

        // Voc� deve utilizar:
        //   fun��o 'length( )' : comprimento Euclidiano de um vetor
        //   fun��o 'atan( , )' : arcotangente. Veja https://en.wikipedia.org/wiki/Atan2.
        //   fun��o 'asin( )'   : seno inverso.
        //   constante M_PI
        //   vari�vel position_model

        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;
        vec4 p_vector = position_model - bbox_center;

        float rho = length(p_vector);
        float theta = atan(position_model.x,position_model.z);
        float phi = asin(position_model.y/rho);


        U = (theta + M_PI)/(2*M_PI);
        V = (phi + M_PI/2)/(M_PI);
    }
    else if ( object_id == BUNNY )
    {
        // PREENCHA AQUI as coordenadas de textura do coelho, computadas com
        // proje��o planar XY em COORDENADAS DO MODELO. Utilize como refer�ncia
        // o slide 106 do documento "Aula_20_e_21_Mapeamento_de_Texturas.pdf",
        // e tamb�m use as vari�veis min*/max* definidas abaixo para normalizar
        // as coordenadas de textura U e V dentro do intervalo [0,1]. Para
        // tanto, veja por exemplo o mapeamento da vari�vel 'p_v' utilizando
        // 'h' no slide 151 do documento "Aula_20_e_21_Mapeamento_de_Texturas.pdf".

        // PREENCHA AQUI
        // Propriedades espectrais do coelho
        Kdif = vec3(1.0, 1.0, 1.0);
        Ks = vec3(1.0, 1.0, 0.0);
        Ka = vec3(1.0,1.0,1.0);
        q = 40.0;

        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx)/(maxx - minx);
        V = (position_model.y - miny)/(maxy - miny);
    }

    else if ( object_id == COW )
    {

        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx)/(maxx - minx);
        V = (position_model.y - miny)/(maxy - miny);
    }

    else if ( object_id == PLANE )
    {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;
    }
    else if ( object_id == GAMEOVER )
    {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;
    }

    else if ( object_id == HEART )
    {

        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx)/(maxx - minx);
        V = (position_model.y - miny)/(maxy - miny);
    }

    // Obtemos a reflet�ncia difusa a partir da leitura da imagem TextureImage0
    vec3 Kd_plane = texture(TextureImage0, vec2(U,V)).rgb;
    vec3 Kd_star = texture(TextureImage1, vec2(U,V)).rgb;
    vec3 Kd_cow = texture(TextureImage2, vec2(U,V)).rgb;
    vec3 Kd_bunny = texture(TextureImage3, vec2(U,V)).rgb;
    vec3 Kd_gameover = texture(TextureImage4, vec2(U,V)).rgb;
    vec3 Kd_heart = texture(TextureImage5, vec2(U,V)).rgb;

    // Equa��o de Ilumina��o

    // Espectro da fonte de ilumina��o
    vec3 I = vec3(1.0,1.0,1.0); // PREENCH AQUI o espectro da fonte de luz

    // Espectro da luz ambiente
    vec3 Ia = vec3(1.0,1.0,1.0); // PREENCHA AQUI o espectro da luz ambiente

    // Termo difuso utilizando a lei dos cossenos de Lambert
    vec3 lambert_diffuse_term = Kdif*I*max(0,dot(n,l)); // PREENCHA AQUI o termo difuso de Lambert

    // Termo ambiente
    vec3 ambient_term = Ka*Ia; // PREENCHA AQUI o termo ambiente

    // Termo especular utilizando o modelo de ilumina��o de Phong
    vec3 phong_specular_term  = Ks*I*pow(max(0,dot(r,v)),q); // PREENCH AQUI o termo especular de Phong

    // Cor final do fragmento calculada com uma combina��o dos termos difuso,
    // especular, e ambiente. Veja slide 134 do documento "Aula_17_e_18_Modelos_de_Iluminacao.pdf".
    //color = lambert_diffuse_term + ambient_term + phong_specular_term;

    float lambert = max(0,dot(n,l));

    if ( object_id == SPHERE )
    {
     color = (Kd_star);
    }
    else if (object_id == BUNNY)
    {
    color = (Kd_bunny * (lambert + 0.01));
    }
    else if (object_id == PLANE)
    {
    color = (Kd_plane * (lambert + 0.01));
    }
    else if (object_id == COW)
    {
    color = (Kd_cow * (lambert_diffuse_term + 0.01));
    }
    else if (object_id == GAMEOVER)
    {
    color = (Kd_gameover);
    }
    else if (object_id == HEART)
    {
    color = (Kd_heart* (lambert_diffuse_term + 0.01))+ phong_specular_term;
    }

    // Cor final com corre��o gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
}
