struct appdata
{
	float4 vertex : POSITION;
};

struct v2g
{
	float4 vertex : SV_POSITION;
};

v2g UpgradePathVertex(appdata v)
{
	v2g o;
	o.vertex = v.vertex;
	return o;
}