// Upgrade NOTE: replaced 'SeperateSpecular' with 'SeparateSpecular'

Shader "Chroma2/Vertex Lit No Light" {

Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
    _SpecColor ("Spec Color", Color) = (1,1,1,0)
    _Emission ("Emmisive Color", Color) = (0,0,0,0)
    _Shininess ("Shininess", Range (0.01, 1)) = 0.7
    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
}

SubShader {

    Tags {Queue=Transparent}

    Blend SrcAlpha OneMinusSrcAlpha

    BindChannels {

        Bind "vertex", vertex

        Bind "texCoord", texCoord

        Bind "color", color

    }

    Pass {

        SetTexture[_MainTex] {Combine texture, primary}

    }        

}

Fallback "Alpha/VertexLit", 1
}