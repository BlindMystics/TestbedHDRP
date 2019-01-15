Shader "Blind Mystics/Cubicate (Transparent)"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", color) = (1.0, 1.0, 1.0, 1.0)

		_SideLength("Side Length", Float) = 0.1
		_DistanceAlongNormal("Distance Along Normal", Float) = 1.0

		[PerRenderData]_EffectRegionTop("Effect Region Top", Float) = 1.0
		[PerRenderData]_EffectRegionBottom("Effect Region Bottom", Float) = 0.0
    }

	HLSLINCLUDE

	#pragma target 4.5
	#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

	#pragma require geometry

	#define HAVE_VERTEX_MODIFICATION

	ENDHLSL

    SubShader
    {
        Tags { "RenderPipeline" = "HDRenderPipeline" "RenderType"="HDUnlitShader" "Queue"="Transparent" }

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
			HLSLPROGRAM

			#include "UnityCG.cginc"
			#include "../Common/EffectRegion.hlsl"

			#include "CubicateVertex.hlsl"
			#include "CubicateGeometry.hlsl"
			#include "CubicateFragment.hlsl"

			#pragma vertex CubicateVertex
			#pragma geometry CubicateGeometry
			#pragma fragment CubicateFragment

			ENDHLSL
        }
    }
}
