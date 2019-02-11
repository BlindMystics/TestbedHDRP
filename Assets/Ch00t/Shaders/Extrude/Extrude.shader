Shader "Blind Mystics/Extrude"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		[HDR]_Color("Color", color) = (1.0, 1.0, 1.0, 1.0)
		[HDR]_InnerColor("Inner Color", color) = (0.0, 0.0, 0.0, 1.0)
		_ExtrudeDistance("Extrude Distance", Float) = 1.0

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
        Tags { "RenderPipeline" = "HDRenderPipeline" "RenderType"="HDUnlitShader" }

        Pass
        {

			HLSLPROGRAM

			#include "UnityCG.cginc"
			#include "../Common/EffectRegion.hlsl"

			#pragma vertex ExtrudeVertex
			#pragma geometry ExtrudeGeometry
			#pragma fragment ExtrudeFragment

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
				float4 props : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _SideLength;
			float _ExtrudeDistance;

			float4 _Color;
			float4 _InnerColor;

			v2g ExtrudeVertex(appdata v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			[maxvertexcount(21)]
			void ExtrudeGeometry(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
			{
				g2f o;

				float3 facePosition = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3.0;

				if (!WithinEffectRegion(facePosition.y)) {
					for (int i = 0; i < 3; i++) {
						o.uv = IN[i].uv;
						o.vertex = UnityObjectToClipPos(IN[i].vertex);
						o.props = float4(0, 0, 0, 0);

						tristream.Append(o);
					}

					return;
				}

				o.uv = IN[0].uv;

				float3 edgeA = IN[1].vertex - IN[0].vertex;
				float3 edgeB = IN[2].vertex - IN[0].vertex;

				float effectValue = EffectRegionValue(facePosition.y);
				float extrudeDistanceMod = _ExtrudeDistance * sin(effectValue * 3.14159265);

				float4 extrudeVector = float4(normalize(cross(edgeA, edgeB)) * extrudeDistanceMod, 0);

				float hsl = _SideLength / 2.0;

				float4 v0 = IN[0].vertex;
				float4 v1 = IN[1].vertex;
				float4 v2 = IN[2].vertex;
				float4 exV0 = v0 + extrudeVector;
				float4 exV1 = v1 + extrudeVector;
				float4 exV2 = v2 + extrudeVector;

				float4 verts[] = {
					exV0, exV1, exV2,

					v0, v1, exV0,
					exV0, v1, exV1,

					v1, v2, exV1,
					exV1, v2, exV2,

					v2, v0, exV2,
					exV2, v0, exV0
				};

				int stripCounter = 0;

				for (int i = 0; i < 21; i++) {
					o.vertex = UnityObjectToClipPos(verts[i]);

					if (i > 2) {
						o.props = float4(1, 0, 0, 0);
					} else {
						o.uv = IN[i].uv;
						o.props = float4(0, 0, 0, 0);
					}

					tristream.Append(o);
					
					if (stripCounter++ == 2) {
						stripCounter = 0;
						tristream.RestartStrip();
					}
				}
			}

			fixed4 ExtrudeFragment(g2f i) : SV_Target
			{
				if (i.props.x) {
					return _InnerColor;
				}

				return tex2D(_MainTex, i.uv) * _Color;
			}

			ENDHLSL

        }
    }
}
