import UnityEngine
import UnityEngine.UI
import UnityEngine.EventSystems

class CanvasButton (MonoBehaviour, IPointerDownHandler):

    public noteSection as NoteSection


    public def OnPointerDown(ped as PointerEventData):
        StartCoroutine(PointerDownRoutine(ped))

    private def PointerDownRoutine(ped as PointerEventData) as IEnumerator:
        localCursorPosition as Vector2
        i as int = 0

        if RectTransformUtility.ScreenPointToLocalPointInRectangle(GetComponent(RectTransform), ped.position, ped.pressEventCamera, localCursorPosition):
            noteSize = NoteSizeSetter.noteSizeSetter.noteSize
            localCursorPosition = Vector2(
                Mathf.FloorToInt(localCursorPosition.x / noteSize) * noteSize,
                Mathf.FloorToInt(localCursorPosition.y))

            if ped.button == PointerEventData.InputButton.Left:
                noteSection.Stop()

                if noteSize > 1:
                    //if there's a note already there, toggle between continuous note and non-continuous

                    noteAlreadyThere = true
                    for i in range(noteSize-2):
                        if not noteSection.notes[localCursorPosition.x +i, localCursorPosition.y] > 0f:
                            noteAlreadyThere = false
                            break

                    if noteAlreadyThere:
                        if localCursorPosition.x + noteSize-1 <= noteSection.sectionLength and noteSection.notes[localCursorPosition.x + noteSize-1, localCursorPosition.y] > 0f:
                            hasEndGap = false
                        else:
                            hasEndGap = true

                    print("note alrady there: " + noteAlreadyThere + ", has end gap: " + hasEndGap)
                    noteSection.PlayNote(localCursorPosition.y, .5f)

                    if noteAlreadyThere and hasEndGap:
                        noteSection.SetNote(localCursorPosition.x + noteSize-1, localCursorPosition.y, 1f)
                    else:
                        for i in range(noteSize-1):
                            noteSection.SetNote(localCursorPosition.x +i, localCursorPosition.y, 1f)

                        noteSection.SetNote(localCursorPosition.x + noteSize-1, localCursorPosition.y, 0f)

                else:
                    for i in range(noteSize):
                        noteSection.SetNote(localCursorPosition.x +i, localCursorPosition.y, 1f)
                        noteSection.PlayNote(localCursorPosition.y, .5f)


                //stop note after a while
                yield WaitForSeconds(0.05)
                noteSection.Stop()


            elif ped.button == PointerEventData.InputButton.Right:
                for i in range(NoteSizeSetter.noteSizeSetter.noteSize):
                    noteSection.SetNote(localCursorPosition.x +i, localCursorPosition.y, 0f)
