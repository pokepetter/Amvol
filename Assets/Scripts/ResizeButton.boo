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

    private originalX as single

    enum Direction:
        Left
        Right

    def Start():
        if direction == Direction.Right:
            rectTransform.anchoredPosition.x = noteSection.sectionLength / 16
        originalX = rectTransform.anchoredPosition.x

    def BeginDrag():
        /*print("begin drag")*/
        originalX = transform.localPosition.x
        startMouseX = Input.mousePosition.x - transform.position.x
        startPosition = transform.localPosition

    def EndDrag():
        startMouseX = 0
        deltaMouseX = transform.localPosition.x - originalX
        originalX = rectTransform.anchoredPosition.x

        if direction == Direction.Left:
            addDirection = Vector2.left
        else:
            addDirection = Vector2.right

        noteSection.AddLength(deltaMouseX * 16, Vector2.right)


    def Update():
        if startMouseX != 0:
            snapX = 1
            transform.position.x = Input.mousePosition.x - startMouseX
            transform.localPosition.x = Mathf.RoundToInt(transform.localPosition.x /snapX) * snapX
