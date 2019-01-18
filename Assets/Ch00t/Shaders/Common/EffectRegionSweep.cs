using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectRegionSweep : MonoBehaviour {
    public float effectTop = 1f;
    public float effectBot = 0f;

    public float timeToSweep = 2f;

    private new Renderer renderer;
    private MaterialPropertyBlock propBlock;

    private enum State {
        TOP_UP,
        BOT_UP,
        BOT_DOWN,
        TOP_DOWN
    };

    private float topPosition = 0f;
    private float botPosition = 0f;
    private float endTime;

    private State currentState;

    private int _EffectRegionBottomId;
    private int _EffectRegionTop;

    private void Start() {
        renderer = GetComponent<Renderer>();
        propBlock = new MaterialPropertyBlock();

        _EffectRegionBottomId = Shader.PropertyToID("_EffectRegionBottom");
        _EffectRegionTop = Shader.PropertyToID("_EffectRegionTop");

        currentState = State.TOP_UP;
    }

    private void Update() {
        endTime -= Time.deltaTime;

        if (endTime < 0) {
            currentState = GetNextState();
            endTime = timeToSweep;
        }

        float t = 1 - (endTime / timeToSweep);

        switch (currentState) {
            case State.TOP_UP:
                topPosition = Mathf.Lerp(effectBot, effectTop, t);
                botPosition = effectBot;
                break;
            case State.BOT_UP:
                topPosition = effectTop;
                botPosition = Mathf.Lerp(effectBot, effectTop, t);
                break;
            case State.TOP_DOWN:
                topPosition = Mathf.Lerp(effectTop, effectBot, t);
                botPosition = effectBot;
                break;
            case State.BOT_DOWN:
                topPosition = effectTop;
                botPosition = Mathf.Lerp(effectTop, effectBot, t);
                break;
        }
    }

    private void LateUpdate() {
        renderer.GetPropertyBlock(propBlock);

        propBlock.SetFloat(_EffectRegionBottomId, botPosition);
        propBlock.SetFloat(_EffectRegionTop, topPosition);

        renderer.SetPropertyBlock(propBlock);
    }

    private State GetNextState() {
        switch (currentState) {
            case State.TOP_UP:
                return State.BOT_UP;
            case State.BOT_UP:
                return State.BOT_DOWN;
            case State.BOT_DOWN:
                return State.TOP_DOWN;
            case State.TOP_DOWN:
                return State.TOP_UP;
        }
        return State.TOP_UP;
    }
}
