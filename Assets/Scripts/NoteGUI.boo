import UnityEngine
import UnityEngine.UI

class NoteGUI (MonoBehaviour): 

    private button as Button
    private noteSection as NoteSection

    def Awake():
        button = GetComponent(Button)
        button.onClick.AddListener({OnClick()})

    def Start():
        noteSection = transform.parent.GetComponent(CanvasButton).noteSection

    public def OnClick():
        if Input.GetKey(KeyCode.LeftAlt):
            noteSection.SetNote(transform.localPosition.x, transform.localPosition.y, 0f)
            Destroy(gameObject)
