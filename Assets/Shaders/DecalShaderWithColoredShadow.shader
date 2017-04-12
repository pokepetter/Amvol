// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Chroma2/DecalShaderWithColoredShadow" {
    Properties {
         _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    }
    SubShader {
        Tags {"Queue" = "Geometry+10" "RenderType" = "Transparent"}
        Cull Back
//        ZWrite On
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
                
                o.pos = UnityObjectToClipPos( v.vertex);
                o.uv = v.texcoord.xy;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }
            
            sampler2D _MainTex;
            float4 GlobalShadowColor;
            
            fixed4 frag(v2f i) : COLOR
            {
                fixed atten = LIGHT_ATTENUATION(i);
                fixed4 texCol = tex2D(_MainTex, i.uv);
                fixed4 lighted = (GlobalShadowColor * (1 - atten)) + (texCol * atten);
                lighted.a = texCol.a;
                return lighted;
            }

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

                 o.pos = UnityObjectToClipPos( v.vertex);
                 o.uv = v.texcoord.xy;
                 TRANSFER_VERTEX_TO_FRAGMENT(o);
                 return o;
             }

             sampler2D _MainTex;
             float4 GlobalShadowColor;

             fixed4 frag(v2f i) : COLOR
             {
                 fixed atten = LIGHT_ATTENUATION(i);                                  
                 return (GlobalShadowColor * (1 - atten)) + (tex2D(_MainTex, i.uv) * atten);
             }
         ENDCG
     }
    }

    Fallback "Transparent/VertexLit"
}