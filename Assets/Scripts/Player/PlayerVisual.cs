using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerVisual : MonoBehaviour
{
    // scene references
    [Header("Scene references")]
    public GameObject mesh; 
    public ParticleSystem topParticles; 
    public ParticleSystem sideParticles; 
    public MeshRenderer face; 

    public void Move(Vector3 pos) {
        topParticles.GetComponent<Renderer>().sharedMaterial.SetFloat("_PlayerBase", this.transform.position.y);
        sideParticles.GetComponent<Renderer>().sharedMaterial.SetFloat("_PlayerBase", this.transform.position.y);
        this.GetComponent<Animator>().SetBool("walking", true);
        face.gameObject.GetComponent<Animator>().SetBool("walking", true);
    }
    
    public void Idle()
    {
        this.GetComponent<Animator>().SetBool("walking", false);
        face.gameObject.GetComponent<Animator>().SetBool("walking", false);
    }

    public void SetExpression(Texture tex)
    {
        face.materials[0].SetTexture("_MainTex", tex);
    }

 }

