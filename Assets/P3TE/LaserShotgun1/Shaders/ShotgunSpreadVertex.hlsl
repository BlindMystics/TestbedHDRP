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

v2g ShotgunSpreadVertex(appdata v)
{
	v2g o;
	o.vertex = v.vertex;
	o.uv = v.uv;
	return o;
}