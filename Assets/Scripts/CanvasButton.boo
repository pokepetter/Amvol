import UnityEngine
import UnityEngine.UI
import UnityEngine.EventSystems

class CanvasButton (MonoBehaviour, IPointerDownHandler): 

    public noteSection as NoteSection


    public def OnPointerDown(ped as PointerEventData):
        localCursorPosition as Vector2
        i as int = 0
        print("down")
        if RectTransformUtility.ScreenPointToLocalPointInRectangle(GetComponent(RectTransform), ped.position, ped.pressEventCamera, localCursorPosition):
            localCursorPosition = Vector2(Mathf.FloorToInt(localCursorPosition.x), Mathf.FloorToInt(localCursorPosition.y))
            if not Input.GetKey(KeyCode.LeftAlt):
                for i in range(NoteSizeSetter.noteSizeSetter.noteSize):
                    noteSection.SetNote(localCursorPosition.x +i, localCursorPosition.y, 1f)
                noteSection.PlayNote(localCursorPosition.y, 1f)
            else:
                for i in range(NoteSizeSetter.noteSizeSetter.noteSize):
                    noteSection.SetNote(localCursorPosition.x +i, localCursorPosition.y, 0f)

