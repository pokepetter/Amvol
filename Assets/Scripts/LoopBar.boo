import UnityEngine
import System.Collections

class LoopBar (MonoBehaviour): 

    public startMouseX as single
    public mouseX as int
    public deltaMouseX as single

    private originalWidth as single
    private startWidth as int

    private rectTransform as RectTransform
    private noteSection as NoteSection

    def Awake():
        rectTransform = transform.GetComponent(RectTransform)
        originalWidth = rectTransform.sizeDelta.x
        noteSection = transform.parent.GetComponent(NoteSection)

    public def BeginDrag():
        print("begin drag")
        startMouseX = mouseX
        startWidth = noteSection.GetComponent(RectTransform).sizeDelta.x

    public def EndDrag():
        print("end drag")
        startMouseX = 0
        rectTransform.sizeDelta.x = originalWidth

        noteSection.GetComponent(RectTransform).sizeDelta.x += deltaMouseX
        noteSection.loops = 3

    public def Update():
        mouseX = Input.mousePosition.x / Screen.width * 100

        if startMouseX > 0:
            deltaMouseX = Mathf.FloorToInt((mouseX - startMouseX) /4) *4
            rectTransform.sizeDelta.x = deltaMouseX