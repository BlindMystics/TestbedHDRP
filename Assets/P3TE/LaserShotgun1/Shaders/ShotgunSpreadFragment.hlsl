float4 _StartColor;
float4 _EndColor;

float4 _LineColor;

fixed4 ShotgunSpreadFragment(v2g i) : SV_Target
{
	/*
	if (i.props.y) {
		return _LineColor;
	}
	*/
	return fixed4(1.0, 1.0, 1.0, 1.0);
	//return _StartColor;
	//return lerp(_StartColor, _EndColor, i.props.x);
}