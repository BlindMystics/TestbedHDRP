struct appdata
{
	float4 vertex : POSITION;
};

struct v2g
{
	float4 vertex : SV_POSITION;
	float4 cameraDirection : TEXCOORD0;
};

v2g UpgradePathVertex(appdata v)
{
	v2g o;
	o.vertex = v.vertex;
	o.cameraDirection = normalize(mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex);

	return o;
}