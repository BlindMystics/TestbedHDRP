using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BMState {
    public abstract class StateMachineBase : MonoBehaviour {

        public void MoveToState(Enum stateId) {
            if (currentStateId == null) {
                if (stateId == null) {
                    //We are already in this state.
                    return;
                }
            } else if(currentStateId.Equals(stateId)){
                //We are already in this state.
                return;
            }
            if (currentStateId != null) {
                CurrentState.OnStateEnd();
            }
            currentStateId = stateId;
            if (currentStateId != null) {
                CurrentState.OnStateStart();
            }
        }

        protected abstract Dictionary<Enum, SingleStateBase> GenerateStates {
            get;
        }

        public abstract Enum InitialState {
            get;
        }

        private Dictionary<Enum, SingleStateBase> allStates;

        private Enum currentStateId = null;

        private SingleStateBase CurrentState {
            get {
                return allStates[currentStateId];
            }
        }

        protected virtual void Start() {
            allStates = GenerateStates;
            foreach (KeyValuePair<Enum, SingleStateBase> state in allStates) {
                state.Value.StateMachine = this;
            }
        }

        protected virtual void Update() {
            if (currentStateId == null) {
                MoveToState(InitialState);
            }
            CurrentState.InternalUpdateOneFrame();
        }

    }
}