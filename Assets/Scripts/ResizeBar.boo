import UnityEngine
import System.Collections

class ResizeBar (MonoBehaviour): 

    public startMouseX as single
    public mouseX as int
    public deltaMouseX as single

    private originalWidth as single

    private rectTransform as RectTransform
    private noteSection as NoteSection

    def Awake():
        rectTransform = transform.GetComponent(RectTransform)
        originalWidth = rectTransform.sizeDelta.x
        noteSection = transform.parent.GetComponent(NoteSection)

    public def BeginDrag():
        print("begin drag")
        startMouseX = mouseX

    public def EndDrag():
        print("end drag")
        startMouseX = 0
        noteSection.AddLength(deltaMouseX)
        rectTransform.sizeDelta.x = originalWidth

    public def Update():
        mouseX = Input.mousePosition.x / Screen.width * 100

        if startMouseX > 0:
            deltaMouseX = Mathf.FloorToInt((mouseX - startMouseX) /4) *4
            rectTransform.sizeDelta.x = deltaMouseX

