import UnityEngine
import UnityEngine.UI

class SnapSettingsButton (MonoBehaviour): 
    
    public snapTo as int

    def Awake():
    	transform.localScale = Vector3.one

    def SetSnapValue(snapValue as int):
        snapTo = snapValue

    def OnClick():
        print(snapTo)
        Amvol.GetMusicScore().snap = snapTo


