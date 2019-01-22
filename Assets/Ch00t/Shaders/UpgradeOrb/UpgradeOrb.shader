Shader "Blind Mystics/Upgrade Orb"
{
	Properties
	{
		_InnerColor("Inner Color", color) = (0.0, 0.0, 0.0, 1.0)
		_OuterColor("Outer Color", color) = (0.0, 1.0, 0.85, 1.0)

		_SideLength("Side Length", Float) = 0.1

		[PerRenderData]_DripRatio("Drip Ratio", Float) = 0.2
		_DripLength("Drip Length", Float) = 0.5
		_DripSpeed("Drip Speed", Float) = 1.2

		_Depth("Depth", Float) = 1.0
		_PulseWidth("Pulse Width", Float) = 0.2

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
		Tags { "RenderPipeline" = "HDRenderPipeline" "RenderType" = "HDUnlitShader" }

		Pass
		{
			HLSLPROGRAM

			#include "UnityCG.cginc"
			#include "../Common/EffectRegion.hlsl"

			#include "UpgradeOrbVertex.hlsl"
			#include "UpgradeOrbGeometry.hlsl"
			#include "UpgradeOrbFragment.hlsl"

			#pragma vertex UpgradeOrbVertex
			#pragma geometry UpgradeOrbGeometry
			#pragma fragment UpgradeOrbFragment

			ENDHLSL
		}
	}
}
