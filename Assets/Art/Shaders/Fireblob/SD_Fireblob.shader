Shader "Unlit/Fireblob"
{
    Properties
    {
        [Header(Colors)] 
        _CenterColor ("Center Color", Color) = (1,1,1,1)
        _MiddleColor ("Middle Color", Color) = (1,1,1,1)

        [Header(Color Properties)] 
        _CenterColorWidth ("Center Color Width", Range(0, 1)) = .1
        _MiddleColorWidth ("Middle Color Width", Range(0, 1)) = .2
        _BlendSharpness("Blend sharpness", Range(0,.1)) = 0

        [Header(Noise Properties)]
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseIntensity("Noise Intensity", Range(0,1)) = 0
        _NoiseVertSpeed("Noise vertical Speed", Range(0,1)) = .2
        _NoiseHorizSpeed("Noise horizontal speed", Range(0,1)) = 0

        [Header(Mesh Properties)]
        _HorizontalWiggle ("Horizontal wiggle amount", Range(0,30)) = 0.1
        


    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        LOD 100

        Stencil
        {
            Ref 10 
            Comp always 
            Pass replace 
        }

        ZWrite On

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            

            #define PI 3.14159265359

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD2;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD3; 
                float3 wPos : TEXCOORD4; 
            };

            fixed4 _CenterColor;
            fixed4 _MiddleColor;
            uniform fixed4 _BaseColor;
            uniform fixed4 _GradientColor;
            uniform float _Emission;
            
            float _BlendSharpness;
            float _CenterColorWidth;
            float _MiddleColorWidth;
            uniform float _GradientHeight;

            float4 _NoiseTex_ST;
            sampler2D _NoiseTex;
            float _NoiseIntensity;
            float _NoiseVertSpeed;
            float _NoiseHorizSpeed;

            float _HorizontalWiggle; 


            float iLerp( float a, float b, float v ) {
                return (v - a) / (b - a);
            }

            v2f vert (appdata v)
            {
                v2f o;

                o.normal = UnityObjectToWorldNormal(v.normal); 
                o.wPos = mul(unity_ObjectToWorld, v.vertex);

                // get view dir in tangent space - https://halisavakis.com/my-take-on-shaders-parallax-effect-part-ii/
                float4 objCam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
                float3 viewDir = v.vertex.xyz - objCam.xyz;
                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 bitangent = cross(v.normal.xyz, v.tangent.xyz) * tangentSign;
                float3 viewDirTangent = float3(
                    dot(viewDir, v.tangent.xyz),
                    dot(viewDir, bitangent.xyz),
                    dot(viewDir, v.normal.xyz)
                );

                // map tang space view dir to uvs 
                o.uv = float2(viewDirTangent.r - (_Time.y * _NoiseHorizSpeed), viewDirTangent.y - (_Time.y * _NoiseVertSpeed));
                o.uv = TRANSFORM_TEX(o.uv, _NoiseTex);
                
                // second set of UVs contains height/width of mesh 
                o.uv1 = v.uv1; 

                // calculate wigglies 
                float wiggleX = sin((o.uv1.y -_Time.y * .2f)  * _HorizontalWiggle) * .0005;
                v.vertex.x = v.vertex.x + (wiggleX * o.uv1.y);
                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // vars 
                float3 N = normalize(i.normal); 
                float3 L = _WorldSpaceLightPos0.xyz;
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos); 
                half fresnel = dot(V, N);

                // sample noise and apply to fresnel 
                float fresnelNoise = tex2D(_NoiseTex, i.uv) * _NoiseIntensity; 
                fresnel += fresnelNoise;
                fresnel = saturate(fresnel);

                // color masks  
                float innerColorMask = saturate(iLerp(1 - _CenterColorWidth - _BlendSharpness, 1 - _CenterColorWidth + _BlendSharpness, fresnel));
                innerColorMask *= step(0.001, _CenterColorWidth); 
                float middleColorThreshold = 1 - _CenterColorWidth - _MiddleColorWidth; 
                // blend sharpness is multiplied here since change in fresnel is not as apparent on the edges 
                float middleColorMask = saturate(iLerp(middleColorThreshold - _BlendSharpness * 2, middleColorThreshold + _BlendSharpness * 1.5, fresnel));
                float outerColorMask = 1 - middleColorMask;
                middleColorMask -= innerColorMask;
                middleColorMask *= step(0.001, _MiddleColorWidth);

                float4 color = innerColorMask * _CenterColor + middleColorMask * _MiddleColor + outerColorMask * _BaseColor;

                // overlay gradient 
                float gradientHeight = 1/(_GradientHeight * 2); // multiply gradient height so exposed parameter makes more sense to end user
                float gradientMask = saturate(i.uv1.y * gradientHeight);   
                color.rgb = color.rgb + (_GradientColor.rgb * (1-gradientMask));

                return color * _Emission;
            }
            ENDCG
        }

    }
}
