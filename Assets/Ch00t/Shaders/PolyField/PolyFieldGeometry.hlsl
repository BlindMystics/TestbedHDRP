struct g2f
{
	float4 vertex : SV_POSITION;
	float4 props : TEX_COORD0;
};

float _QuadSize;
float _LineWidth;

[maxvertexcount(3)]
void PolyFieldGeometry(triangle v2g IN[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> tristream) {
	g2f o;

	//The original triangle

	o.props = float4(0.0, 0.0, 0.0, 0.0);

	for (uint i = 0; i < 3; i++) {
		o.vertex = UnityObjectToClipPos(IN[i].vertex);
		tristream.Append(o);
	}

	tristream.RestartStrip();
}

[maxvertexcount(12)]
void PolyFieldLineGeometry(triangle v2g IN[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> tristream) {
	g2f o;
	o.props = float4(0.0, 1.0, 0.0, 0.0);

	//Generate the quad for the lines

	for (uint i = 0; i < 3; i++) {
		uint p0 = i;
		uint p1 = (i + 1) % 3;

		float4 lineStart = IN[p0].vertex;
		float4 lineEnd = IN[p1].vertex;

		float3 forward = normalize(lineEnd - lineStart);
		float3 toCamera = IN[p0].cameraDirection;
		float3 up = normalize(cross(forward, toCamera));

		float hlw = _LineWidth / 2.0;

		float4 q0 = UnityObjectToClipPos(lineStart + up * -hlw);
		float4 q1 = UnityObjectToClipPos(lineStart + up * hlw);
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
	}
}

[maxvertexcount(12)]
void PolyFieldQuadGeometry(triangle v2g IN[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> tristream) {
	g2f o;

	//Generate the cube for the first vertex of the line
	o.props = float4(0.0, 0.0, 1.0, 0.0);

	float height = _QuadSize / 2.0;
	float width = height * (_ScreenParams.y / _ScreenParams.x);

	for (uint i = 0; i < 3; i++) {
		float4 position = UnityObjectToClipPos(IN[i].vertex);

		float4 q0 = position + float4(-width, -height, 0, 0);
		float4 q1 = position + float4(-width, height, 0, 0);
		float4 q2 = position + float4(width, -height, 0, 0);
		float4 q3 = position + float4(width, height, 0, 0);

		o.vertex = q0;
		tristream.Append(o);
		o.vertex = q2;
		tristream.Append(o);
		o.vertex = q1;
		tristream.Append(o);
		o.vertex = q3;
		tristream.Append(o);

		tristream.RestartStrip();
	}
}