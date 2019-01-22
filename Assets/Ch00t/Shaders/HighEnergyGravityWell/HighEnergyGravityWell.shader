Shader "Blind Mystics/HighEnergyGravityWell"
{
    Properties
    {
		_MainCol("Main Color", Color) = (1.0, 1.0, 0.0, 1.0)
		_SecondaryCol("Secondary Color", Color) = (0.0, 0.0, 0.0, 1.0)

		_Wave("Wave", Float) = 0.2
		_Depth("Depth", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float4 _MainCol;
			float4 _SecondaryCol;

			float _Wave;
			float _Depth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex)));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float rim = 1.0 - saturate(dot(i.viewDir, i.normal));
				rim = 1.0 - min(cos(rim * 1.57079) * _Depth * (1.0 - sin(_Time.y * 1.57079) * _Wave), 1);
                fixed4 col = lerp(_MainCol, _SecondaryCol, rim);
                return col;
            }
            ENDCG
        }
    }
}
