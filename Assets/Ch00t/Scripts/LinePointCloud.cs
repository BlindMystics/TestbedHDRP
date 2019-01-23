using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class LinePointCloud : MonoBehaviour {
    public GameObject lineMesh;
    public Transform lineEnd;

    [Space]

    public int pointsPerUnit = 10;

    private Mesh mesh;
    private int updateHash = 0;

    //Generates a "Point cloud" which is just a line of vertices between the start and end points.
    //This line will then be manipulated by the geometry shader

    void Start() {
        mesh = new Mesh();
        lineMesh.GetComponent<MeshFilter>().mesh = mesh;
        lineMesh.transform.localPosition = new Vector3();
    }

    void Update() {
        pointsPerUnit = Mathf.Max(1, pointsPerUnit);

        int newUpdateHash = GenerateUpdateHash();
        if (updateHash != newUpdateHash) {
            lineMesh.transform.LookAt(lineEnd);
            updateHash = newUpdateHash;

            GenerateGeometry(mesh);
        }
    }

    private void GenerateGeometry(Mesh mesh) {
        int previousNumberOfVertices = mesh.vertices.Length;

        Vector3 endPoint = lineEnd.localPosition;
        float length = endPoint.magnitude;

        float numberOfVertices = length * pointsPerUnit;
        int numberOfVerticesInt = Mathf.CeilToInt(numberOfVertices) + 1;

        Vector3[] vertices = new Vector3[numberOfVerticesInt];
        vertices[0] = new Vector3();

        for (int i = 1; i < numberOfVertices; i++) {
            vertices[i] = new Vector3(0f, 0f, length * i / numberOfVertices);
        }

        int[] indices = new int[numberOfVerticesInt];
        for (int i = 0; i < numberOfVerticesInt; i++) {
            indices[i] = i;
        }

        //Ensure we use SetIndices here as it will only render if you set the triangles array otherwise.
        if (previousNumberOfVertices > numberOfVerticesInt) {
            mesh.SetIndices(indices, MeshTopology.Points, 0);
            mesh.vertices = vertices;
        } else {
            mesh.vertices = vertices;
            mesh.SetIndices(indices, MeshTopology.Points, 0);
        }
    }

    private int GenerateUpdateHash() {
        Vector3 endPoint = lineEnd.localPosition;
        return Mathf.FloorToInt(
            ((endPoint.x * 7919) % 65535) + 
            ((endPoint.y * 6229) % 65535) + 
            ((endPoint.z * 4297) % 65535)) +
            pointsPerUnit +
            (int) topologyType;
    }
}
