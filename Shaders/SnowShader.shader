Shader "Custom/SnowShader"
{
    Properties
    {
        _MainTexture("Albedo",2D) = "white" {}
        _Normal("Normal",2D) = "bump"{}
        _Gloss("Gloss",float) = .1
        _Emission("Emission",Range(0,1))=.1

        _FrameBufferBlurIterationCount("Blur Iteration Count",float) =10 

        _TrailTexture("Trail Texture",2D) = "white"{}
        _TrailColor("Trail Tint", Color) = (1,1,1,1)
        _TrailNormal("Trail Normal",2D) = "bump"{}
        _TrailBlendMaxBlend("Max Blend Ratio",Range(0,1.0)) = .5
        _TrailGloss("Trail Gloss",float) = .5

        _Noise("Noise",2D) = "black" {}
        _HeightMap("HeightMap",2D) = "black"{}
        _HeightMapMultiplier("Height Multiplier",float) = 0.5
        _BlurSize("Blur Size",float) = 0.01
        
    }
    SubShader
    {
      Tags{"RenderType"= "Opaque"}
      
      CGPROGRAM
      #pragma surface surface_main Standard vertex:vertex_main fullforwardshadows
      #pragma target 3.0

      sampler2D _MainTexture;
      sampler2D _Normal;
      float _Gloss;
      float _Emission;
      float _FrameBufferBlurIterationCount;

      sampler2D _TrailTexture;
      float3 _TrailColor;
      sampler2D _TrailNormal;
      float _TrailBlendMaxBlend;
      float _TrailGloss;

      sampler2D _Noise;
      sampler2D _HeightMap;
      float _HeightMapMultiplier;
      float _BlurSize;

    //Has to be named as Input for a stupid reason
      struct Input{
        float2 uv_MainTexture;
        float2 uv_TrailTexture;
        float2 uv_Noise;
        float3 worldNormal; INTERNAL_DATA 
        float3 viewDir;
      };

      void vertex_main(inout appdata_full v){
        float mean_height;
        for(int i=-1;i<=1;i++){
            for(int j=-1;j<=1;j++){
                mean_height+= tex2Dlod(_HeightMap,float4(v.texcoord.x+i*_BlurSize,v.texcoord.y+j*_BlurSize,0,0)).r;
            }
        }
        v.vertex.y -= saturate(mean_height/9.0) *_HeightMapMultiplier;
      }

      void surface_main(Input input,inout SurfaceOutputStandard output){
          float4 color= tex2D(_MainTexture,input.uv_MainTexture);

          float3 noise_texture = normalize(normalize(tex2D(_Noise,input.uv_Noise).xyz-.5) + input.worldNormal);
          float3 viewDirOffset = normalize(1-input.viewDir);
          float sparkle = dot(viewDirOffset,noise_texture);
          sparkle = pow(saturate(sparkle),.5);
          color+=float4(sparkle,sparkle,sparkle,0);

          float3 normal = UnpackNormal(tex2D(_Normal,input.uv_MainTexture));

          float4 trail_color = tex2D(_TrailTexture,input.uv_TrailTexture);
          float3 trail_normal = UnpackNormal(tex2D(_TrailNormal,input.uv_TrailTexture));

          float4 height_map= tex2D(_HeightMap,input.uv_MainTexture);
          float clamped_trail_blend = clamp(height_map.r,0,_TrailBlendMaxBlend);
          float3 trail_mixed = lerp(color.rgb,trail_color.rgb*_TrailColor,clamped_trail_blend);
          float3 trail_nrm_mixed = lerp(normal,trail_normal,clamped_trail_blend);

          output.Albedo = trail_mixed;
          output.Normal = trail_nrm_mixed;
          output.Smoothness = lerp(_Gloss,_TrailGloss,clamped_trail_blend);
          output.Metallic = 0;
          output.Emission = saturate(dot(trail_mixed,float3(1,1,1)))*_Emission;
      }
      ENDCG
    }
    Fallback "Diffuse"
}
