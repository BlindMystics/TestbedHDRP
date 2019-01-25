Shader "Blind Mystics/Unity Mat Verification"
{
    Properties
    {

		_ColourInRadius("Colour In Radius", Color) = (1,1,0,1)
		_ColourOutOfRadius("Colour Out Of Radius", Color) = (0,1,1,1)

		_ColourChangeWorldPos("Colour Change World Pos", Vector) = (0,0,0,0)
		_ColourChangeRadius("Colour Change Radius", Float) = 1.0

        

		// Blending state
		//Although I can't really definitvely say, I'm pretty sure sureface type of 1 is transparent.
		_SurfaceType("__surfacetype", Float) = 1.0 
		[HideInInspector] _BlendMode("__blendmode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
		//[HideInInspector] _CullMode("__cullmode", Float) = 2.0
		[HideInInspector] _ZTestModeDistortion("_ZTestModeDistortion", Int) = 8
		
    }

	HLSLINCLUDE

	#pragma target 4.5
	#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

	#pragma require geometry

	#pragma shader_feature _ALPHATEST_ON
	//#pragma shader_feature _DOUBLESIDED_ON
				// #pragma shader_feature _DOUBLESIDED_ON - We have no lighting, so no need to have this combination for shader, the option will just disable backface culling

	#pragma shader_feature _EMISSIVE_COLOR_MAP

				// Keyword for transparent
	#pragma shader_feature _SURFACE_TYPE_TRANSPARENT
	#pragma shader_feature _ _BLENDMODE_ALPHA _BLENDMODE_ADD _BLENDMODE_PRE_MULTIPLY
	#pragma shader_feature _ENABLE_FOG_ON_TRANSPARENT

	#define HAVE_VERTEX_MODIFICATION

	//#define _SURFACE_TYPE_TRANSPARENT

	#define _BLENDMODE_ALPHA

	ENDHLSL

    SubShader
    {
		Tags{ "RenderPipeline" = "HDRenderPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off //Back / Front / Off
        //Tags { "RenderPipeline" = "HDRenderPipeline" "RenderType"="HDUnlitShader" "Queue" = "Transparent" }
		//Tags{ "RenderPipeline" = "HDRenderPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass
        {
			//Surface[_SurfaceType]
			//Blend[_SrcBlend][_DstBlend]
			//ZWrite[_ZWrite]
			//Cull[_CullMode]

			HLSLPROGRAM

			#include "UnityCG.cginc"

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
				float4 worldSpacePos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _ShieldColour;
			float4 _ShieldBreakColour;

			float _SideLength;
			float _ExtrudeDistance;

			float _IntroRegionTop;
			float _IntroRegionWidth;

			float _VertexSpin;

			float4 _FailurePoint;
			float _FailureRadius;
			float _FailureBrightDist;

			float4 _LaserHolePos;
			float _LaserHoleRadius;
			float _HoleRingSize;

			float4 _AddBrightnessPlane;
			float _AddBrightnessMax;
			float _AddBrightnessDist;

			float4 _ColourInRadius;
			float4	_ColourOutOfRadius;

			float4 _ColourChangeWorldPos;
			float _ColourChangeRadius;

			v2g ExtrudeVertex(appdata v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			// Rotation with angle (in radians) and axis
			float3x3 AngleAxis3x3(float angle, float3 axis)
			{
				float c, s;
				sincos(angle, s, c);

				float t = 1 - c;
				float x = axis.x;
				float y = axis.y;
				float z = axis.z;

				return float3x3(
					t * x * x + c, t * x * y - s * z, t * x * z + s * y,
					t * x * y + s * z, t * y * y + c, t * y * z - s * x,
					t * x * z - s * y, t * y * z + s * x, t * z * z + c
				);
			}

			[maxvertexcount(3)]
			void ExtrudeGeometry(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
			{
				g2f o;

				float4 verts[] = {
					IN[0].vertex,
					IN[1].vertex,
					IN[2].vertex
				};

				float2 uvs[] = {
					float2(0.0,0.0),
					float2(0.5,1.0),
					float2(1.0,0.0)
				};

				for (int i = 0; i < 3; i++) {

					//o.uv = IN[i].uv; //TODO - Set these all to be similar.
					o.uv = uvs[i];
					o.vertex = UnityObjectToClipPos(verts[i]);
					//o.vertex = UnityObjectToClipPos(mul(unity_WorldToObject, mul(unity_ObjectToWorld, verts[i])));
					//mul(unity_WorldToObject

					float inRadius = 0;
					float3 toPoint = mul(unity_WorldToObject, _ColourChangeWorldPos).xyz - verts[i].xyz;
					//float3 toPoint = _ColourChangeWorldPos.xyz - mul(unity_ObjectToWorld, verts[i]).xyz;
					//float3 toPoint = _ColourChangeWorldPos.xyz - verts[i].xyz;
					if (length(toPoint) < _ColourChangeRadius) {
						inRadius = 1;
					}


					o.props = float4(inRadius, 0, 0, 0);
					o.worldSpacePos = mul(unity_ObjectToWorld, verts[i]);

					tristream.Append(o);
				}
				
			}

			fixed4 ExtrudeFragment(g2f i) : SV_Target
			{
				if (i.props.x) {
					return _ColourInRadius;
				}

				return _ColourOutOfRadius;

			}

			ENDHLSL

        }
    }
}
