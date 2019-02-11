float4 _QuadColor;
float4 _LineColor;
float4 _FaceColor;

fixed4 PolyFieldFragment(g2f i) : SV_Target
{
	if (i.props.y) {
		return _LineColor;
	}

	if (i.props.z) {
		return _QuadColor;
	}

	return _FaceColor;
}