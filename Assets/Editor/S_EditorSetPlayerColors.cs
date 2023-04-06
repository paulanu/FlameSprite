using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SetPlayerColors))]
public class EditorSetPlayerColors : Editor {
   
   Color baseColor;
   Color gradientColor;
   float gradientHeight;
   float emission; 

    public override void OnInspectorGUI() {
        SetPlayerColors selected = target as SetPlayerColors; 

        baseColor = EditorGUILayout.ColorField("Base Color", selected.baseColor);
        gradientColor = EditorGUILayout.ColorField("Gradient Color", selected.gradientColor);
        gradientHeight = EditorGUILayout.Slider("Gradient Height", selected.gradientHeight, 0, 1);
        emission = EditorGUILayout.Slider("Emission", selected.emission, 1, 5);

        if (selected != null)
        {
            selected.SetPlayerBaseColor(baseColor);
            selected.SetPlayerGradientColor(gradientColor);
            selected.SetPlayerGradientHeight(gradientHeight);
            selected.SetPlayerEmission(emission);

        }
        
    }
}

