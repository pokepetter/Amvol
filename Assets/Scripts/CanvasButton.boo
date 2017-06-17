import UnityEngine
import UnityEngine.UI
import UnityEngine.EventSystems

class CanvasButton (MonoBehaviour, IPointerDownHandler): 

    public noteSection as NoteSection

    private prevPos as Vector2


    public def OnPointerDown(ped as PointerEventData):
        localCursorPosition as Vector2
        i as int = 0
        print("down")
        if RectTransformUtility.ScreenPointToLocalPointInRectangle(GetComponent(RectTransform), ped.position, ped.pressEventCamera, localCursorPosition):
            localCursorPosition = Vector2(Mathf.FloorToInt(localCursorPosition.x), Mathf.FloorToInt(localCursorPosition.y))
            if not Input.GetKey(KeyCode.LeftAlt):

                if Input.GetKey(KeyCode.LeftShift):
                    for i in range(prevPos.x, localCursorPosition.x):
                        noteSection.SetNote(i, prevPos.y, 1f)

                for i in range(NoteSizeSetter.noteSizeSetter.noteSize):
                    noteSection.SetNote(localCursorPosition.x +i, localCursorPosition.y, 1f)

                noteSection.PlayNote(localCursorPosition.y, 1f)
                prevPos = localCursorPosition


            else:
                if Input.GetKey(KeyCode.LeftShift):
                    for i in range(prevPos.x, localCursorPosition.x):
                        noteSection.SetNote(i, prevPos.y, 1f)

                for i in range(NoteSizeSetter.noteSizeSetter.noteSize):
                    noteSection.SetNote(localCursorPosition.x +i, localCursorPosition.y, 0f)

                prevPos = localCursorPosition

