using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandInCircleTest : MonoBehaviour
{

    public GameObject toCopy;
    public int numInstances = 1000;

    public enum Method {
        UNITY, //Uniform
        POLAR_COORDS, //Not Uniform, higher density towards the center
        TRY_AGAIN, //Uniform - Technically unbounded, practically not that bad
        POLAR_COORDS_COMPENSATE //Uniform
    }

    public Method method = Method.UNITY;

    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < numInstances; i++) {
            GameObject copied = Instantiate<GameObject>(toCopy, this.transform);
            copied.SetActive(true);
            Vector2 position = Vector2.zero;
            switch (method) {
                case Method.UNITY:
                    position = UnityEngine.Random.insideUnitCircle;
                    break;
                case Method.POLAR_COORDS:
                    float distance = UnityEngine.Random.Range(0f, 1f);
                    float angle = UnityEngine.Random.Range(0f, Mathf.PI * 2.0f);
                    position.x = distance * Mathf.Cos(angle);
                    position.y = distance * Mathf.Sin(angle);
                    break;
                case Method.TRY_AGAIN:
                    while (true) {
                        position = new Vector2(UnityEngine.Random.Range(-1f, 1f), UnityEngine.Random.Range(-1f, 1f));
                        if (position.sqrMagnitude < 1.0f) {
                            break;
                        }
                    }
                    break;
                case Method.POLAR_COORDS_COMPENSATE:
                    float area = UnityEngine.Random.Range(0f, 1.0f);
                    float usedRadius = Mathf.Sqrt(area);
                    float angle2 = UnityEngine.Random.Range(0f, Mathf.PI * 2.0f);
                    position.x = usedRadius * Mathf.Cos(angle2);
                    position.y = usedRadius * Mathf.Sin(angle2);
                    break;
            }
            
            copied.transform.localPosition = new Vector3(position.x, 0f, position.y);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
