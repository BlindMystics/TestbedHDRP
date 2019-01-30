using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DroneAi {
    public class DroneAiAimState : DroneAiBaseState {

        public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            base.OnStateEnter(animator, stateInfo, layerIndex);
            DroneAi.chargeShotEffect.SendEvent("OnChargeBegin");
        }

        public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            
        }

        public override void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            base.OnStateUpdate(animator, stateInfo, layerIndex);
            DroneAi.SlowDown(DroneAi.moveAcceleration * Time.deltaTime);
            DroneAi.LookTowardOrigin();
            if (durationInState > (DroneAi.aimTime - DroneAi.stopChargeVfxEarly)) {
                DroneAi.chargeShotEffect.SendEvent("OnChargeEnd");
            }
            if (durationInState > DroneAi.aimTime) {
                animator.SetTrigger("Fire");
            }
        }
    }
}