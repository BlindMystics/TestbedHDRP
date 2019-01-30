using BMState;
using DroneStates;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.VFX;

public class DroneStateMachine : StateMachineBase {

    public float moveTime = 3.0f;

    public float moveAcceleration = 3.0f;

    public float moveMaxVelocity = 4.0f;

    [Space]

    public float aimTime = 2.0f;
    public float lookRotationSpeed = 90.0f;
    public float stopChargeVfxEarly = 1.0f;

    [Space]

    public VisualEffect chargeShotEffect;
    public float fireCooldown = 1.0f;
    public GameObject objectToFirePrefab;
    public float fireVelocity = 10.0f;

    [Space]

    public VisualEffect destroyEffect;
    public GameObject renderedParent;
    public float destructionAnimationTime = 2.0f;

    [Space]

    public bool destroyDrone = false;

    protected override Dictionary<Enum, SingleStateBase> GenerateStates => new Dictionary<Enum, SingleStateBase> {
        {DroneState.MOVE, new MoveState()},
        {DroneState.AIM, new AimState()},
        {DroneState.FIRE, new FireState()},
        {DroneState.DESTROY, new DestroyState()},
    };

    public override Enum InitialState => DroneState.MOVE;

    private float _currentSpeed = 0;

    public float CurrentSpeed {
        get {
            return _currentSpeed;
        }
        set {
            _currentSpeed = value;
            //Limit speed.
            if (_currentSpeed > moveMaxVelocity) {
                _currentSpeed = moveMaxVelocity;
            } else if (_currentSpeed < -moveMaxVelocity) {
                _currentSpeed = -moveMaxVelocity;
            }
        }
    }

    public void SlowDown(float deacceleration) {
        if (CurrentSpeed > 0) {
            CurrentSpeed -= Mathf.Abs(deacceleration);
            if (CurrentSpeed < 0) {
                CurrentSpeed = 0f;
            }
        } else if (CurrentSpeed < 0) {
            CurrentSpeed += Mathf.Abs(deacceleration);
            if (CurrentSpeed > 0) {
                CurrentSpeed = 0f;
            }
        }
    }


    protected override void Update() {
        base.Update();

        OrbitAroundPoint(Vector3.zero);

        if (destroyDrone) {
            MoveToState(DroneState.DESTROY);
        }

    }

    private void OrbitAroundPoint(Vector3 orbitAround) {
        Vector3 toOrigin = orbitAround - transform.position;
        Vector2 xzDistToOrigin = new Vector2(toOrigin.x, toOrigin.z);
        float radius = xzDistToOrigin.magnitude;
        float circumference = Mathf.PI * 2.0f * radius;
        float currentAngle = Mathf.Atan2(xzDistToOrigin.y, xzDistToOrigin.x);

        float distanceTravelled = CurrentSpeed * Time.deltaTime;
        float precentCircumferenceTravelled = (distanceTravelled / circumference) % 1.0f;
        float angleChange = precentCircumferenceTravelled * Mathf.PI * 2.0f;
        float newAngle = currentAngle + angleChange;
        float newX = orbitAround.x - (radius * Mathf.Cos(newAngle));
        float newZ = orbitAround.z - (radius * Mathf.Sin(newAngle));

        Vector3 newPosition = new Vector3(newX, transform.position.y, newZ);
        transform.position = newPosition;
    }

    public void LookTowardOrigin() {
        Vector3 orbitAround = Vector3.zero;
        Vector3 desiredLookVector = orbitAround - transform.position;
        desiredLookVector.y = 0f;
        Quaternion lookRotation = Quaternion.LookRotation(desiredLookVector);
        transform.rotation = Quaternion.RotateTowards(transform.rotation, lookRotation, lookRotationSpeed * Time.deltaTime);
    }

    public void FireForwards() {
        GameObject toFire = Instantiate<GameObject>(objectToFirePrefab);
        toFire.transform.position = transform.position;
        toFire.transform.rotation = transform.rotation;
        Rigidbody rigidbodyComponent = toFire.GetComponent<Rigidbody>();
        rigidbodyComponent.velocity = transform.forward * fireVelocity;
    }

    public void PlayDestroySequence() {
        CurrentSpeed = 0f;
        renderedParent.SetActive(false);
        chargeShotEffect.gameObject.SetActive(false);
        destroyEffect.SendEvent("OnDestroyDrone");
    }

    public void DestroyObject() {
        Destroy(gameObject);
    }

}
