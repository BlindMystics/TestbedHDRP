using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnergyShieldGraphicsDemo : MonoBehaviour {

    public EnergyShieldGraphicsHandler energyShieldToDemo;


    public KeyCode playIntroAnimationKey = KeyCode.T;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update() {

        if (Input.GetKeyDown(playIntroAnimationKey)) {
            energyShieldToDemo.StartIntroAnimation();
        }

        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit raycastHit;
        if (Physics.Raycast(ray, out raycastHit)) {
            if (raycastHit.collider != null) {
                EnergyShieldGraphicsHandler energyShieldGraphicsHandler = raycastHit.collider.GetComponentInParent<EnergyShieldGraphicsHandler>();
                if (energyShieldGraphicsHandler == energyShieldToDemo) {
                    energyShieldToDemo.SetLaserHolePosition(raycastHit.point);
                    if (Input.GetMouseButtonDown(0)) {
                        energyShieldToDemo.FailShield(raycastHit.point);
                    }
                }
            }
        }

    }
}
