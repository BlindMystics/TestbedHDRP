using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.VFX;

public class LaserBeam : MonoBehaviour {

    public float lifetime = 10.0f;
    public float durationOfCollisionEffect = 1.0f;

    private float elapsedTime = 0.0f;

    public VisualEffect visualEffect;
    public GameObject beamRenderer;

    private enum CurrentState {
        HIDDEN,
        FLYING,
        DESTROYING
    }

    private CurrentState currentState = CurrentState.FLYING;

    // Start is called before the first frame update
    void Start() {
        elapsedTime = 0.0f;
    }

    // Update is called once per frame
    void Update() {

        switch (currentState) {
            case CurrentState.DESTROYING:
                HandleStateDestroying();
                break;
        }
    }

    private void HandleStateDestroying() {
        //
    }

    private int _wallLayerId = -1;

    private int WallLayerId {
        get {
            if (_wallLayerId == -1) {
                _wallLayerId = LayerMask.NameToLayer("Walls");
            }
            return _wallLayerId;
        }
    }

    private void OnTriggerEnter(Collider other) {

        if (WallLayerId == other.gameObject.layer) {
            //TODO - we've hit a wall...

            visualEffect.SendEvent("OnHit");
            currentState = CurrentState.DESTROYING;
            //Set it to destroy / recycle when the collision animation has played.
            elapsedTime = lifetime - durationOfCollisionEffect;
            beamRenderer.SetActive(false);
            Rigidbody rigidBody = GetComponent<Rigidbody>();
            rigidBody.constraints = RigidbodyConstraints.FreezeAll;

        }

    }

    private void FixedUpdate() {

        elapsedTime += Time.deltaTime;
        if (elapsedTime > lifetime) {
            Destroy(this.gameObject);
            return;
        }

    }

    public void SetColours(Color beamColour, Gradient beamHitGradient) {
        //TODO ...
        /*
        MaterialPropertyBlock materialPropertyBlock = new MaterialPropertyBlock();
        beamRenderer.GetPropertyBlock(materialPropertyBlock);
        materialPropertyBlock.SetColor("_ShotgunBeamColour_A", beamColour);
        beamRenderer.SetPropertyBlock(materialPropertyBlock);

        visualEffect.SetGradient("Colour Gradient", beamHitGradient);
        */
    }

}
