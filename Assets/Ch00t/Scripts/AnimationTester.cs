using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class AnimationTester : MonoBehaviour {
    public float startAnimationValue = 0f;
    public float endAnimationValue = 1f;

    public float animationTimeSeconds = 1f;
    public float timeBetweenTests = 0.5f;

    [Space]
    public Renderer animationRenderer;

    private MaterialPropertyBlock materialPropertyBlock;
    private int _AnimationTimeId;

    private bool waiting = false;
    private float countdown = 0;

    void Start() {
        _AnimationTimeId = Shader.PropertyToID("_AnimationTime");

        materialPropertyBlock = new MaterialPropertyBlock();

        countdown = timeBetweenTests;
    }

    void Update() {
        if (animationRenderer == null) {
            return;
        }
        animationRenderer.GetPropertyBlock(materialPropertyBlock);

        countdown -= Time.deltaTime;

        if (countdown < 0f) {
            waiting = !waiting;

            if (waiting) {
                countdown = timeBetweenTests;

                materialPropertyBlock.SetFloat(_AnimationTimeId, -1f);
                animationRenderer.SetPropertyBlock(materialPropertyBlock);
            } else {
                countdown = animationTimeSeconds;
            }
        }

        if (waiting) {
            return;
        }

        float value = Mathf.Lerp(startAnimationValue, endAnimationValue, 1f - countdown / animationTimeSeconds);

        materialPropertyBlock.SetFloat(_AnimationTimeId, value);

        animationRenderer.SetPropertyBlock(materialPropertyBlock);
    }
}
