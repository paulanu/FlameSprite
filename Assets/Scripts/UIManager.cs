using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour
{

    // UI canvases
    public GameObject escapeMenu;

    private void Awake() {
        PlayerController.ToggleEscapeMenu += ToggleEscapeMenu;
    }

    public void ExitGame() {
        Application.Quit();
    }

    public void ToggleEscapeMenu() 
    {
        escapeMenu.SetActive(!escapeMenu.activeInHierarchy);
    }  
}
