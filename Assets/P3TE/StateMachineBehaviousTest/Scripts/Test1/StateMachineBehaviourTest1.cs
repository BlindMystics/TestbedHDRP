using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StateMachineBehaviourTest1 : StateMachineBehaviour {

    public StateMachineHandlerTest1 handler;

    public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
        base.OnStateEnter(animator, stateInfo, layerIndex);
        Debug.Log("OnStateEnter: " + stateInfo.ToString());
    }

    public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
        base.OnStateExit(animator, stateInfo, layerIndex);
        Debug.Log("OnStateExit: " + stateInfo.ToString());
    }

    public override void OnStateMove(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
        base.OnStateMove(animator, stateInfo, layerIndex);
        Debug.Log("OnStateMove: " + stateInfo.ToString());
    }

    public override void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
        base.OnStateUpdate(animator, stateInfo, layerIndex);
        Debug.Log("OnStateUpdate: " + stateInfo.ToString());
        
        animator.SetTrigger("Trigger1");
    }
}
