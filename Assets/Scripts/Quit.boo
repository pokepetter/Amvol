import UnityEngine

class Quit (MonoBehaviour): 

    def ExitButton():
        transform.parent.GetComponent(ToggleButton).Toggle()

    def Quit():
        Application.Quit()
