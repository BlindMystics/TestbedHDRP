#ifndef EFFECT_REGION_HLSL
#define EFFECT_REGION_HLSL

float _EffectRegionBottom;
float _EffectRegionTop;

float EffectRegionValue(float3 position) {
	float effectRegionLength = _EffectRegionTop - _EffectRegionBottom;
	return (position.y - _EffectRegionBottom) / effectRegionLength;
}

bool WithinEffectRegion(float3 position) {
	return (position.y > _EffectRegionBottom && position.y < _EffectRegionTop);
}

bool AboveEffectRegion(float3 position) {
	return position.y > _EffectRegionTop;
}

bool BelowEffectRegion(float3 position) {
	return position.y < _EffectRegionBottom;
}

#endif