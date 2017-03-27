import UnityEngine
import UnityEngine.UI
import UnityEngine.EventSystems

class CanvasButton (MonoBehaviour, IPointerDownHandler): 

    public noteSection as NoteSection

    public def OnPointerDown(ped as PointerEventData):
        localCursorPosition as Vector2
        i as int = 0

        if RectTransformUtility.ScreenPointToLocalPointInRectangle(GetComponent(RectTransform), ped.position, ped.pressEventCamera, localCursorPosition) and Input.GetKey(KeyCode.LeftAlt) == false:
            localCursorPosition = Vector2(Mathf.FloorToInt(localCursorPosition.x), Mathf.FloorToInt(localCursorPosition.y))
            
            if transform.parent.localScale.x == 1f:
                noteSection.SetNote(localCursorPosition.x, localCursorPosition.y, 1f)
            elif transform.parent.localScale.x == 0.5f:
                for i in range(2):
                    noteSection.SetNote(localCursorPosition.x + i, localCursorPosition.y, 1f)
            elif transform.parent.localScale.x == 0.25f:
                for i in range(4):
                    noteSection.SetNote(localCursorPosition.x + i, localCursorPosition.y, 1f) 
            elif transform.parent.localScale.x == 0.125f:
                for i in range(8):
                    noteSection.SetNote(localCursorPosition.x + i, localCursorPosition.y, 1f)

            noteSection.PlayNote(localCursorPosition.y, 1f)

