using System;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    // events 
    public static event Action ToggleEscapeMenu;
    public PlayerVisual playerVisual;

    // components 
    private CharacterController cc;
    public Transform cam; 

    // movement stuff
    private readonly float speed = 5f;

    public float turnSmoothTime = 0.1f; 

    private float turnSmoothVelocity; 

    // Start is called before the first frame update
    void Start()
    {
        cc = GetComponent<CharacterController>();
    }

    // Update is called once per frame
    void Update()
    {
        var inputVector = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));


        if (inputVector.magnitude > 0)
        {

            Vector3 direction = new Vector3(inputVector.y, 0f, -inputVector.x).normalized;
            float targetAngle = Mathf.Atan2(direction.x, direction.z) * Mathf.Rad2Deg + cam.eulerAngles.y;
            float angle = Mathf.SmoothDampAngle(transform.eulerAngles.y, targetAngle, ref turnSmoothVelocity, turnSmoothTime); 
            transform.rotation = Quaternion.Euler(0f, angle, 0f);

            // call static method for visual updates
            playerVisual.Move(this.transform.position); 

            Vector3 moveDir = Quaternion.Euler(0f, targetAngle, 0f) * Vector3.forward;

            cc.SimpleMove(moveDir * speed);
        }
        else if (Input.GetButtonDown("Escape")) 
        {
            ToggleEscapeMenu?.Invoke();
        }
        else 
        {
            playerVisual.Idle();
        }

    }
}
