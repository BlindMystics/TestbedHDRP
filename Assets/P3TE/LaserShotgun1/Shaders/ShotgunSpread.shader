Shader "Blind Mystics/Shotgun Spread"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_StartColor("Start Color", Color) = (0.0, 0.0, 1.0, 1.0)
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment ShotgunSpreadFragment
		// make fog work
#pragma multi_compile_fog

#include "UnityCG.cginc"

		struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	float4 _StartColor;

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
	}

	fixed4 ShotgunSpreadFragment(v2f i) : SV_Target
	{
		// sample the texture
		fixed4 col = tex2D(_MainTex, i.uv);
		// apply fog
		return _StartColor;
	}
		ENDCG
	}
	}
}

//Shader "Blind Mystics/Shotgun Spread"
//{
//	Properties
//	{
//		_StartColor("Start Color", Color) = (0.0, 0.0, 1.0, 1.0)
//		_EndColor("End Color", Color) = (1.0, 0.0, 0.0, 1.0)
//		_LineColor("Line Color", Color) = (0.0, 1.0, 0.0, 1.0)
//
//    }
//    SubShader
//    {
//		Tags{ "RenderPipeline" = "HDRenderPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
//        LOD 100
//
//		//TODO: Begin by just rendering a cube at each vertex along the line.
//		//Then start playing around with particle effects.
//		//Effects to make:
//		// - Cubesplosion sweeper
//		// - Gluon gun wiggly lines
//		//
//		//Don't forget to apply a bloom effect to them.
//        Pass
//        {
//            CGPROGRAM
//            #pragma vertex ShotgunSpreadVertex
//			//#pragma geometry ShotgunSpreadGeometry
//            #pragma fragment ShotgunSpreadFragment
//
//			#include "UnityCG.cginc"
//
//		struct appdata
//	{
//		float4 vertex : POSITION;
//		float2 uv : TEXCOORD0;
//	};
//
//	struct v2g
//	{
//		float2 uv : TEXCOORD0;
//		float4 vertex : SV_POSITION;
//	};
//
//	v2g ShotgunSpreadVertex(appdata v)
//	{
//		v2g o;
//		o.vertex = v.vertex;
//		o.uv = v.uv;
//		return o;
//	}
//
//	float4 _StartColor;
//	float4 _EndColor;
//
//	float4 _LineColor;
//
//	fixed4 ShotgunSpreadFragment(v2g i) : SV_Target
//	{
//		//if (i.props.y) {
//		//return _LineColor;
//		//}
//		return fixed4(1.0, 1.0, 1.0, 1.0);
//	//return _StartColor;
//	//return lerp(_StartColor, _EndColor, i.props.x);
//	}
//
//			//#include "ShotgunSpreadVertex.hlsl"
//			//#include "ShotgunSpreadGeometry.hlsl"
//			//#include "ShotgunSpreadFragment.hlsl"
//
//            ENDCG
//        }
//    }
//}
