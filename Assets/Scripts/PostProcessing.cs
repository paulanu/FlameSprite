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
    public Color color; 
    [Range(0.0f, 10.0f)]
    public float radius = 0.5f;
    [Range(0.0f, 1f)]
    public float normalThreshold = 0.5f;
    [Range(0.0f, 10.0f)]
    public float waveRange = 0.5f;
    public float waveSpeed = 1;
    public float softness = 0.5f;
 
    // private shader properties 
    private int shPropColor;
    private int shPropRadius;
    private int shPropNormalThreshold;
    private int shPropWaveRange;
    private int shPropWaveSpeed;
    private int shPropSoftness;

    private new Camera camera;
    void OnEnable () {
        camera = GetComponent<Camera>();
        camera.depthTextureMode = camera.depthTextureMode | DepthTextureMode.DepthNormals;

        shPropColor = Shader.PropertyToID("_Color");
        shPropRadius = Shader.PropertyToID("_Radius");
        shPropNormalThreshold = Shader.PropertyToID("_NormalThreshold");
        shPropWaveRange = Shader.PropertyToID("_WaveRange");
        shPropWaveSpeed = Shader.PropertyToID("_WaveSpeed");
        shPropSoftness = Shader.PropertyToID("_Softness");

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
        material.SetColor (shPropColor, color);
        material.SetFloat (shPropRadius, radius);
        material.SetFloat (shPropNormalThreshold, normalThreshold);
        material.SetFloat (shPropWaveRange, waveRange);
        material.SetFloat (shPropWaveSpeed, waveSpeed);
        material.SetFloat (shPropSoftness, softness);

        // apply pp material 
        Graphics.Blit (src, dest, material);
    }
 
}
