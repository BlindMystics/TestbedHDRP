using BMState;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DroneStates {

    public enum DroneState {
        MOVE,
        AIM,
        FIRE,
        DESTROY
    }

    public class MoveState : TimedState<DroneStateMachine> {

        public override float StateDuration => StateMachine.moveTime;

        public override Enum NextState => DroneState.AIM;

        public override void OnStateUpdate() {
            StateMachine.CurrentSpeed += StateMachine.moveAcceleration * Time.deltaTime;
            StateMachine.LookTowardOrigin();
        }
    }


    public class AimState : TimedState<DroneStateMachine> {

        public override float StateDuration => StateMachine.aimTime;

        public override Enum NextState => DroneState.FIRE;

        public override void OnStateStart() {
            base.OnStateStart();
            StateMachine.chargeShotEffect.SendEvent("OnChargeBegin");
        }

        public override void OnStateUpdate() {
            StateMachine.SlowDown(StateMachine.moveAcceleration * Time.deltaTime);
            StateMachine.LookTowardOrigin();
            if (RemainingTime < (StateMachine.stopChargeVfxEarly)) {
                StateMachine.chargeShotEffect.SendEvent("OnChargeEnd");
            }
        }
    }


    public class FireState : TimedState<DroneStateMachine> {

        public override float StateDuration => StateMachine.destructionAnimationTime;

        public override Enum NextState => DroneState.MOVE;

        public override void OnStateStart() {
            base.OnStateStart();
            StateMachine.FireForwards();
        }

        public override void OnStateUpdate() {
            //Nothing done here...
        }
    }

    public class DestroyState : TimedState<DroneStateMachine> {

        public override float StateDuration => StateMachine.destructionAnimationTime;

        public override Enum NextState => null;

        public override void OnStateStart() {
            base.OnStateStart();
            StateMachine.PlayDestroySequence();
        }

        public override void OnStateUpdate() {
            //Nothing to do here...
        }

        public override void OnStateEnd() {
            base.OnStateEnd();
            StateMachine.DestroyObject();
        }

    }
}
