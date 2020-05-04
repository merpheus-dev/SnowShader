using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class SnowFrameBufferProcessor : MonoBehaviour
{
    [SerializeField] private int heightMapSize;
    [SerializeField] private MeshRenderer targetRenderer;
    [SerializeField] private Shader blurShader;
    private Camera _camera;
    private RenderTexture _renderTexture;
    private RenderTexture temporaryRT1;
    private RenderTexture temporaryRT2;
    private Material blurMaterial;

    void Awake()
    {
        blurMaterial = new Material(blurShader);
        _camera = GetComponent<Camera>();
        _camera.depth = -1; //make sure camera depth is less than main camera depth.
        _renderTexture = new RenderTexture(heightMapSize, heightMapSize, 16, RenderTextureFormat.RHalf);
        _renderTexture.filterMode = FilterMode.Trilinear;
        _renderTexture.Create();
        _camera.targetTexture = _renderTexture;

        targetRenderer.material.SetTexture("_HeightMap", _renderTexture);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        temporaryRT1 = RenderTexture.GetTemporary(src.width, src.height, 16, src.format);
        temporaryRT2 = RenderTexture.GetTemporary(src.width, src.height, 16, src.format);
        Graphics.Blit(src, temporaryRT1);
        for (var i = 0; i < 4; i++)
        {
            Graphics.Blit(temporaryRT1, temporaryRT2, blurMaterial, 1);
            Graphics.Blit(temporaryRT2, temporaryRT1, blurMaterial, 2);
            Graphics.Blit(temporaryRT1, dest);
        }
        RenderTexture.ReleaseTemporary(temporaryRT1);
        RenderTexture.ReleaseTemporary(temporaryRT2);
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 200, 200), _renderTexture);
        
    }
}