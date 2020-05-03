using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class SnowFrameBufferProcessor : MonoBehaviour
{
    [SerializeField] private int heightMapSize;
    [SerializeField] private MeshRenderer targetRenderer;

    private Camera _camera;
    private RenderTexture _renderTexture;

    void Awake(){
        _camera = GetComponent<Camera>();
        _camera.depth=-1; //make sure camera depth is less than main camera depth.
        _renderTexture = new RenderTexture(heightMapSize,heightMapSize,16,RenderTextureFormat.RHalf);
        _renderTexture.filterMode = FilterMode.Trilinear;
        _renderTexture.Create();
        _camera.targetTexture = _renderTexture;
        _camera.clearFlags = CameraClearFlags.Nothing;

        targetRenderer.material.SetTexture("_HeightMap",_renderTexture);
    }
}
