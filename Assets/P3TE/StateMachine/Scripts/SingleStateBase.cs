using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BMState {
    public abstract class SingleStateBase {

        public StateMachineBase StateMachine {
            get;
            set;
        }

        public virtual void InternalUpdateOneFrame() {
            OnStateUpdate();
        }

        public virtual void OnStateStart() {

        }

        public abstract void OnStateUpdate();

        public virtual void OnStateEnd() {

        }

        public void MoveToState(System.Enum stateId) {
            StateMachine.MoveToState(stateId);
        }

    }
}