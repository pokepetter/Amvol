import UnityEngine

class Hotkey (MonoBehaviour): 

    public modifier as string
    public key as string


    def Update():
        if Input.GetKey(modifier) and Input.GetKeyDown(key) or modifier == "" and Input.GetKeyDown(key):
            if transform.GetComponent(Button) != null:

                transform.GetComponent(Button).onClick.Invoke()


    # public enum Modifier:
    #     KeyCode.None
    #     KeyCode.LeftControl
    #     KeyCode.LeftShift
    #     KeyCode.LeftAlt