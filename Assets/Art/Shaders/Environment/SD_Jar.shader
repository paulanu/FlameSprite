Shader "Unlit/Jar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Albedo ("Color", Color) = (1,0,1,1)
        _Gloss ("Glossiness", Range(0,1)) = 0.5
        _GlossColor ("Gloss Color", Color) = (1,1,1,1)
        _FresnelSize ("Fresnel thickness", Range(0,1)) = 0.5
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _InnerFresnelSize ("Inner Fresnel thickness", Range(0,1)) = 0.5
        _InnerFresnelColor ("Inner Fresnel Color", Color) = (1,1,1,1)
        _Emission ("Emission", Range(0,5)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        Pass
        {
            Zwrite On
            ColorMask 0
        }

        Pass
        {
            ZWrite On
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha 


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // Unity specific data for light (includes light pos)
            #include "AutoLight.cginc"
            #include "UnityLightingCommon.cginc" 


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL; 
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1; 
                float3 wPos : TEXCOORD2; 
                LIGHTING_COORDS(3, 4) 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Albedo;
            float _Alpha; 

            float _Gloss;
            float _GlossSize;
            float4 _GlossColor;

            float _FresnelSize; 
            float4 _FresnelColor;

            float _InnerFresnelSize; 
            float4 _InnerFresnelColor;

            float _Emission;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o); // transfer over lighting info 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                // variables 
                float3 N = normalize(i.normal); 
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos); 
                float3 L = normalize(UnityWorldSpaceLightDir(i.wPos)); 

                // specular lighting 
                float3 H = normalize(L + V); 
                float specularReflection = (dot(H,N)); 
                float specularSize = pow(specularReflection, exp2((1-_Gloss)*11)+2); 
                float specular = smoothstep(0.005, 0.006, specularSize); 
                float4 specularColor = specular * _GlossColor; 

                // fresnel 
                float fresnelReflection = dot(V, N); 
                float fresnel = smoothstep(_FresnelSize - 0.01, _FresnelSize + 0.01, saturate(1.0 - fresnelReflection)); 
                float4 fresnelColor = fresnel * _FresnelColor;

                // inner fresnel 
                float innerFresnel = smoothstep(_InnerFresnelSize - 0.01, _InnerFresnelSize + 0.01, fresnelReflection);
                float4 innerFresnelColor = innerFresnel * _InnerFresnelColor;

                float4 baseColor = _Albedo * (1-specular) * (1-fresnel) * (1-innerFresnel); 
                
                float4 col = baseColor + specularColor + fresnelColor * (1-specular) + innerFresnelColor * (1-specular);
                return col * _Emission;
            }
            ENDCG
        }
    }
}
