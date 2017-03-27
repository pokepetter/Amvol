Shader "Debug/GrayscaleDepth" {
	Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

        ZWrite On

		CGPROGRAM
		#pragma surface surf Lambert

        uniform sampler2D _CameraDepthTexture;
        sampler2D _MainTex;

		struct Input {
            float2 uv_MainTex;
			INTERNAL_DATA
		};

		void surf (Input IN, inout SurfaceOutput o) {
            float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, IN.uv_MainTex));
            float linEyeDepth = Linear01Depth(depth);
            half4 c;
            c.r = linEyeDepth;
            c.g = linEyeDepth;
            c.b = linEyeDepth;
			o.Albedo = c.rgb;
			o.Alpha = 1;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
