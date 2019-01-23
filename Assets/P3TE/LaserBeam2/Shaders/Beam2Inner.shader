Shader "Unlit/Beam2Inner"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		[PerRenderData][HDR]_InnerColour("Core Inner Colour", Color) = (1,1,1,1)
		[PerRenderData]_OuterColour("Core Outer Colour", Color) = (0,1,1,1)

		_InnerOuterCutoff("Inner to Outer Cutoff", Float) = 0.4
		[PerRenderData]_TexUVYOffset("Main Text UV Offset", Float) = 0.0
		_InnerOuterTextureStrength("Inner Outer Tex Stength", Float) = 0.5
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
		Tags{ "RenderPipeline" = "HDRenderPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float4 _InnerColour;
			float4 _OuterColour;

			float _InnerOuterCutoff;

			float _TexUVYOffset;
			float _InnerOuterTextureStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				float2 vertexUV = v.uv;
				vertexUV.y += _TexUVYOffset;
                o.uv = TRANSFORM_TEX(vertexUV, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex)));
                return o;
            }

				fixed4 frag (v2f i) : SV_Target
			{

				fixed4 col;
                // sample the texture

                fixed4 texCol = tex2D(_MainTex, i.uv);
				
				//TODO - Move the angle between to the vertex shader.
				float2 viewDirXY = normalize(i.viewDir.xy);
				float2 normalXY = normalize(i.normal.xy);
				float dotProduct = dot(viewDirXY, normalXY);
				float angleBetween = acos(dotProduct);
				//End TODO.
				float cutoff = _InnerOuterCutoff * 1.570796;
				float multiplier = texCol.x - 0.5;
				multiplier *= _InnerOuterTextureStrength;
				multiplier += 0.5;
				multiplier *= 2.0;
				cutoff *= multiplier;
				//angleBetween += texCol.x * 2;
				if (angleBetween > cutoff) {
					col = _OuterColour;
					//discard;
				}
				else {
					col = _InnerColour;
				}


                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
			}
            ENDCG
        }
    }
}
