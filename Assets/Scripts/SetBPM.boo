import UnityEngine
import UnityEngine.UI

public class SetBPM (MonoBehaviour): 
    
    public musicScore as MusicScore
    public inputFieldText as Text

    def Awake():
    	SetBPM(60f)

    def SetBPM():
    	SetBPM(single.Parse(inputFieldText.text))

    def SetBPM(newBPM as single):
        musicScore.SetBPM(newBPM)