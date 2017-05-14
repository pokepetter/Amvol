import UnityEngine
import System.Collections

class NoteSizeSetter (MonoBehaviour): 
    
    public noteSize as int = 1

    public static noteSizeSetter as NoteSizeSetter

    def Awake():
        noteSizeSetter = self

    def SetNoteSize(size as int):
        noteSizeSetter.noteSize = size