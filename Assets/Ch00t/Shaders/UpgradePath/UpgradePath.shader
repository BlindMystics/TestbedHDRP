Shader "Blind Mystics/Upgrade Path"
{
	Properties
	{
		_StartColor("Start Color", Color) = (0.0, 0.0, 1.0, 1.0)
		_EndColor("End Color", Color) = (1.0, 0.0, 0.0, 1.0)
		_LineColor("Line Color", Color) = (0.0, 1.0, 0.0, 1.0)

		_CubeWidth("Cube Width", Float) = 0.1
		_LineWidth("Line Width", Float) = 0.05

		[PerRenderData] _TotalLineLength("Total Line Length", Float) = 1.0
		[PerRenderData] _AnimationTime("Animation Time", Float) = 0.0
		[PerRenderData] _LineEnd("Laser End", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderPipeline" = "HDRenderPipeline" "RenderType" = "HDUnlitShader" }
        LOD 100

		//cull off

		//TODO: Begin by just rendering a cube at each vertex along the line.
		//Then start playing around with particle effects.
		//Effects to make:
		// - Cubesplosion sweeper
		// - Gluon gun wiggly lines
		//
		//Don't forget to apply a bloom effect to them.
        Pass
        {
            CGPROGRAM
            #pragma vertex UpgradePathVertex
			#pragma geometry UpgradePathGeometry
            #pragma fragment UpgradePathFragment

			#include "UnityCG.cginc"

			#include "UpgradePathVertex.hlsl"
			#include "UpgradePathGeometry.hlsl"
			#include "UpgradePathFragment.hlsl"

            ENDCG
        }
    }
}
