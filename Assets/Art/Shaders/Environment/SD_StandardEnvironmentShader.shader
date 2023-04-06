Shader "Custom/StandardEnvironmentShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _TexMask ("Texture Mask", 2D) = "white" {}
        [NoScaleOffset] _Glossiness ("Smoothness", 2D) = "white" {}
        _GlossinessMult ("Smoothness multiplier", Range(0,1)) = 1
        [NoScaleOffset]_Normals ("Normal Map", 2D) = "bump" {}
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" } 
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _TexMask;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_TexMask;
        };

        sampler2D _Glossiness;
        sampler2D _Normals;

        half _GlossinessMult;
        half _NormalsMult;

        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 mask = tex2D(_TexMask, IN.uv_TexMask);
            o.Albedo = c.rgb * mask.r + _Color * (1-mask.r);
            o.Metallic = _Metallic;
            o.Smoothness = tex2D (_Glossiness, IN.uv_MainTex).r * _GlossinessMult;
            o.Normal = UnpackNormal(tex2D(_Normals, IN.uv_MainTex));
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
