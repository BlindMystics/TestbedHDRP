using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleLaser : MonoBehaviour {
    public Transform laserEnd;

    private Mesh mesh;

    //TODO: Genereate a "Point cloud" which is just a line of vertices between the start and end points.
    //This line will then be manipulated by the geometry shader

    void Start() {
        Mesh mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;

    }

    void Update() {

    }

    private Vector3[] GenerateVertices() {
        Vector3[] vertices = new Vector3[2];
        vertices[0] = new Vector3();
        vertices[1] = laserEnd.localPosition;

        return vertices;
    }
}
