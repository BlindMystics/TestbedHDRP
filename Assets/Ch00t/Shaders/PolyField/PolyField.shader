Shader "Blind Mystics/PolyField"
{
	Properties
	{
		[HDR]_FaceColor("Face Color", Color) = (1.0, 0.0, 0.0, 0.5)
		[HDR]_QuadColor("Quad Color", Color) = (0.0, 0.0, 1.0, 1.0)
		[HDR]_LineColor("Line Color", Color) = (0.0, 1.0, 0.0, 1.0)

		_QuadSize("Quad Width", Float) = 0.1
		_LineWidth("Line Width", Float) = 0.05
	}
		SubShader
	{
		Tags { "RenderPipeline" = "HDRenderPipeline" "RenderType" = "HDUnlitShader" "Queue" = "Transparent" }
		LOD 100

		ZWrite off
		Blend SrcAlpha OneMinusSrcAlpha

		//This effect should end up looking similar to the effect in the VFX Graph demonstration video...

		//Should be implemented as multiple passes to solve issues and ensure draw order.
		//TODO: HDRP and multipass rendering aren't playing along here.

		Pass
		{
			Name "Triangle"

			Cull off

			HLSLPROGRAM
			#pragma vertex PolyFieldVertex
			#pragma geometry PolyFieldGeometry
			#pragma fragment PolyFieldFragment

			#include "UnityCG.cginc"

			#include "PolyFieldVertex.hlsl"
			#include "PolyFieldGeometry.hlsl"
			#include "PolyFieldFragment.hlsl"

			ENDHLSL
		}

		Pass
		{
			Name "Line"

			Cull back

			HLSLPROGRAM
			#pragma vertex PolyFieldVertex
			#pragma geometry PolyFieldLineGeometry
			#pragma fragment PolyFieldFragment

			#include "UnityCG.cginc"

			#include "PolyFieldVertex.hlsl"
			#include "PolyFieldGeometry.hlsl"
			#include "PolyFieldFragment.hlsl"

			ENDHLSL
		}

		Pass
		{
			Name "Quad"

			Cull back

			HLSLPROGRAM
			#pragma vertex PolyFieldVertex
			#pragma geometry PolyFieldQuadGeometry
			#pragma fragment PolyFieldFragment

			#include "UnityCG.cginc"

			#include "PolyFieldVertex.hlsl"
			#include "PolyFieldGeometry.hlsl"
			#include "PolyFieldFragment.hlsl"

			ENDHLSL
		}
	}
}
