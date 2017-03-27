Shader "Chroma2/UnlitSurfaceWithColoredShadows" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
        _Color ("Tint color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque"}

		Cull Back
        ZWrite On

		CGPROGRAM
		#pragma surface surf CustomLambert

        #include "UnityCG.cginc"
        #include "AutoLight.cginc"

        float4 GlobalShadowColor;

        half4 LightingCustomLambert (SurfaceOutput s, half3 lightDir, half atten){
            half4 c;
            c.r = 1 * (1 - atten);
            c.g = 1 * (1 - atten);
            c.b = 1 * (1 - atten);
            half4 sh;
            c.a = s.Alpha;
            sh.rgb = s.Albedo * (1 - c.rgb) + c * GlobalShadowColor;
            sh.a = 1;
            return sh;
        }

		sampler2D _MainTex;
        fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * _Color.rgb;
//			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	} 
	FallBack "Diffuse"
}
