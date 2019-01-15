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

sampler2D _MainTex;
float4 _MainTex_ST;

v2g CubicateVertex(appdata v)
{
	v2g o;
	o.vertex = v.vertex;
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	return o;
}