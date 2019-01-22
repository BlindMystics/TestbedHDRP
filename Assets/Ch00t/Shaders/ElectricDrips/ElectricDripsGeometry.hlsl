#include "Assets/CustomShader/Common/Shader/Random.hlsl"

struct g2f
{
	float2 uv : TEXCOORD0;
	float4 vertex : SV_POSITION;
	float4 props : TEXCOORD1;
};

float _SideLength;
float _DripLength;

float _AnimationSpeed;

[maxvertexcount(39)]
void ElectricDripsGeometry(triangle v2g IN[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> tristream)
{
	g2f o;
	o.uv = IN[0].uv;

	float3 facePosition = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3.0;

	for (int i = 0; i < 3; i++) {
		o.uv = IN[i].uv;
		o.vertex = UnityObjectToClipPos(IN[i].vertex);
		o.props = float4(0, 0, 0, 0);

		tristream.Append(o);
	}

	tristream.RestartStrip();

	if (WithinEffectRegion(facePosition.y) && Random(pid) < 0.3) {
		float effectRegionValue = EffectRegionValue(facePosition.y);

		float hsl = (_SideLength) / 2.0;

		float4 cubePosition = float4(facePosition, 0);

		float cycleValue = Random(pid + effectRegionValue * 65535) + _Time.x * _AnimationSpeed;

		if (cycleValue > 1.0) {
			cycleValue = cycleValue % 1.0;
		}

		cubePosition.y -= cycleValue * _DripLength;

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
			o.props = float4(1, 0, 0, 0);
			tristream.Append(o);

			if (stripCounter++ == 2) {
				stripCounter = 0;
				tristream.RestartStrip();
			}
		}
	}
}