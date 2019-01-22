using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NormalizedTransformTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

        //They pretty much are, sometimes it's 0.9999999 / 0.9999998
        //So, close enough...
        Debug.Log("||up|| = " + transform.up.magnitude);
        Debug.Log("||forward|| = " + transform.forward.magnitude);
        Debug.Log("||right|| = " + transform.right.magnitude);

    }
}
