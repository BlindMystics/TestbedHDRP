using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DroneAi {
    public class DroneAiDestroyState : DroneAiBaseState {
        public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            base.OnStateEnter(animator, stateInfo, layerIndex);
            DroneAi.PlayDestroySequence();
        }

        public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            base.OnStateExit(animator, stateInfo, layerIndex);
            Destroy(DroneAi.gameObject);
        }

        public override void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
            base.OnStateUpdate(animator, stateInfo, layerIndex);
            if (durationInState > DroneAi.distructionAnimationTime) {
                animator.SetTrigger("DestructionComplete");
            }
        }
    }
}
