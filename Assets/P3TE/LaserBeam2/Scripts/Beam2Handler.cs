using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Beam2Handler : MonoBehaviour
{

    public Renderer beamInnerRenderer;

    public float uvOffsetSpeed = 1.0f;

    private MaterialPropertyBlock propBlock;

    private float uvOffset = 0f;

    private void Awake() {
        propBlock = new MaterialPropertyBlock();
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update() {
        uvOffset += Time.deltaTime * uvOffsetSpeed;
    }

    private void LateUpdate() {
        if (propBlock == null) {
            Awake();
        }
        beamInnerRenderer.GetPropertyBlock(propBlock);

        propBlock.SetFloat("_TexUVYOffset", uvOffset);

        beamInnerRenderer.SetPropertyBlock(propBlock);

    }
}
