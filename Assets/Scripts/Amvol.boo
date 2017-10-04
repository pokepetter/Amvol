import UnityEngine

public class Amvol (MonoBehaviour): 
    
    public musicScore as MusicScore
    public FileBrowser as FileBrowser
    public scaleChanger as ScaleChanger
    public keyboardPlayer as KeyboardPlayer
    public instrumentChanger as InstrumentChanger
    public saveSystem as SaveSystem

    public static instance as Amvol

    def Awake():
        instance = self
        Screen.SetResolution(Screen.currentResolution.width-100, Screen.currentResolution.height-100, false)

    public static def GetMusicScore() as MusicScore:
        return instance.musicScore

    public static def GetFileBrowser() as FileBrowser:
        return instance.FileBrowser

    public static def GetScaleChanger() as ScaleChanger:
        return instance.scaleChanger

    public static def GetKeyboardPlayer() as KeyboardPlayer:
        return instance.keyboardPlayer

    public static def GetInstrumentChanger() as InstrumentChanger:
        return instance.instrumentChanger

    public static def GetSaveSystem() as SaveSystem:
        return instance.saveSystem
