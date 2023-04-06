Shader "Custom/Signs"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Decal ("Decal", 2D) = "white" {}
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

        sampler2D _Decal;

        struct Input
        {
            float2 uv_Decal;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 decal = tex2D (_Decal, IN.uv_Decal); 
            o.Albedo = _Color * (1-decal.a) + decal.rgb * decal.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = _Color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
