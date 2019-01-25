using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShotgunFocusDemo : MonoBehaviour {

    public ShotgunFocusLineRendererTest1 shotgunFocus;

    public float noFireDuration = 0.35f;

    private float currentAlpha = 0f;
    private float alphaWhenReleased = 0f;
    private float alphaFadeTimer = 0f;

    public float alphaLeadinTime = 0.5f;
    public float alphaFadeTime = 0.25f;

    private bool isVisible = false;

    public float startAngle = 30.0f;
    public float endAngle = 10.0f;
    public float durationToEndAngle = 5.0f;

    private float timeVisisble = 0f;

    public float powerComponentRadiusReduction = 3.0f;

    public ShotgunBeam shotgunBeamPrefab;
    public int beamCount = 5;

    public Vector2 fireVelocityRange = new Vector2(15f, 20f);

    public float beamSpawnOffset = 0.25f;

    private Color currentBaseColour = Color.black;


    [Space]

    public float beamColourIntensity = 3.0f;
    public float beamColourSaturation = 0.8f;

    [Space]

    public float focusColourIntensity = -2.0f;

    [Space]

    public float beamImpactIntensity = 2.0f;
    public float beamImpactSaturation = 0.8f;
    [GradientUsage(true)]
    public Gradient beamImpactBaseGradient;

    [Space]

    public Color cyanColourBase = new Color(0f, 1f, 1f);
    public Color redColourBase = new Color(1f, 0f, 0f);

    public Color SetColorIntensity(Color color, float newIntensity, float desiredSaturation = -1) {
        float h, s, v;
        Color result;
        if (desiredSaturation != -1) {
            Color.RGBToHSV(color, out h, out s, out v);
            s = desiredSaturation;
            result = Color.HSVToRGB(h, s, v);
        } else {
            result = color;
        }
        result *= Mathf.Pow(2.0f, newIntensity);
        return result;
    }

    public Color GetBeamColour(Color baseColour) {
        return SetColorIntensity(baseColour, beamColourIntensity, beamColourSaturation);
    }

    public Color GetFocusColour(Color baseColour) {
        return SetColorIntensity(baseColour, focusColourIntensity);
    }

    public Gradient GetBeamImpactGradient(Color baseColour) {
        GradientAlphaKey[] gradientAlphaKeys = new GradientAlphaKey[beamImpactBaseGradient.alphaKeys.Length];
        System.Array.Copy(beamImpactBaseGradient.alphaKeys, gradientAlphaKeys, beamImpactBaseGradient.alphaKeys.Length);
        GradientColorKey[] gradientColourKeys = new GradientColorKey[beamImpactBaseGradient.colorKeys.Length];
        System.Array.Copy(beamImpactBaseGradient.colorKeys, gradientColourKeys, beamImpactBaseGradient.colorKeys.Length);
        for (int i = 0; i < gradientColourKeys.Length; i++) {
            Color existingColour = gradientColourKeys[i].color;
            float intensity = Mathf.Log(existingColour.r, 2);
            gradientColourKeys[i].color = baseColour * Mathf.Pow(2.0f, intensity);
        }
        Gradient result = new Gradient();
        result.alphaKeys = gradientAlphaKeys;
        result.colorKeys = gradientColourKeys;
        return result;
    }

    // Start is called before the first frame update
    void Start() {
        UpdateColours(cyanColourBase);
    }

    private float CurrentAngle {
        get {
            float angleRange = startAngle - endAngle;
            //float usedPercentage = 1.0f - Mathf.Sin(percentageFocused * (Mathf.PI / 2.0f));
            float usedPercentage = 1.0f - Mathf.Pow(1.0f - PercentageFocused, powerComponentRadiusReduction);
            float currentAngle = startAngle - ((usedPercentage) * angleRange);
            return currentAngle;
        }
    }

    private float PercentageFocused {
        get {
            float percentageFocused = 1.0f;
            if (timeVisisble < durationToEndAngle) {
                percentageFocused = timeVisisble / durationToEndAngle;
            }
            return percentageFocused;
        }
    }

    private void UpdateColours(Color baseColour) {
        this.currentBaseColour = baseColour;
        shotgunFocus.lineColour = GetFocusColour(currentBaseColour);
    }

    // Update is called once per frame
    void Update() {

        if (Input.GetKeyDown(KeyCode.R)) {
            UpdateColours(redColourBase);
        }
        if (Input.GetKeyDown(KeyCode.C)) {
            UpdateColours(cyanColourBase);
        }

        isVisible = Input.GetMouseButton(0);

        if (isVisible) {
            timeVisisble += Time.deltaTime;
            currentAlpha += Time.deltaTime / alphaLeadinTime;
            if (currentAlpha > 1.0f) {
                currentAlpha = 1.0f;
            }

            shotgunFocus.coneAngleDeg = CurrentAngle;

        } else {
            if (Input.GetMouseButtonUp(0)) {
                if (timeVisisble >= noFireDuration) {
                    FireBeams();
                }
                alphaWhenReleased = currentAlpha;
                alphaFadeTimer = 0f;
            }

            timeVisisble = 0f;

            alphaFadeTimer += Time.deltaTime;
            currentAlpha = (1.0f - (alphaFadeTimer / alphaFadeTime)) * alphaWhenReleased;

            if (currentAlpha < 0.0f) {
                currentAlpha = 0.0f;
            }
        }

        Color shotgunFocusColour = shotgunFocus.lineColour;
        shotgunFocusColour.a = currentAlpha;
        shotgunFocus.lineColour = shotgunFocusColour;

        shotgunFocus.gameObject.SetActive(currentAlpha > 0.0f);

    }

    private void FireBeams() {

        for (int i = 0; i < beamCount; i++) {

            Vector2 insideUnitCircle = UnityEngine.Random.insideUnitCircle;
            float unitCircleDistanceFromOrigin = 1.0f / Mathf.Sin(CurrentAngle * Mathf.Deg2Rad);
            Vector3 fireDirection = new Vector3(insideUnitCircle.x, insideUnitCircle.y, unitCircleDistanceFromOrigin);
            shotgunFocus.transform.TransformDirection(fireDirection);
            Vector3 fireDirectionNormalized = fireDirection.normalized;
            Quaternion fireRotation = Quaternion.LookRotation(fireDirection);
            ShotgunBeam newBeam = Instantiate<ShotgunBeam>(shotgunBeamPrefab);
            Transform beamTransform = newBeam.transform;
            beamTransform.rotation = fireRotation;
            beamTransform.transform.position = shotgunFocus.transform.position + (beamSpawnOffset * fireDirectionNormalized);
            Rigidbody beamRigidbody = newBeam.GetComponent<Rigidbody>();
            beamRigidbody.velocity = fireDirectionNormalized * UnityEngine.Random.Range(fireVelocityRange.x, fireVelocityRange.y);
            ShotgunBeam shotgunBeam = newBeam.GetComponent<ShotgunBeam>();
            shotgunBeam.SetColours(GetBeamColour(currentBaseColour), GetBeamImpactGradient(currentBaseColour));


        }

    }
}
