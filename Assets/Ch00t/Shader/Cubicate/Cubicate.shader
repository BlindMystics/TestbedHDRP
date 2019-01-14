Shader "Blind Mystics/Cubicate"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_SideLength("Side Length", Float) = 0.1
		_DistanceAlongNormal("Distance Along Normal", Float) = 1.0
    }

	HLSLINCLUDE

	#pragma target 4.5
	#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

	#pragma require geometry

	#define HAVE_VERTEX_MODIFICATION

			/*
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
	*/

	ENDHLSL

    SubShader
    {
        Tags { "RenderPipeline" = "HDRenderPipeline" "RenderType"="HDUnlitShader" }

        Pass
        {

			HLSLPROGRAM

			#include "UnityCG.cginc"

			#pragma vertex CubicateVertex
			#pragma geometry CubicateGeometry
			#pragma fragment CubicateFragment

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2g
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			struct g2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float4 _Color;
			float _SideLength;
			float _DistanceAlongNormal;

			v2g CubicateVertex(appdata v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.uv = v.uv;
				return o;
			}

			[maxvertexcount(36)]
			void CubicateGeometry(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
			{
				g2f o;
				o.uv = IN[0].uv;

				float3 facePosition = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3.0;

				float3 edgeA = IN[1].vertex - IN[0].vertex;
				float3 edgeB = IN[2].vertex - IN[0].vertex;

				float3 normal = normalize(cross(edgeA, edgeB));

				float hsl = _SideLength / 2.0;

				float4 cubePosition = float4(facePosition + normal * _DistanceAlongNormal, 0);

				float4 v0 = UnityObjectToClipPos(cubePosition + float4(-hsl, hsl, -hsl, 0));
				float4 v1 = UnityObjectToClipPos(cubePosition + float4(-hsl, hsl, hsl, 0));
				float4 v2 = UnityObjectToClipPos(cubePosition + float4(hsl, hsl, -hsl, 0));
				float4 v3 = UnityObjectToClipPos(cubePosition + float4(hsl, hsl, hsl, 0));
				float4 v4 = UnityObjectToClipPos(cubePosition + float4(-hsl, -hsl, -hsl, 0));
				float4 v5 = UnityObjectToClipPos(cubePosition + float4(-hsl, -hsl, hsl, 0));
				float4 v6 = UnityObjectToClipPos(cubePosition + float4(hsl, -hsl, -hsl, 0));
				float4 v7 = UnityObjectToClipPos(cubePosition + float4(hsl, -hsl, hsl, 0));

				float4 verts[36] =
				{
					v0, v1, v2,
					v2, v1, v3,
					
					v4, v6, v5,
					v6, v7, v5,
					
					v4, v0, v6,
					v6, v0, v2,

					v5, v7, v1,
					v7, v3, v1,

					v6, v2, v7,
					v2, v3, v7,

					v4, v5, v0,
					v0, v5, v1				
				};

				int stripCounter = 0;

				for (int i = 0; i < 36; i++) {
					o.vertex = verts[i];
					tristream.Append(o);

					if (stripCounter++ == 2) {
						stripCounter = 0;
						tristream.RestartStrip();
					}
				}
			}

			fixed4 CubicateFragment(g2f i) : SV_Target
			{
				return _Color;
			}

			ENDHLSL

        }
    }
}
