using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class BeamTest1Handler : MonoBehaviour {

    public Renderer beamInnerRenderer;
    public Renderer beamInnerRenderer2;

    public float uvOffsetSpeed = 1.0f;
    public float uvOffsetSpeed2 = 1.0f;

    public Transform toRotate1;
    public float rotate1ZSpeed = 1f;

    public Transform toRotate2;
    public float rotate2ZSpeed = 1f;

    public Transform toRotate3;
    public float rotate3ZSpeed = 1f;

    private MaterialPropertyBlock propBlock;
    private MaterialPropertyBlock propBlock2;

    private float uvOffset = 0f;
    private float uvOffset2 = 0f;

    private void Awake() {
        propBlock = new MaterialPropertyBlock();
        propBlock2 = new MaterialPropertyBlock();
    }

    // Start is called before the first frame update
    void Start() {
        
    }

    // Update is called once per frame
    void Update() {
        uvOffset += Time.deltaTime * uvOffsetSpeed;
        uvOffset2 += Time.deltaTime * uvOffsetSpeed2;

        toRotate1.Rotate(new Vector3(0f, 0f, rotate1ZSpeed * Time.deltaTime));
        toRotate2.Rotate(new Vector3(0f, 0f, rotate2ZSpeed * Time.deltaTime));
        toRotate3.Rotate(new Vector3(0f, 0f, rotate3ZSpeed * Time.deltaTime));
    }

    private void LateUpdate() {
        if (propBlock == null || propBlock2 == null) {
            Awake();
        }
        beamInnerRenderer.GetPropertyBlock(propBlock);

        propBlock.SetFloat("Vector1_D14B30CC", uvOffset);

        beamInnerRenderer.SetPropertyBlock(propBlock);

        beamInnerRenderer2.GetPropertyBlock(propBlock2);

        propBlock2.SetFloat("Vector1_D14B30CC", uvOffset2);

        beamInnerRenderer2.SetPropertyBlock(propBlock2);
    }
}
