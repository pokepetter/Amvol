import UnityEngine
import UnityEngine.UI

public class SetBPM (MonoBehaviour): 
    
    public musicScore as MusicScore
    public inputFieldText as Text

    def SetBPM():
    	SetBPM(int.Parse(inputFieldText.text))

    def SetBPM(newBPM as int):
        musicScore.SetBPM(newBPM)