using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Beam2Handler : MonoBehaviour
{

    public Renderer beamInnerRenderer;

    public float uvOffsetSpeed = 1.0f;

    public LineRenderer lineRenderer1;
    public LineRenderer lineRenderer2;

    public float lineLength = 10.0f;
    public int linePoints = 100;

    public float revolutionsAlongLength = 2.0f;

    public float spiralRadius = 0.5f;
    public float spiralVelocity = 1.0f;

    public float beamRotateSpeedZ = 90.0f;

    private MaterialPropertyBlock propBlock;

    private float uvOffset = 0f;

    private float spiralOffsetPercentage;

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
        spiralOffsetPercentage += Time.deltaTime * (spiralVelocity / lineLength);
        spiralOffsetPercentage = spiralOffsetPercentage % 1.0f;

        lineRenderer1.transform.Rotate(new Vector3(0f, 0f, beamRotateSpeedZ * Time.deltaTime));
        lineRenderer2.transform.Rotate(new Vector3(0f, 0f, beamRotateSpeedZ * Time.deltaTime));

        UpdateLineRenderers();
    }

    private void UpdateLineRenderers() {

        Vector3[] linePositions = new Vector3[linePoints];
        Vector3[] linePositions2 = new Vector3[linePoints];

        for (int i = 0; i < linePoints; i++) {
            Vector3 newPosition = new Vector3();
            Vector3 newPosition2 = new Vector3();
            float percentageAlongLine = (((float) i) / (linePoints - 1));

            newPosition.z = percentageAlongLine * lineLength;
            newPosition2.z = percentageAlongLine * lineLength;

            float rotationOffset = (percentageAlongLine + spiralOffsetPercentage) * revolutionsAlongLength * Mathf.PI * 2.0f;

            newPosition.x = spiralRadius * Mathf.Cos(rotationOffset);
            newPosition.y = spiralRadius * Mathf.Sin(rotationOffset);
            newPosition2.x = spiralRadius * Mathf.Cos(-rotationOffset);
            newPosition2.y = spiralRadius * Mathf.Sin(-rotationOffset);
            linePositions[i] = newPosition;
            linePositions2[i] = newPosition2;
        }

        lineRenderer1.positionCount = linePoints;
        lineRenderer1.SetPositions(linePositions);

        lineRenderer2.positionCount = linePoints;
        lineRenderer2.SetPositions(linePositions2);
        
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
