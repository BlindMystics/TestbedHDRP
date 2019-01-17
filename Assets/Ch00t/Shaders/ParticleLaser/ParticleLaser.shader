Shader "Blind Mystics/Particle Laser"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Width("Width", Float) = 0.1

		_PulseWidth("Pulse Width", Float) = 0.1

		[PerRenderData] _TotalBeamLength("Total Beam Length", Float) = 1.0
		[PerRenderData] _AnimationTime("Animation Time", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderPipeline" = "HDRenderPipeline" "RenderType" = "HDUnlitShader" "RenderType"="Transparent" }
        LOD 100

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
            #pragma vertex ParticleLaserVertex
			#pragma geometry ParticleLaserGeometry
            #pragma fragment ParticleLaserFragment

            #include "UnityCG.cginc"
			#include "ParticleLaserVertex.hlsl"
			#include "ParticleLaserGeometry.hlsl"
			#include "ParticleLaserFragment.hlsl"

            ENDCG
        }
    }
}
