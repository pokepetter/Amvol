using UnityEditor;
using UnityEngine;
using System.Collections;

public class GroupSelected : MonoBehaviour {
	
	private Vector3 averagePosition;
	private int j;
	
	[MenuItem("Custom/Group Selected %g")]
    static void GroupCenter() {
		Vector3 averagePosition = Vector3.zero;
		int j = 0;
		
        Transform[] transforms = Selection.transforms;
        if (transforms.Length == 0)
            return;

        Transform firstSelected = transforms[0];

        GameObject group = new GameObject("Group " + firstSelected.name);
        group.transform.parent = firstSelected.parent;
		
		for (j = 0; j < transforms.Length; j++) {
            averagePosition += transforms[j].position;
        }
		averagePosition = averagePosition / transforms.Length;
        group.transform.position = averagePosition;

        for (int i = 0; i < transforms.Length; i++) {
            Undo.RecordObject(Selection.gameObjects[i], "Undo grouping");
            transforms[i].parent = group.transform;
            EditorUtility.SetDirty(transforms[i].gameObject);
        }
		Selection.activeGameObject = group;
    }
	
    [MenuItem("Custom/Group Zero %#g")]
    static void GroupZero() {
        Transform[] transforms = Selection.transforms;
        if (transforms.Length == 0)
            return;

        Transform firstSelected = transforms[0];

        GameObject group = new GameObject("Group " + firstSelected.name);
        group.transform.parent = firstSelected.parent;

        group.transform.localPosition = Vector3.zero;

        for (int i = 0; i < transforms.Length; i++) {
            Undo.RecordObject(Selection.gameObjects[i], "Undo grouping");
            transforms[i].parent = group.transform;
            EditorUtility.SetDirty(transforms[i].gameObject);
        }
		Selection.activeGameObject = group;
    }


}
