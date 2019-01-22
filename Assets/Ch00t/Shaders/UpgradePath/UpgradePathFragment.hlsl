float4 _StartColor;
float4 _EndColor;

float4 _LineColor;

fixed4 UpgradePathFragment(g2f i) : SV_Target
{
	if (i.props.x == 1.0) {
		return _LineColor;
	}

	return lerp(_StartColor, _EndColor, i.props.x);
}