Shader "Unlit/SkyBox"
{
    Properties
    {
        _ColorA ("Color A", Color) = (.3,.3,.3,1)
        _ColorB ("Color B", Color) = (.7,.7,.7,1)
        _Start ("Start height", Range(-1,1)) = .5
        _End ("End Height", Range(-1,1)) = 1
        _Texture("Sky Texture", 2D) = "white" {}
        _Opacity("Texture opacity", Range(0,1)) = 1
        
    }
    SubShader
    {
        Tags { "RenderType"="Background" "Queue"="Background" "PreviewType"="Quad"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718
            #define PI 3.14159265358979

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 wPos : TEXCOORD1; 
            };

            float iLerp( float a, float b, float v ) {
                return clamp((v - a) / (b - a), 0, 1);
            }

            fixed4 _ColorA;
            fixed4 _ColorB; 
            float _Start;
            float _End;
            sampler2D _Texture;
            float4 _Texture_ST;
            float _Opacity;

            v2f vert (appdata v)
            {
                v2f o;
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 nwPos = normalize(i.wPos);

                //calculate gradient
                float inverseLerp = iLerp(_Start, _End, nwPos.y);
                fixed4 col = lerp(_ColorA, _ColorB, inverseLerp);

                //calculate uvs so there is no weird stretching (ref: //https://medium.com/@jannik_boysen/procedural-skybox-shader-137f6b0cb77c)
                float uCoord = atan2(nwPos.r, nwPos.b)/(UNITY_TWO_PI);
                float vCoord = asin(nwPos.g)/(UNITY_HALF_PI);
                float2 uv = float2(uCoord, vCoord);
                uv = uv * _Texture_ST.xy + _Texture_ST.zw;

                fixed4 tex = tex2D (_Texture, uv);
                return col * (1-tex.a*_Opacity) + tex * tex.a*_Opacity;
            }
            ENDCG
        }
    }
}