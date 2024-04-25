using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
#if UNITY_EDITOR
using UnityEditor;
#endif
 
[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class PostProcessing : MonoBehaviour {
 

    // public variables 
    public Material material;
    public Transform player;
    public Color color; 
    [Range(0.0f, 10.0f)]
    public float radius = 0.5f;
    public Color flickerColor; 
    [Range(0.0f, 10.0f)]
    public float flickerRadius = 0.5f;
    [Range(0.0f, 1f)]
    public float normalThreshold = 0.5f;
    [Range(0.0f, 10.0f)]
    public float flickerRange = 0.5f;
    [Range(0.0f, 10.0f)]
    public float flickerSpeed = 1;
    public float softness = 0.5f;
    public Texture noise; 
 
    // private shader properties 
    private int shPropPlayerPos;
    private int shPropColor;
    private int shPropRadius;
    private int shPropFlickerColor;
    private int shPropFlickerRadius;
    private int shPropNormalThreshold;
    private int shPropFlickerRange;
    private int shPropFlickerSpeed;
    private int shPropSoftness;
    private int shPropNoise;

    private new Camera camera;
    void OnEnable () {
        camera = GetComponent<Camera>();
        camera.depthTextureMode = camera.depthTextureMode | DepthTextureMode.DepthNormals;

        shPropPlayerPos = Shader.PropertyToID("_PlayerPos");
        shPropColor = Shader.PropertyToID("_Color");
        shPropRadius = Shader.PropertyToID("_Radius");
        shPropFlickerColor = Shader.PropertyToID("_FlickerColor");
        shPropFlickerRadius = Shader.PropertyToID("_FlickerRadius");
        shPropNormalThreshold = Shader.PropertyToID("_NormalThreshold");
        shPropFlickerRange = Shader.PropertyToID("_flickerRange");
        shPropFlickerSpeed = Shader.PropertyToID("_flickerSpeed");
        shPropSoftness = Shader.PropertyToID("_Softness");
        shPropNoise = Shader.PropertyToID("_Noise");

    }
 
    void OnRenderImage (RenderTexture src, RenderTexture dest) {    
        if (material == null) return;

        // get matrices 
        var p = GL.GetGPUProjectionMatrix (camera.projectionMatrix, false);
        p[2, 3] = p[3, 2] = 0.0f;
        p[3, 3] = 1.0f;
        var clipToWorld = Matrix4x4.Inverse (p * camera.worldToCameraMatrix) * Matrix4x4.TRS (new Vector3 (0, 0, -p[2, 2]), Quaternion.identity, Vector3.one);
        material.SetMatrix ("_ClipToWorld", clipToWorld);

        Matrix4x4 viewToWorld = camera.cameraToWorldMatrix;
        material.SetMatrix("_viewToWorld", viewToWorld);

        // apply shader customization  
        material.SetVector (shPropPlayerPos, player.position);
        material.SetColor (shPropColor, color);
        material.SetFloat (shPropRadius, radius);
        material.SetColor (shPropFlickerColor, flickerColor);
        material.SetFloat (shPropFlickerRadius, flickerRadius);
        material.SetFloat (shPropNormalThreshold, normalThreshold);
        material.SetFloat (shPropFlickerRange, flickerRange);
        material.SetFloat (shPropFlickerSpeed, flickerSpeed);
        material.SetFloat (shPropSoftness, softness);
        material.SetTexture (shPropNoise, noise);

        // apply post processing material 
        Graphics.Blit (src, dest, material);
    }
 
}
