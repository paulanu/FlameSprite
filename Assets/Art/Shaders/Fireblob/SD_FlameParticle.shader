Shader "Unlit/FlameParticle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PlayerHeight ("Player height", float) = 1
        _PlayerBase ("Player Base", float) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent+1"}
        LOD 100

        ZWrite On
        Pass
        {   
            //stencil buffer prevents particles from overlapping with themselves or the player body
            Stencil
            {
                Ref 10  
                Comp notequal 
                Pass Replace 
            }

        
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                fixed3 wPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _PlayerHeight;
            float _PlayerBase;
            uniform float _GradientHeight;
            uniform float4 _BaseColor;
            uniform float4 _GradientColor;
            uniform float _Emission;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                o.wPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            float iLerp( float a, float b, float v ) {
                return min(max((v - a) / (b - a), 0), 1);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col-.95);

                // calculate gradient using same method as in SD_Fireblob.shader 
                float y = iLerp(_PlayerBase, _PlayerHeight + _PlayerBase, i.wPos.y);
                float gradientHeight = 1/(_GradientHeight * 2);
                float gradientMask = saturate(y * gradientHeight);
                
                // calculate color
                float4 color = _BaseColor + (_GradientColor * (1-gradientMask));
                color.a = _BaseColor.a;
                
                return color * _Emission;
            }
            ENDCG
        }

    }
}
