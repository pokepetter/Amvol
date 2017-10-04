import UnityEngine
import UnityEngine.UI

public class CopyPaste (MonoBehaviour): 
    
    public notesAsString as string

    private musicScore as MusicScore

    def Start():
        musicScore = Amvol.instance.musicScore
    
    def Update():
        if Input.GetKey(KeyCode.LeftShift) and Input.GetKeyDown(KeyCode.C):
            # print(GUIUtility.systemCopyBuffer)
            # print(Amvol.instance.musicScore.currentNoteSection.notes.ToString())
            if musicScore.currentNoteSection != null:
                noteSection = musicScore.currentNoteSection
                
                notesAsString = "noteSection "
                for x in range(noteSection.notes.GetLength(0)):
                    row = ""
                    for y in range(noteSection.notes.GetLength(1)):
                        row += noteSection.notes[x,y].ToString()

                    notesAsString += row + ","

                # notesAsString += " "

                print(notesAsString)

            GUIUtility.systemCopyBuffer = notesAsString

        if Input.GetKey(KeyCode.LeftShift) and Input.GetKeyDown(KeyCode.V):
            if GUIUtility.systemCopyBuffer.StartsWith("noteSection"):
                print("paste note section")
                notesPart = GUIUtility.systemCopyBuffer[12:]
                noteRows = notesPart.Split(char.Parse(","))
                

                # notesCopy = ((0,0,0), (0,0,0))
                newNotes = matrix(single, noteRows.Length, noteRows[0].Length)
                # for x in range(newNotes.GetLength(0)):
                #     for y in range(newNotes.GetLength(1)):
                #         newNotes[x,y] = 

                for x in range(noteRows.Length):
                    rowArray = noteRows[x].ToCharArray()
                    for y in range(rowArray.Length):
                        newNotes[x,y] = single.Parse(rowArray[y].ToString())


                newNoteSection = musicScore.CreateNoteSection(musicScore.cursor.localPosition, noteRows.Length)
                # newNoteSection.notes = newNotes
                for y in range(newNotes.GetLength(1)):
                    for x in range(newNotes.GetLength(0)):
                        newNoteSection.SetNote(x, y, newNotes[x,y])

            else:
                print(GUIUtility.systemCopyBuffer)
