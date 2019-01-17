Shader "Hidden/Ch00t/PostProcessing/Invert"
{
	HLSLINCLUDE

	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/Colors.hlsl"

	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);

	half4 InvertFrag(VaryingsDefault i) : SV_Target
	{
		half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		// just invert the colors
		col.rgb = 1 - col.rgb;
		return col;
	}

	ENDHLSL

    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
			HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment InvertFrag
			ENDHLSL
        }
    }
}
