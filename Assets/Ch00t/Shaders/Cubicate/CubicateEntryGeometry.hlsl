#include "Assets/CustomShader/Common/Shader/Random.hlsl"

//TODO: The purpose of this shader is to have the cubes come up from below and reach their target position.
//Then a second sweep converts the cubes into the actual model.

struct g2f
{
	float2 uv : TEXCOORD0;
	float4 vertex : SV_POSITION;
	float4 props : TEXCOORD1;
};

float _SideLength;

float _EntryZoomLength;
float _EntryRegionSize;
float _EntryCubeSize;

float _EntryValue;
float _DetailValue;

[maxvertexcount(36)]
void CubicateEntryGeometry(triangle v2g IN[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> tristream)
{
	g2f o;
	o.uv = IN[0].uv;

	float4 facePosition = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3.0;

	float effectRegionValue = EffectRegionValue(facePosition.y);

	if (BelowEffectRegion(facePosition.y) || AboveEffectRegion(facePosition.y) || effectRegionValue < _DetailValue) {
		for (int i = 0; i < 3; i++) {
			o.uv = IN[i].uv;
			o.vertex = UnityObjectToClipPos(IN[i].vertex);
			o.props = float4(0, 0, 0, 0);

			tristream.Append(o);
		}

		return;
	}

	//Verify this works by only colouring the result over the zone which is affected by the cube entrance.

	if (effectRegionValue > _EntryValue) {
		return;
	}

	float entryRegionValue = min(max((_EntryValue - effectRegionValue) / _EntryRegionSize, 0.0), 1.0);

	if (entryRegionValue == 0.0) {
		return;
	}

	float sideLength = lerp(_EntryCubeSize, _SideLength, entryRegionValue);

	float hsl = sideLength / 2.0;

	float4 cubePosition = facePosition;
	cubePosition.y -= _EntryZoomLength * (1 - entryRegionValue);

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
		o.props = float4(entryRegionValue, effectRegionValue, 0, 0);
		tristream.Append(o);

		if (stripCounter++ == 2) {
			stripCounter = 0;
			tristream.RestartStrip();
		}
	}
}