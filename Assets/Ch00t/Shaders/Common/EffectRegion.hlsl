#ifndef EFFECT_REGION_HLSL
#define EFFECT_REGION_HLSL

float _EffectRegionBottom;
float _EffectRegionTop;

float EffectRegionValue(float position) {
	float effectRegionLength = _EffectRegionTop - _EffectRegionBottom;
	return (position - _EffectRegionBottom) / effectRegionLength;
}

bool WithinEffectRegion(float position) {
	return (position > _EffectRegionBottom && position < _EffectRegionTop);
}

bool AboveEffectRegion(float position) {
	return position > _EffectRegionTop;
}

bool BelowEffectRegion(float position) {
	return position < _EffectRegionBottom;
}

#endif