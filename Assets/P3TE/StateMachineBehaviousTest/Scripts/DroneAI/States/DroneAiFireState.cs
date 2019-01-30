using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DroneAi {
    public class DroneAiFireState : DroneAiBaseState {

        public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            base.OnStateEnter(animator, stateInfo, layerIndex);
            DroneAi.FireForwards();
        }

        public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            
        }

        public override void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            base.OnStateUpdate(animator, stateInfo, layerIndex);
            if (durationInState > DroneAi.cooldown) {
                animator.SetTrigger("FinishCooldown");
            }
        }

    }
}
