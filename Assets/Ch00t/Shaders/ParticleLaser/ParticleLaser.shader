Shader "Blind Mystics/Particle Laser"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

		//TODO: Begin by just rendering a cube at each vertex along the line.
		//Then start playing around with particle effects.
		//Effects to make:
		// - Cubesplosion sweeper
		// - Gluon gun wiggly lines
		//
		//Don't forget to apply a bloom effect to them.
        Pass
        {
            CGPROGRAM
            #pragma vertex ParticleLaserVertex
			#pragma geometry ParticleLaserGeometry
            #pragma fragment ParticleLaserFragment

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

			struct g2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2g ParticleLaserVertex(appdata v)
            {
                v2g o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			[maxvertexcount(36)]
			void ParticleLaserGeometry(point v2g IN[1], inout TriangleStream<g2f> tristream) {
				g2f o;

				o.vertex = IN[0].vertex;
				o.uv = IN[0].uv;

				tristream.Append(o);
			}

            fixed4 ParticleLaserFragment(g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
