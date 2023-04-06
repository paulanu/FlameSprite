using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    private Transform cam;

    // Start is called before the first frame update
    void Start()
    {
        cam = this.GetComponent<Transform>();
    }

    // Update is called once per frame
    void Update()
    {
        float x = 5 * Input.GetAxis ("Mouse X");
        float y = 5 * -Input.GetAxis ("Mouse Y");
        this.transform.Rotate (0, x, 0);

    }
}
