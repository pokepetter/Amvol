import UnityEngine
import UnityEngine.UI

public class CopyPaste (MonoBehaviour): 
    
    public notesAsString as string
    
    def Update():
        if Input.GetKey(KeyCode.LeftShift) and Input.GetKeyDown(KeyCode.C):
            # print(GUIUtility.systemCopyBuffer)
            # print(Amvol.Amvol.musicScore.currentNoteSection.notes.ToString())
            if Amvol.Amvol.musicScore.currentNoteSection != null:
                noteSection = Amvol.Amvol.musicScore.currentNoteSection
                
                notesAsString = "noteSection "
                for note in noteSection.notes:
                    notesAsString += note.ToString()

                # notesAsString += " "

                print(notesAsString)

            GUIUtility.systemCopyBuffer = notesAsString

        if Input.GetKey(KeyCode.LeftShift) and Input.GetKeyDown(KeyCode.V):
            if GUIUtility.systemCopyBuffer.StartsWith("noteSection"):
                print("paste note section")
                notesPart = GUIUtility.systemCopyBuffer[12:]
                print(notesPart)
            else:
                print(GUIUtility.systemCopyBuffer)
