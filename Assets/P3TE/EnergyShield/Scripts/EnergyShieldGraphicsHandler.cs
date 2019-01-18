using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.VFX;

[ExecuteInEditMode]
public class EnergyShieldGraphicsHandler : MonoBehaviour {

    #region EditorVariables

    public Renderer energyShieldRenderer;
    public Transform energyShieldTransform;

    [Space]

    public Vector3 rotationSpeed;

    [Space]

    public Transform failurePoint;
    public float failureRadius = 0.0f;
    public float failureBrightDist = 0.5f;
    public float failureRadiusGrowthPerSecond = 1f;
    public bool shieldFailing = false;

    [Space]

    public float introAnimEffectRange = 0.4f;
    public float introAnimationDuration;

    [Space]

    public Vector3 positionOfLaserHole;
    public float radiusOfLaserHole;
    public VisualEffect shieldHoleVisualEffect;

    #region debugPublicVariables

    [Space]

    //Failure Point
    public bool displayFailurePointDebug = false;

    [Space]
    //Intro Sequence
    public bool displayIntroSequenceDebug = false;
    public bool overrideIntroSeqCurrVal = false;
    [Range(0.0f, 1.0f)]
    public float introSeqOverrideVal = 0.5f;

    [Space]
    //Laser Hole.
    public bool displayDebugLaserHole = false;
    public bool debugLaserHoleActive = false;
    public GameObject laserHoleDebugParent;
    public Transform laserHoleDebugPos;

    #endregion


    #endregion

    #region privateDataClasses

    private class IntroAnimationData {

        //From parent
        private float startPosition;
        private float endPosition;
        private float animationDuration;

        //Other
        private bool animationActive = false;
        private float currentAnimationTimer = 0f;
        private float percentageComplete;

        public IntroAnimationData(EnergyShieldGraphicsHandler parent) {
            UpdateData(parent);
        }

        public void StartAnimation() {
            animationActive = true;
            currentAnimationTimer = 0f;
        }

        public void UpdateData(EnergyShieldGraphicsHandler parent) {
            Vector3 centerOfEnergyShield = parent.energyShieldTransform.position;
            Vector3 sizeOfEnergyShield = parent.energyShieldTransform.localScale;
            this.startPosition = (sizeOfEnergyShield.y + parent.introAnimEffectRange);
            this.endPosition = -(sizeOfEnergyShield.y + parent.introAnimEffectRange);
            this.animationDuration = parent.introAnimationDuration;
            HandleUpdate();
        }

        public void HandleUpdate() {
            if (animationActive) {
                currentAnimationTimer += Time.deltaTime;
                if (currentAnimationTimer > animationDuration) {
                    animationActive = false;
                    currentAnimationTimer = animationDuration;
                }
            }
            percentageComplete = currentAnimationTimer / animationDuration;
        }

        public float CurrentPosition {
            get {
                float effectRange = endPosition - startPosition;
                return (startPosition + (percentageComplete * effectRange));
            }
        }

        public void DebugSetPercent(float introSeqOverrideVal) {
            percentageComplete = introSeqOverrideVal;
        }

        public float PercentageComplete {
            get {
                return percentageComplete;
            }
        }

        public float StartPosition {
            get {
                return startPosition;
            }
        }

        public float EndPosition {
            get {
                return endPosition;
            }
        }
    }

    #endregion

    #region privateVariables

    private IntroAnimationData introAnimationData;

    private MaterialPropertyBlock propBlock;

    private int frameHoleUpdated = -1;

    #endregion

    public bool LaserHoleActive {
        get {
            //NOTE - This is only really valid in the LateUpdate.
            return (!shieldFailing) && (frameHoleUpdated == Time.frameCount) && (introAnimationData.PercentageComplete >= 1.0f);
        }
    }

    private void Awake() {
        propBlock = new MaterialPropertyBlock();
        introAnimationData = new IntroAnimationData(this);
        ClearShieldFailure();
    }

    // Update is called once per frame
    void Update() {

#if UNITY_EDITOR
        if (introAnimationData == null) {
            //Reinitialise
            Awake();
        }
#endif

        introAnimationData.UpdateData(this);

        if (shieldFailing) {
            failureRadius += failureRadiusGrowthPerSecond * Time.deltaTime;
        }


#if UNITY_EDITOR

        if (overrideIntroSeqCurrVal) {
            introAnimationData.DebugSetPercent(introSeqOverrideVal);
        }

        //Only show the debug display in the editor.
        UpdateDebugDisplay();
#else

        laserHoleDebugParent.SetActive(false);
#endif

        energyShieldTransform.Rotate(rotationSpeed * Time.deltaTime);

    }

    private void UpdateDebugDisplay() {
        laserHoleDebugParent.SetActive(displayDebugLaserHole);
        if (displayDebugLaserHole) {
            if (debugLaserHoleActive) {
                SetLaserHolePosition(laserHoleDebugPos.position);
            }
        }
    }

    public void StartIntroAnimation() {
        ClearShieldFailure();
        introAnimationData.StartAnimation();
    }

    public void ClearShieldFailure() {
        shieldFailing = false;
        failureRadius = 0f;
    }

    public void FailShield(Vector3 startPosition) {
        failurePoint.position = startPosition;
        shieldFailing = true;
        failureRadius = 0f;
    }

    public void SetLaserHolePosition(Vector3 holePosition, bool accountForCircleCurvature = true) {

        frameHoleUpdated = Time.frameCount;

        if (!LaserHoleActive) {
            return;
        }

        if (accountForCircleCurvature) {
            Vector3 transformCenter = energyShieldTransform.position;
            Vector3 toGivenHolePos = holePosition - transformCenter;

            float radiusOfShield = energyShieldTransform.localScale.x;
            float extraAmountInward = radiusOfShield;
            if (radiusOfLaserHole < 0) {
                radiusOfLaserHole = 0f;
            }
            if (radiusOfLaserHole < radiusOfShield) {
                extraAmountInward = radiusOfShield - Mathf.Sqrt((radiusOfShield * radiusOfShield) - (radiusOfLaserHole * radiusOfLaserHole));
            }

            positionOfLaserHole = transformCenter + (toGivenHolePos.normalized * (radiusOfShield - extraAmountInward));
        } else {
            positionOfLaserHole = holePosition;
        }
    }

    private void LateUpdate() {
        energyShieldRenderer.GetPropertyBlock(propBlock);

        //Outro sequence:
        Vector3 localFailurePosition = failurePoint.position - energyShieldTransform.position;
        propBlock.SetVector("_FailurePoint", localFailurePosition);
        propBlock.SetFloat("_FailureRadius", failureRadius);
        propBlock.SetFloat("_FailureBrightDist", failureBrightDist);

        //Intro sequence:
        //Vector3 localExtrudeRegionTopPosition = extrudeRegionTop.position - energyShieldTransform.position;
        //float extrudeValueTop = localExtrudeRegionTopPosition.y;
        //float extrudeValueBottom = extrudeValueTop - effectRange;

        
        propBlock.SetFloat("_IntroRegionTop", introAnimationData.CurrentPosition);
        propBlock.SetFloat("_IntroRegionWidth", introAnimEffectRange);

        //Laser Hole
        //Vector3 shaderLaserHolePos = positionOfLaserHole - energyShieldTransform.position;

        shieldHoleVisualEffect.transform.position = positionOfLaserHole;
        shieldHoleVisualEffect.transform.LookAt(energyShieldTransform.position); //Look at the center of the energy shield.

        if (LaserHoleActive) {
            shieldHoleVisualEffect.Play();
            Vector3 shaderLaserHolePos = positionOfLaserHole;
            propBlock.SetVector("_LaserHolePos", shaderLaserHolePos);
            propBlock.SetFloat("_LaserHoleRadius", radiusOfLaserHole);
        } else {
            shieldHoleVisualEffect.Stop();
            propBlock.SetVector("_LaserHolePos", Vector3.zero);
            propBlock.SetFloat("_LaserHoleRadius", -1000.0f);
        }
        

        energyShieldRenderer.SetPropertyBlock(propBlock);
    }

    #region Editor gizmo implementation

    #if UNITY_EDITOR

    Mesh _gridMesh;

    void OnDestroy() {
        if (_gridMesh != null) {
            if (Application.isPlaying)
                Destroy(_gridMesh);
            else
                DestroyImmediate(_gridMesh);
        }
    }

    void OnDrawGizmos() {
        if (_gridMesh == null)
            InitGridMesh();

        //Gizmos.matrix = transform.localToWorldMatrix;

        if (displayIntroSequenceDebug) {

            Quaternion introDebugPlaneRotation = transform.rotation * Quaternion.Euler(-90f, 0f, 0f);
            Matrix4x4 rotationMatrix = Matrix4x4.TRS(transform.position, introDebugPlaneRotation, transform.lossyScale);
            Gizmos.matrix = rotationMatrix;

            Gizmos.color = new Color(0, 1, 0, 0.5f);
            Gizmos.DrawWireMesh(_gridMesh, Vector3.forward * (introAnimationData.CurrentPosition + introAnimEffectRange));
            Gizmos.color = new Color(1, 1, 0, 0.5f);
            Gizmos.DrawWireMesh(_gridMesh, Vector3.forward * introAnimationData.CurrentPosition);
            Gizmos.color = new Color(1, 0, 0, 0.5f);
            Gizmos.DrawWireMesh(_gridMesh, Vector3.forward * (introAnimationData.CurrentPosition - introAnimEffectRange));

            Gizmos.color = new Color(1, 0, 0, 0.5f);
            float introRange = introAnimationData.EndPosition - introAnimationData.StartPosition;
            Gizmos.DrawWireCube(Vector3.zero, new Vector3(0.02f, 0.02f, introRange));

        }

        if (displayFailurePointDebug) {

            Gizmos.matrix = Matrix4x4.identity;

            if (failureRadius > 0) {
                Gizmos.color = new Color(1, 1, 0, 0.5f);
                Gizmos.DrawWireSphere(failurePoint.position, failureRadius);
            }

            if (failureRadius - failureBrightDist > 0) {
                Gizmos.color = new Color(1, 0, 0, 0.5f);
                Gizmos.DrawWireSphere(failurePoint.position, failureRadius - failureBrightDist);
            }
            
        }

        if (displayDebugLaserHole && debugLaserHoleActive) {

            Gizmos.matrix = Matrix4x4.identity;

            Gizmos.color = new Color(1, 0, 0, 0.5f);
            Gizmos.DrawWireSphere(positionOfLaserHole, radiusOfLaserHole);

        }

    }

    void InitGridMesh() {
        const float ext = 1.5f;
        const int columns = 10;

        var vertices = new List<Vector3>();
        var indices = new List<int>();

        for (var i = 0; i < columns + 1; i++) {
            var x = ext * (2.0f * i / columns - 1);

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(x, -ext, 0));

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(x, +ext, 0));

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(-ext, x, 0));

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(+ext, x, 0));
        }

        _gridMesh = new Mesh { hideFlags = HideFlags.DontSave };
        _gridMesh.SetVertices(vertices);
        _gridMesh.SetNormals(vertices);
        _gridMesh.SetIndices(indices.ToArray(), MeshTopology.Lines, 0);
        _gridMesh.UploadMeshData(true);
    }

    #endif

    #endregion
}
