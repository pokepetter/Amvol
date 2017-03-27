import UnityEngine
import UnityEngine.UI
import System.IO
import System.Collections

public class ScaleButton (MonoBehaviour): 

    public scalePattern as string
    private button as Button

    def Awake():
        button = GetComponent(Button)
        button.onClick.AddListener({SelectScale()})


    public def SelectScale() as callable:
        Amvol.GetScaleChanger().SetScale(scalePattern)