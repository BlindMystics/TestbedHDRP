using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DroneAi {
    public class DroneAiMoveState : DroneAiBaseState {

        public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            base.OnStateEnter(animator, stateInfo, layerIndex);
        }

        public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
        }

        public override void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            base.OnStateUpdate(animator, stateInfo, layerIndex);
            DroneAi.CurrentSpeed += DroneAi.moveAcceleration * Time.deltaTime;
            DroneAi.LookTowardOrigin();
            if (durationInState > DroneAi.moveTime) {
                animator.SetTrigger("BeginAim");
            }
        }
    }
}