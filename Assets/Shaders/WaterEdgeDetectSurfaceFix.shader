// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Chroma2/WaterEdgeDetectSurfaceFix" {
    Properties{
        _OverlayTex ("Overlay (RGBA)", 2D) = "white" {}
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _HighlightColor("Highlight Color", Color) = (1, 1, 1, .5)
        _HighlightThresholdMax("Highlight Threshold Max", Float) = 1
        _Cube ("Reflection Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
        _TotalAlpha("Total alpha", Float) = 1
    }
    SubShader{
        Tags { "Queue" = "Transparent" "RenderType"="Transparent"  }

        ZWrite Off
        Cull Off

        Blend SrcAlpha OneMinusSrcAlpha

        CGPROGRAM
// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members uv_MainTex)
#pragma exclude_renderers d3d11 xbox360
        #pragma surface surf CustomLambert vertex:vert

        #include "UnityCG.cginc"
        #include "AutoLight.cginc"

        uniform sampler2D _CameraDepthTexture; //Depth Texture
        uniform float4 _HighlightColor;
        uniform float _HighlightThresholdMax;
        uniform float _TotalAlpha;

        half4 LightingCustomLambert (SurfaceOutput s, half3 lightDir, half atten){
            half4 sh;
            sh.rgb = s.Albedo;
            sh.a = s.Alpha;//_TotalAlpha;
            return sh;
        }

        struct Input{
            float2 uv_MainTex;
            float2 uv_OverlayTex;
            float3 worldRefl;
            float4 pos : SV_POSITION;
            float4 projPos : TEXCOORD1;
            INTERNAL_DATA
        };

        void vert(inout appdata_full v, out Input o){
            o.pos = UnityObjectToClipPos(v.vertex);
            o.projPos = ComputeScreenPos(o.pos);
        }

        sampler2D _MainTex;
        sampler2D _OverlayTex;
        samplerCUBE _Cube;

        void surf (Input IN, inout SurfaceOutput o) {
            half4 tex = tex2D (_MainTex, IN.uv_MainTex);
            half4 overlay = tex2D (_OverlayTex, IN.uv_OverlayTex);

            float4 finalColor;
            finalColor.rgb = tex.rgb;// + (1- overlay.a * overlay.rgb); (1 - overlay.a) *

            finalColor.a = tex.a * (1 - overlay.a);

            float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)));
            float partZ = IN.projPos.z;
            float softFactor = saturate (1 * (sceneZ-partZ)); //_InvFade

//            if(diff <= 1){
//
//                finalColor = lerp(_HighlightColor, finalColor, float4(diff, diff, diff, diff));
//            }

            o.Albedo.rgb = finalColor * softFactor + _HighlightColor * (1 - softFactor);

            o.Alpha = (1 - softFactor) + (finalColor.a * _TotalAlpha);//0.5 * finalColor.a;//finalColor.a * (1 - softFactor);
        }


        ENDCG

    }
    FallBack "VertexLit"
}
