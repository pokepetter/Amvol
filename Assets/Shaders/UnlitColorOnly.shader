Shader "Chroma2/Unlit Color Only" {

 

Properties {

    _Color ("Color", Color) = (1,1,1)

	}

 

SubShader {
	Tags {"RenderType"="Color"}
    Color [_Color]

    Pass {}

	} 

 

}