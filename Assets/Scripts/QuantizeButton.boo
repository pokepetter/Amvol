    import UnityEngine
import UnityEngine.UI

class QuantizeButton (MonoBehaviour): 
    
    public musicScore as MusicScore
    public snap as int

    public def Quantize():
        # for noteSection in musicScore.noteSections:
        # 	noteSection.Quantize(snap)
        musicScore.currentNoteSection.Quantize(snap)


    public def SetSnap(newSnap as int):
    	snap = newSnap