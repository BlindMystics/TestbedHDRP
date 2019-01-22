float4 _Color;

fixed4 ElectricDripsFragment(g2f i) : SV_Target
{
	return tex2D(_MainTex, i.uv) * _Color;
}