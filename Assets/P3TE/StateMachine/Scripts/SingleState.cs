using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BMState {
    public abstract class SingleState <T> : SingleStateBase where T : StateMachineBase {

        public new T StateMachine {
            get {
                return base.StateMachine as T;
            }
            set {
                base.StateMachine = value;
            }
        }

    }
}