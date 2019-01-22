float4 _InnerColor;
float4 _OuterColor;

float _Depth;
float _PulseWidth;

fixed4 UpgradeOrbFragment(g2f i) : SV_Target
{
	float rim = 1.0 - saturate(dot(i.viewDir, i.normal));
	rim = 1.0 - min(cos(rim * 1.57079) * _Depth * (1.0 - sin(_Time.y * 1.57079) * _PulseWidth), 1);
	return lerp(_InnerColor, _OuterColor, rim);
}