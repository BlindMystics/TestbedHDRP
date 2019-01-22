struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : NORMAL;
};

struct v2g
{
	float2 uv : TEXCOORD0;
	float4 vertex : SV_POSITION;
	float3 normal : NORMAL;
	float3 viewDir : TEXCOORD1;
};

sampler2D _MainTex;
float4 _MainTex_ST;

v2g UpgradeOrbVertex(appdata v)
{
	v2g o;
	o.vertex = v.vertex;
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	o.normal = UnityObjectToWorldNormal(v.normal);
	o.viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex)));
	return o;
}