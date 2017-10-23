import UnityEngine
import System.Collections

class ResizeButton (MonoBehaviour, IPointerDownHandler, IPointerUpHandler):

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

    def OnPointerDown(ped as PointerEventData):
        if ped.button == PointerEventData.InputButton.Left:
            originalX = Mathf.RoundToInt(transform.localPosition.x)
            startMouseX = Input.mousePosition.x - transform.position.x

    def OnPointerUp(ped as PointerEventData):
        if ped.button == PointerEventData.InputButton.Left:
            startMouseX = 0
            transform.localPosition.x = Mathf.RoundToInt(transform.localPosition.x)
            deltaMouseX = transform.localPosition.x - originalX
            originalX = rectTransform.anchoredPosition.x

            if direction == Direction.Left:
                addDirection = Vector2.left
            else:
                addDirection = Vector2.right


            noteSection.AddLength(deltaMouseX * 16, addDirection)


    def Update():
        if startMouseX != 0:
            transform.position.x = Input.mousePosition.x - startMouseX
            transform.localPosition.x = Mathf.RoundToInt(transform.localPosition.x)
