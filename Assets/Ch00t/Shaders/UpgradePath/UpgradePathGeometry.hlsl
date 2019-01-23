#include "Assets/CustomShader/Common/Shader/Random.hlsl"


struct g2f
{
	float4 vertex : SV_POSITION;
	float4 props : TEX_COORD0;
};

float _CubeWidth;
float _LineWidth;

float _TotalLineLength;
float _AnimationTime;
float _LineEnd;

[maxvertexcount(42)]
void UpgradePathGeometry(line v2g IN[2], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> tristream) {
	g2f o;

	o.props = float4(0.0, 1.0, 0.0, 0.0);

	float4 position = IN[0].vertex;

	//Generate the quad for the line.
	float4 lineEnd = IN[1].vertex;

	float3 forward = normalize(lineEnd - position);
	float3 toCamera = IN[0].cameraDirection;
	float3 up = normalize(cross(forward, toCamera));

	float hlw = _LineWidth / 2.0;

	float4 q0 = UnityObjectToClipPos(position + up * -hlw);
	float4 q1 = UnityObjectToClipPos(position + up * hlw);
	float4 q2 = UnityObjectToClipPos(lineEnd + up * -hlw);
	float4 q3 = UnityObjectToClipPos(lineEnd + up * hlw);

	o.vertex = q0;
	tristream.Append(o);
	o.vertex = q1;
	tristream.Append(o);
	o.vertex = q2;
	tristream.Append(o);
	o.vertex = q3;
	tristream.Append(o);

	tristream.RestartStrip();

	//Generate the cube for the first vertex of the line.

	o.props = float4(0.0, 0.0, 0.0, 0.0);

	float normalizedLinePosition = position.z / _TotalLineLength;

	o.props.x = normalizedLinePosition;

	if (normalizedLinePosition > _AnimationTime || normalizedLinePosition < _LineEnd) {
		return;
	}

	float hsl = _CubeWidth / 2.0;

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
	tristream.RestartStrip();
}