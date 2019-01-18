float4 _InnerColor;
float4 _OuterColor;

fixed4 ParticleLaserFragment(g2f i) : SV_Target
{
	return _InnerColor * (1 - i.props.x) + _OuterColor * i.props.x;
}