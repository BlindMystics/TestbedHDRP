using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DroneAi {
    public abstract class DroneAiBaseState : StateMachineBehaviour {

        public DroneAiHandler DroneAi {
            get;
            set;
        }

        protected float durationInState;

        public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            if (DroneAi == null) {
                DroneAi = animator.gameObject.GetComponent<DroneAiHandler>();
            }
            durationInState = 0f;
        }

        public override void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            durationInState += Time.deltaTime;
        }

    }
}