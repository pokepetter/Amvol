import UnityEngine
import System.Collections

class ResizeButton (MonoBehaviour): 

    public startMouseX as single
    public mouseX as int
    public deltaMouseX as single

    public rectTransform as RectTransform
    public noteSection as NoteSection
    public noteSectionRectTransform as RectTransform

    public direction as Direction

    private originalPosition as single

    enum Direction:
        Left
        Right

    def Start():
        if direction == Direction.Right:
            rectTransform.anchoredPosition.x = noteSection.sectionLength / 8
        originalPosition = rectTransform.anchoredPosition.x

    public def BeginDrag():
        print("begin drag")
        startMouseX = mouseX

    public def EndDrag():
        print("end drag: " + deltaMouseX)
        startMouseX = 0
        
        if direction == Direction.Left:
            addDirection = Vector2.left
        else:
            addDirection = Vector2.right

        noteSection.AddLength(deltaMouseX, Vector2.right)
        originalPosition = rectTransform.anchoredPosition.x

    public def Update():
        mouseX = Input.mousePosition.x / Screen.width * 100

        if startMouseX > 0:
            deltaMouseX = Mathf.FloorToInt((mouseX - startMouseX) /4) *4
            rectTransform.anchoredPosition.x = originalPosition + deltaMouseX