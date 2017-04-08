import UnityEngine
import System.Collections

class LoopBar (MonoBehaviour): 

    public rectTransform as RectTransform
    public noteSection as NoteSection
    public noteSectionRectTransform as RectTransform

    public startMouseX as single
    public mouseX as int
    public deltaMouseX as single

    private originalWidth as single
    private startWidth as int


    public def BeginDrag():
        # print("begin drag")
        startMouseX = mouseX
        originalWidth = noteSectionRectTransform.sizeDelta.x

    public def EndDrag():
        # print("end drag")
        startMouseX = 0
        originalWidth = noteSectionRectTransform.sizeDelta.x
        noteSection.CalculateLoops()
        # rectTransform.sizeDelta.x = originalWidth

        # noteSectionRectTransform.sizeDelta.x += deltaMouseX
        # noteSection.loops = 3

    public def Update():
        mouseX = Input.mousePosition.x / Screen.width * 100

        if startMouseX > 0:
            deltaMouseX = Mathf.FloorToInt((mouseX - startMouseX) /4) *4
            noteSectionRectTransform.sizeDelta.x = originalWidth + deltaMouseX