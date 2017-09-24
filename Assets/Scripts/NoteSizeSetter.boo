import UnityEngine
import System.Collections

class NoteSizeSetter (MonoBehaviour):

    public noteSize as int = 1
    public stopButton as GameObject
    public repeatNoteSection as bool
    public noteButtons as (Image)

    private originalColor as Color
    private selectedColor as Color

    public static noteSizeSetter as NoteSizeSetter

    def Awake():
        noteSizeSetter = self


    def SetRepeatNoteSection(repeat as bool):
        repeatNoteSection = repeat 