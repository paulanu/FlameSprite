using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SetPlayerColors : MonoBehaviour
{
    public Color baseColor; 
    public Color gradientColor; 
    public float gradientHeight; 
    public float emission;  

    private void Awake() {
        Shader.SetGlobalColor("_BaseColor", baseColor);
        Shader.SetGlobalColor("_GradientColor", gradientColor);
        Shader.SetGlobalFloat("_GradientHeight", gradientHeight);
        Shader.SetGlobalFloat("_Emission", emission);
    }

    public void SetPlayerBaseColor(Color baseColor) // turn into properties? 
    {
        this.baseColor = baseColor;
        Shader.SetGlobalColor("_BaseColor", this.baseColor);
        
    }

    public void SetPlayerGradientColor(Color gradientColor)
    {
        this.gradientColor = gradientColor;
        Shader.SetGlobalColor("_GradientColor", this.gradientColor);   
    }

    public void SetPlayerGradientHeight(float gradientHeight)
    {
        this.gradientHeight = gradientHeight;
        Shader.SetGlobalFloat("_GradientHeight", this.gradientHeight);
    }

    public void SetPlayerEmission(float emission)
    {
        this.emission = emission; 
        Shader.SetGlobalFloat("_Emission", this.emission);
    }
}
