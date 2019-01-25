using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ShotgunFocusLineRendererTest1 : MonoBehaviour {

    public LineRenderer outerCircleRenderer;
    public List<LineRenderer> circleRenderers;
    public List<LineRenderer> lineRenderers;

    public int circlePointCount = 32;

    public float coneLength = 4.0f;
    public float coneAngleDeg = 20.0f;

    public float strobeSpeed = 1f;
    public float lineSpinSpeed = 90f;

    public Color lineColour;
    private Color lineColourCache;

    private float strobeOffset = 0f;
    private float lineRotationOffset = 0f;

    // Start is called before the first frame update
    void Start() {
        
    }

    // Update is called once per frame
    void Update() {

        strobeOffset += Time.deltaTime * strobeSpeed;
        strobeOffset = strobeOffset % 1.0f;

        lineRotationOffset += Time.deltaTime * lineSpinSpeed;
        lineRotationOffset = lineRotationOffset % 360.0f;

        //Cone parameters:

        float endRadius = coneLength * Mathf.Tan(Mathf.Deg2Rad * coneAngleDeg);


        UpdateCircle(outerCircleRenderer, endRadius, coneLength);

        for (int i = 0; i < circleRenderers.Count; i++) {

            float distanceOffset = i + 1.0f + strobeOffset;
            float percentDownCone = distanceOffset / ((float) circleRenderers.Count);
            percentDownCone = percentDownCone % 1.0f;
            float distanceDownCone = percentDownCone * coneLength;
            float currentCircleRadius = distanceDownCone * Mathf.Tan(Mathf.Deg2Rad * coneAngleDeg);
            UpdateCircle(circleRenderers[i], currentCircleRadius, distanceDownCone);
        }

        
        for (int i = 0; i < lineRenderers.Count; i++) {
            float percentageOfLines = i / ((float) lineRenderers.Count);
            float angleOffset = percentageOfLines * 2.0f * Mathf.PI;
            //if (i % 2 == 0) {
            //    angleOffset += Mathf.Deg2Rad * lineRotationOffset;
            //} else {
            //    angleOffset -= Mathf.Deg2Rad * lineRotationOffset;
            //}
            angleOffset += Mathf.Deg2Rad * lineRotationOffset;
            UpdateLine(lineRenderers[i], endRadius, coneLength, angleOffset);
        }

    }

    private void UpdateCircle(LineRenderer lineRenderer, float radius, float zOffset) {

        Vector3[] linePoints = new Vector3[circlePointCount];

        for (int i = 0; i < circlePointCount; i++) {
            Vector3 pointOnCircle = new Vector3();

            float percentageOfPointCount = ((float) i) / ((float) circlePointCount - 1);

            float angle = Mathf.PI * 2.0f * percentageOfPointCount;
            pointOnCircle.x = radius * Mathf.Cos(angle);
            pointOnCircle.y = radius * Mathf.Sin(angle);
            pointOnCircle.z = zOffset;

            linePoints[i] = pointOnCircle;
        }

        lineRenderer.positionCount = circlePointCount;
        lineRenderer.SetPositions(linePoints);

    }

    private void UpdateLine(LineRenderer lineRenderer, float endRadius, float zDistance, float angleOffset) {

        Vector3[] positions = new Vector3[2];
        positions[0] = Vector3.zero;

        Vector3 positionOnFarCircle = new Vector3();
        positionOnFarCircle.x = endRadius * Mathf.Cos(angleOffset);
        positionOnFarCircle.y = endRadius * Mathf.Sin(angleOffset);
        positionOnFarCircle.z = zDistance;
        positions[1] = positionOnFarCircle;

        lineRenderer.positionCount = positions.Length;
        lineRenderer.SetPositions(positions);

    }

    private void LateUpdate() {
        if (lineColour != lineColourCache) {
            SetLineColour(lineColour);
        }
    }

    private void SetLineColour(Color lineColour) {
        lineColourCache = lineColour;
        Gradient gradient = new Gradient();

        GradientAlphaKey[] gradientAlphaKeys = new GradientAlphaKey[2];
        gradientAlphaKeys[0] = new GradientAlphaKey(lineColour.a, 0f);
        gradientAlphaKeys[1] = new GradientAlphaKey(lineColour.a, 1f);
        gradient.alphaKeys = gradientAlphaKeys;

        GradientColorKey[] gradientColorKeys = new GradientColorKey[2];
        gradientColorKeys[0] = new GradientColorKey(lineColour, 0f);
        gradientColorKeys[1] = new GradientColorKey(lineColour, 1f);
        gradient.colorKeys = gradientColorKeys;

        outerCircleRenderer.colorGradient = gradient;
        for (int i = 0; i < circleRenderers.Count; i++) {
            circleRenderers[i].colorGradient = gradient;
        }
        for (int i = 0; i < lineRenderers.Count; i++) {
            lineRenderers[i].colorGradient = gradient;
        }

    }


}
