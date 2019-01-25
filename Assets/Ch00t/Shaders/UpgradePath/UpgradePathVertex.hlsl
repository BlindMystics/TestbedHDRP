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
	
	//For translations to work with 4D matrices, ensure you have a one in the w.
	o.cameraDirection = normalize(mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)) - v.vertex);

	return o;
}