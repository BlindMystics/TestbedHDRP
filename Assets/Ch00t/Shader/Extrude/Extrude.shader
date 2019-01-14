Shader "Blind Mystics/Extrude"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SideLength("Side Length", Float) = 0.1
		_DistanceAlongNormal("Distance Along Normal", Float) = 1.0
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

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _SideLength;
			float _DistanceAlongNormal;


			//TODO: The goal of this shader is to extrude all faces along their normal into triangular prisms
			//The interior sides of the pyramids should be interestingly coloured, the surface should be the texture colour

			//Extension: define a vertical region over which the effect takes place. The length of the extrusion should be a sin function over that area.
			//This vertical region should then be animated along the height of the mesh - using a C# program.

			v2g CubicateVertex(appdata v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			[maxvertexcount(39)]
			void CubicateGeometry(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
			{
				g2f o;

				float3 edgeA = IN[1].vertex - IN[0].vertex;
				float3 edgeB = IN[2].vertex - IN[0].vertex;

				float3 normal = normalize(cross(edgeA, edgeB));

				float hsl = _SideLength / 2.0;

				for (int i = 0; i < 3; i++) {
					o.uv = IN[i].uv;
					o.vertex = UnityObjectToClipPos(IN[i].vertex + normal * _DistanceAlongNormal);
					tristream.Append(o);
				}
			}

			fixed4 CubicateFragment(g2f i) : SV_Target
			{
				// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				return float4(i.uv.x, i.uv.y, 1, 1);
			}

			ENDHLSL

        }
    }
}
