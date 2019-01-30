using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BMState {
    public abstract class TimedState<T> : SingleState<T> where T : StateMachineBase {

        private float currentStateTime;

        public abstract float StateDuration {
            get;
        }

        public abstract System.Enum NextState {
            get;
        }

        public override void OnStateStart() {
            base.OnStateStart();
            currentStateTime = 0f;
        }

        public override void InternalUpdateOneFrame() {
            currentStateTime += Time.deltaTime;
            if (currentStateTime > StateDuration) {
                MoveToState(NextState);
            } else {
                base.InternalUpdateOneFrame();
            }
        }

        public float ElapsedTime {
            get {
                return currentStateTime;
            }
        }

        public float RemainingTime {
            get {
                return StateDuration - currentStateTime;
            }
        }
    }
}