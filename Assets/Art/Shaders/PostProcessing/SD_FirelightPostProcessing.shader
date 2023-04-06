// Referenced:
// https://www.ronja-tutorials.com/post/018-postprocessing-normal/
// https://halisavakis.com/my-take-on-shaders-spherical-mask-post-processing-effect/

Shader "Unlit/FirelightPostProcessing"
{
     Properties
    {
        // all props are set in post processing script so hide them in the shader
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        [HideInInspector]_PlayerPos ("Player pos", Vector) = (1,1,1)
        [HideInInspector]_Color ("Fire Color", Color) = (1,1,1,1)
        [HideInInspector]_Radius ("Radius", float) = 5
        [HideInInspector]_NormalThreshold ("Normal threshold", Range(0, 1)) = .1
        [HideInInspector]_WaveRange ("Wave Range", Range(0,1)) = 0.5
        [HideInInspector]_WaveSpeed ("Wave Speed", float) = 1 
        [HideInInspector]_Softness ("Softness", float) = 1 
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
             
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
 
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldDirection : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };
             
            float4x4 _ClipToWorld;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
 
                float4 clip = float4(o.vertex.xy, 0.0, 1.0);
                o.worldDirection = mul(_ClipToWorld, clip) - _WorldSpaceCameraPos;
                return o;
            }
             
            sampler2D _MainTex;
            sampler2D _CameraDepthNormalsTexture;
            float4x4 _viewToWorld;

            float4 _Color;
            float4 _PlayerPos;
            float _Radius;
            float _NormalThreshold;
            float _WaveRange; 
            float _WaveSpeed;
            float _Softness;

            float spheresdf (float3 p, float3 center, float radius)
            {
                return distance(p, center) - radius;
            }
 
            float iLerp( float a, float b, float v ) {
                return (v - a) / (b - a);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 depthnormal = tex2D(_CameraDepthNormalsTexture, i.uv);

                // decode depthnormal
                float3 normal;
                float depth;
                DecodeDepthNormal(depthnormal, depth, normal);

                // get depth as distance from camera in units 
                depth = depth * _ProjectionParams.z;

                // convert normal from view to world space
                normal = mul((float3x3)_viewToWorld, normal); 

                // calculate variables
                float3 wpos = i.worldDirection * depth + _WorldSpaceCameraPos;
                float3 L = normalize(_PlayerPos.rgb - wpos);
                float3 N = normalize(normal); 

                // get sin adjustment for firelight flicker effect
                float wave = _Radius + sin(_Time.a * _WaveSpeed) * _WaveRange;
                float sphereMask = spheresdf(wpos, _PlayerPos, wave)/_Softness;  
                sphereMask = 1 - saturate(sphereMask); 

                float normalMask = saturate(dot(L,N));
                
                // this does VERY approximate anti-aliasing 
                normalMask = saturate(iLerp(_NormalThreshold - 0.1, _NormalThreshold, normalMask));

                
                float mask = sphereMask * normalMask; 
                float4 source = tex2D(_MainTex, i.uv);
                
                return source + mask * _Color; 
            }
            ENDCG
        }
    }
}
