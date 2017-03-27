Shader "Chroma2/DecalShader" {
    Properties {
         _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    }

    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Transparent"}
        LOD 200
        ZWrite off
        Offset -1, -1
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
         Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
             #pragma vertex vert
             #pragma fragment frag alpha
             #pragma multi_compile_fwdbase
             #pragma fragmentoption ARB_fog_exp2
             #pragma fragmentoption ARB_precision_hint_fastest
             
             #include "UnityCG.cginc"
             #include "AutoLight.cginc"

             struct v2f
             {
                 float4  pos         : SV_POSITION;
                 float2  uv          : TEXCOORD0;
                 LIGHTING_COORDS(1,2)
             };

             v2f vert (appdata_tan v)
             {
                 v2f o;

                 o.pos = mul( UNITY_MATRIX_MVP, v.vertex);
                 o.uv = v.texcoord.xy;
                 TRANSFER_VERTEX_TO_FRAGMENT(o);
                 return o;
             }

             sampler2D _MainTex;

             fixed4 frag(v2f i) : COLOR
             {
                 fixed atten = LIGHT_ATTENUATION(i); // Light attenuation + shadows.
                 //fixed atten = SHADOW_ATTENUATION(i); // Shadows ONLY.
                 return tex2D(_MainTex, i.uv) * atten;
             }

//            struct Input {
//             float2 uv_MainTex;
//            };

//            void surf (Input IN, inout SurfaceOutput o) {
//             fixed4 c = tex2D(_MainTex, IN.uv_MainTex);// * _Color;
//             o.Albedo = c.rgb;
//             o.Alpha = c.a;
//            }

         ENDCG
     }

     Pass {
         Tags {"LightMode" = "ForwardAdd"}
         Blend One One
         CGPROGRAM
             #pragma vertex vert
             #pragma fragment frag
             #pragma multi_compile_fwdadd_fullshadows
             #pragma fragmentoption ARB_fog_exp2
             #pragma fragmentoption ARB_precision_hint_fastest

             #include "UnityCG.cginc"
             #include "AutoLight.cginc"

             struct v2f
             {
                 float4  pos         : SV_POSITION;
                 float2  uv          : TEXCOORD0;
                 LIGHTING_COORDS(1,2)
             };

             v2f vert (appdata_tan v)
             {
                 v2f o;

                 o.pos = mul( UNITY_MATRIX_MVP, v.vertex);
                 o.uv = v.texcoord.xy;
                 TRANSFER_VERTEX_TO_FRAGMENT(o);
                 return o;
             }

             sampler2D _MainTex;

             fixed4 frag(v2f i) : COLOR
             {
                 fixed atten = LIGHT_ATTENUATION(i); // Light attenuation + shadows.
                 //fixed atten = SHADOW_ATTENUATION(i); // Shadows ONLY.
                 return tex2D(_MainTex, i.uv) * atten;
             }
         ENDCG
     }
    }

    Fallback "Transparent/VertexLit"
}