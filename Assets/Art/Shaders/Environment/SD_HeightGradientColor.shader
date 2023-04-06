Shader "Custom/HeightGradientColor"
{
    Properties
    {
        _StartColor ("Gradient start", Color) = (1,1,1,1)
        _EndColor ("Gradient end", Color) = (0,0,0,0)
        _StartHeight ("Lowest height", float) = 5
        _EndHeight ("Tallest height", float) = 20 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        struct Input
        {
            float3 color;
        };

        float4 _StartColor; 
        float4 _EndColor; 
        float _StartHeight; 
        float _EndHeight; 

        float ilerp(float start, float end, float val) 
        {
            val = clamp(val, start, end); 
            return (val - start)/(end - start); 
        }

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);

            float originHeight = mul(unity_ObjectToWorld, float4(0,0,0,1)).y; 
            float val = ilerp(_StartHeight, _EndHeight, originHeight);
            o.color = lerp(_StartColor, _EndColor, val); 
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = IN.color;
            o.Metallic = 0;
            o.Smoothness = 0;
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
