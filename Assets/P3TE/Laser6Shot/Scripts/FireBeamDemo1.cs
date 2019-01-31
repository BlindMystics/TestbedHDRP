using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireBeamDemo1 : MonoBehaviour {

    public LaserBeam laserBeamPrefab;
    public float initialVelocity = 15.0f;

    private void Update() {
        if (Input.GetKeyDown(KeyCode.Space)) {
            LaserBeam laserBeam = Instantiate<LaserBeam>(laserBeamPrefab);
            Rigidbody rigidbody = laserBeam.GetComponent<Rigidbody>();

            laserBeam.transform.position = transform.position;
            laserBeam.transform.rotation = transform.rotation;

            Vector3 velocity = transform.forward * initialVelocity;
            rigidbody.velocity = velocity;
        }
    }


}
