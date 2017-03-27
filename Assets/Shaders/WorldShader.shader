// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/WorldShader" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" { } //Base (RGB) - the base texture
        _AlphaTex ("Alpha (B&W)", 2D) = "white" { } //Alpha (B&W) - the see through walls alpha mask
        _camHeight ("Camera Height", float) = 100 //Camera Height - bias for the height check
    }
    SubShader {
   
        Pass {
            Tags {Queue = Transparent}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
                CGPROGRAM //Shader Start, Vertex Shader named vert, Fragment shader named frag
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
               
                sampler2D _MainTex;
                sampler2D _AlphaTex;
                float _camHeight;
               
                struct v2f
                {
                        float4  position : SV_POSITION;
                        float4  suv : TEXCOORD0;
                        float2  uv : TEXCOORD1;
                        float3  pos : TEXCOORD2;
                };
               
                float4 _MainTex_ST;
               
                v2f vert (appdata_base v)
                {
                        v2f o;
                        o.position = mul (UNITY_MATRIX_MVP, v.vertex); //Transform the vertex position
                        o.suv = o.position; //pass position for screen coords
                        o.uv = TRANSFORM_TEX (v.texcoord, _MainTex); //Prepare the vertex uv
                        o.pos = mul (unity_ObjectToWorld, v.vertex); //world position for height check
                        return o;
                }
               
                half4 frag (v2f i) : COLOR
                {
                    float4 texcol = tex2D (_MainTex, i.uv); //base texture
                    float4 output = texcol;
                    if (i.pos.y > _WorldSpaceCameraPos.y - _camHeight) //if object is higher than player
                    {
                        float2 uv = i.suv.xy / i.suv.w; //get screen coords
                        uv = (uv + 1.0)/2;
                        uv.y = 1.0 - uv.y;
                        output.a = 1 - ((tex2D(_AlphaTex, uv).r * 1.5) - 0.5); //set the alpha
                    }
                        return output;
                }
               
                ENDCG //Shader End
        }
    }
}