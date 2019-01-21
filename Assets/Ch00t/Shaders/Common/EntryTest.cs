using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EntryTest : MonoBehaviour {
    public float goneTime = 0.5f, entryTime = 1f, detailTime = 1f;

    [Space]

    public float entryRegionSize = 0.2f;

    private new Renderer renderer;
    private MaterialPropertyBlock propBlock;

    private enum State {
        GONE,
        ENTERING,
        DETAIL,
        DISSOLVE,
        DISAPPEAR
    }

    private State currentState;

    private float stageTime = 0f;

    private int _EntryValueId;
    private int _DetailValueId;

    private float entryValue = 0f;
    private float detailValue = 0f;

    private void Start() {
        renderer = GetComponent<Renderer>();
        propBlock = new MaterialPropertyBlock();

        _EntryValueId = Shader.PropertyToID("_EntryValue");
        _DetailValueId = Shader.PropertyToID("_DetailValue");

        currentState = State.GONE;
    }

    private void Update() {
        stageTime -= Time.deltaTime;
        if (stageTime <= 0) {
            currentState = GetNextState();

            switch (currentState) {
                case State.ENTERING:
                    stageTime = entryTime;
                    break;
                case State.DETAIL:
                    stageTime = detailTime;
                    break;
                case State.DISSOLVE:
                    stageTime = detailTime;
                    break;
                case State.DISAPPEAR:
                    stageTime = entryTime;
                    break;
                case State.GONE:
                    stageTime = goneTime;
                    break;
            }
        }

        float fullEntryAmount = 1f + entryRegionSize;

        switch (currentState) {
            case State.GONE:
                entryValue = 0f;
                detailValue = 0f;
                break;
            case State.ENTERING:
                entryValue = fullEntryAmount * (1f - (stageTime / entryTime));
                detailValue = 0f;
                break;
            case State.DETAIL:
                entryValue = fullEntryAmount;
                detailValue = fullEntryAmount * (1f - (stageTime / detailTime));
                break;
            case State.DISSOLVE:
                entryValue = fullEntryAmount;
                detailValue = stageTime / detailTime;
                break;
            case State.DISAPPEAR:
                entryValue = fullEntryAmount * ((stageTime / entryTime));
                detailValue = 0f;
                break;
        }
    }

    private void LateUpdate() {
        renderer.GetPropertyBlock(propBlock);

        propBlock.SetFloat(_EntryValueId, entryValue);
        propBlock.SetFloat(_DetailValueId, detailValue);

        renderer.SetPropertyBlock(propBlock);
    }

    private State GetNextState() {
        switch (currentState) {
            case State.GONE:
                return State.ENTERING;
            case State.ENTERING:
                return State.DETAIL;
            case State.DETAIL:
                return State.DISSOLVE;
            case State.DISSOLVE:
                return State.DISAPPEAR;
            case State.DISAPPEAR:
                return State.GONE;
        }
        return State.GONE;
    }
}
