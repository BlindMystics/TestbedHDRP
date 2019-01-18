Shader "Blind Mystics/EnergyShieldGeom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ShieldColour("Shield Colour", Color) = (1,1,1,1)
		_ShieldBreakColour("Shield Colour", Color) = (1,1,1,1)
		_ExtrudeDistance("Extrude Distance", Float) = 1.0
		[PerRenderData]_IntroRegionTop("Extrude Region Top", Float) = -1.0
		[PerRenderData]_IntroRegionWidth("Extrude Region Bottom", Float) = 0.4
		_VertexSpin("Vertex Spin", Float) = 0.0

		[PerRenderData]_FailurePoint("Failure Point", Vector) = (0,0,0,0)
		[PerRenderData]_FailureRadius("Failure Radius", Float) = 0.0
		[PerRenderData]_FailureBrightDist("Failure Bright Distance", Float) = 1.0

		[PerRenderData]_LaserHolePos("Laser Hole Position", Vector) = (0,0,0,0)
		[PerRenderData]_LaserHoleRadius("Laser Hole Radius", Float) = 0.3
		_HoleRingSize("Hole Ring Size", Float) = 0.2

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

				float3 facePosition = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3.0;

				float3 worldSpaceFacePosition = mul(unity_ObjectToWorld, facePosition).xyz;

				float visible = 1;
				float extruded = 0;
				float breakColourBlend = 0;

				
				if (_FailureRadius > 0) {
					float3 toFailurePoint = _FailurePoint.xyz - worldSpaceFacePosition;
					float distSquardToFailure = dot(toFailurePoint, toFailurePoint);
					float distToFailure = sqrt(distSquardToFailure);

					float disapearThreshold = _FailureRadius - _FailureBrightDist;
					
					if (distToFailure < _FailureRadius) {
						if (distToFailure < disapearThreshold) {
							visible = 0;
						} else {
							breakColourBlend = 1.0 - ((distToFailure - disapearThreshold) / _FailureBrightDist);
						}
					}
				}

				if (worldSpaceFacePosition.y < _IntroRegionTop) {
					if (worldSpaceFacePosition.y < (_IntroRegionTop - _IntroRegionWidth)) {
						visible = 0;
					} else {
						extruded = 1;
					}
				}

				float4 verts[] = {
					IN[0].vertex,
					IN[1].vertex,
					IN[2].vertex
				};

				float extrudePositionNormalized = 0.0;

				if (extruded) {

					float3 edgeA = IN[1].vertex - IN[0].vertex;
					float3 edgeB = IN[2].vertex - IN[0].vertex;

					extrudePositionNormalized = (_IntroRegionTop - worldSpaceFacePosition.y) / _IntroRegionWidth;
					extrudePositionNormalized = 1.0 - cos(extrudePositionNormalized * 1.57079632679); //Fast when far, slow when close. Stop trianges from snapping into place.
					
					breakColourBlend = 1.0;
					//breakColourBlend = extrudePositionNormalized;


					float extrudeDistanceMod = extrudePositionNormalized * _ExtrudeDistance;
					//float extrudeDistanceMod = _ExtrudeDistance * sin(extrudePositionNormalized * 3.14159265);

					float3 crossProductNormalised = normalize(cross(edgeA, edgeB));

					float3 extrudeVector = crossProductNormalised * extrudeDistanceMod;

					float3x3 rotationMatrix = AngleAxis3x3(_VertexSpin * extrudePositionNormalized, crossProductNormalised);

					for (int i = 0; i < 3; i++) {
						float3 recenteredPoint = IN[i].vertex - facePosition;
						float3 rotatedPoint = mul(rotationMatrix, recenteredPoint);
						float3 vertPos = rotatedPoint + facePosition;
						verts[i] = float4(vertPos + extrudeVector, 0);
					}

				} else {
					
					float top2 = _IntroRegionTop + _IntroRegionWidth;
					if (top2 > worldSpaceFacePosition.y) {
						breakColourBlend = (top2 - worldSpaceFacePosition.y) / _IntroRegionWidth;
					}
					//extrudePositionNormalized = (_IntroRegionTop - worldSpaceFacePosition.y) / extrudeRegionLength;
				}

				float2 uvs[] = {
					float2(0.0,0.0),
					float2(0.5,1.0),
					float2(1.0,0.0)
				};

				for (int i = 0; i < 3; i++) {

					//o.uv = IN[i].uv; //TODO - Set these all to be similar.
					o.uv = uvs[i];
					o.vertex = UnityObjectToClipPos(verts[i]);
					o.props = float4(visible, extruded, extrudePositionNormalized, breakColourBlend);
					o.worldSpacePos = mul(unity_ObjectToWorld, verts[i]);

					tristream.Append(o);
				}
				
			}

			fixed4 ExtrudeFragment(g2f i) : SV_Target
			{
				if (!i.props.x) {
					discard;
					return fixed4(0,0,0,1);
				}

				float3 toLaserHoleCenter = _LaserHolePos.xyz - i.worldSpacePos.xyz;
				float distToLaserHole = length(toLaserHoleCenter);
				if (distToLaserHole < _LaserHoleRadius) {
					discard;
					return fixed4(1, 0, 0, 1);
				}

				float4 brokenShieldColour = _ShieldBreakColour;

				if (distToLaserHole < (_LaserHoleRadius + _HoleRingSize)) {
					float mixAmount = ((_LaserHoleRadius + _HoleRingSize) - distToLaserHole) / _HoleRingSize;
					i.props.w = mixAmount;
					brokenShieldColour.a = 1.0 - mixAmount;
				}

				fixed4 mainTex = tex2D(_MainTex, i.uv);
				fixed4 outputColour = _ShieldColour;
				outputColour.a *= mainTex.r;

				outputColour = lerp(outputColour, brokenShieldColour, i.props.w);
				

				outputColour.a *= (1.0 - i.props.z);
				return outputColour;
			}

			ENDHLSL

        }
    }
}
