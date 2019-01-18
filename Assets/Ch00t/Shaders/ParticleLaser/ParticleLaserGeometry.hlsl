#include "Assets/CustomShader/Common/Shader/Random.hlsl"


struct g2f
{
	float4 vertex : SV_POSITION;
	float4 props : TEX_COORD0;
};

float _Width;
float _TotalBeamLength;
float _PulseWidth;
float _AnimationTime;
float _LaserEnd;

[maxvertexcount(36)]
void ParticleLaserGeometry(point v2g IN[1], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> tristream) {
	g2f o;

	o.props = float4(0.0, 0.0, 0.0, 0.0);

	float4 position = IN[0].vertex;

	float normalizedBeamPosition = position.z / _TotalBeamLength;

	if (normalizedBeamPosition > _AnimationTime || normalizedBeamPosition < _LaserEnd) {
		return;
	}

	float timeSinceSpawn = _AnimationTime - normalizedBeamPosition;

	if (timeSinceSpawn > 1) {
		return;
	}

	float exitRotation = Hash(pid);

	float effectValue = 1 - cos(timeSinceSpawn * 1.57079);

	o.props.x = effectValue;

	float4 positionUpdate = float4(sin(exitRotation), cos(exitRotation), 0, 0)
		* _PulseWidth * effectValue;

	position += positionUpdate;

	float hsl = _Width * (1 - effectValue) / 2.0;

	float4 v0 = UnityObjectToClipPos(position + float4(-hsl, hsl, -hsl, 0));
	float4 v1 = UnityObjectToClipPos(position + float4(-hsl, hsl, hsl, 0));
	float4 v2 = UnityObjectToClipPos(position + float4(hsl, hsl, -hsl, 0));
	float4 v3 = UnityObjectToClipPos(position + float4(hsl, hsl, hsl, 0));
	float4 v4 = UnityObjectToClipPos(position + float4(-hsl, -hsl, -hsl, 0));
	float4 v5 = UnityObjectToClipPos(position + float4(-hsl, -hsl, hsl, 0));
	float4 v6 = UnityObjectToClipPos(position + float4(hsl, -hsl, -hsl, 0));
	float4 v7 = UnityObjectToClipPos(position + float4(hsl, -hsl, hsl, 0));

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