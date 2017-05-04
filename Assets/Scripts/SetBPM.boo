import UnityEngine
import UnityEngine.UI

public class SetBPM (MonoBehaviour): 
    
    public musicScore as MusicScore
    public inputFieldText as Text


    def SetBPM():
        musicScore.SetBPM(int.Parse(inputFieldText.text))