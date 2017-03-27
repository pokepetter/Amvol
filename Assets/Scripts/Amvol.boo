import UnityEngine

public class Amvol (MonoBehaviour): 
    
    public musicScore as MusicScore
    public FileBrowser as FileBrowser
    public scaleChanger as ScaleChanger
    public keyboardPlayer as KeyboardPlayer
    public instrumentChanger as InstrumentChanger
    public saveSystem as SaveSystem

    public static Amvol as Amvol

    def Awake():
        Amvol = self

    public static def GetMusicScore() as MusicScore:
        return Amvol.musicScore

    public static def GetFileBrowser() as FileBrowser:
        return Amvol.FileBrowser

    public static def GetScaleChanger() as ScaleChanger:
        return Amvol.scaleChanger

    public static def GetKeyboardPlayer() as KeyboardPlayer:
        return Amvol.keyboardPlayer

    public static def GetInstrumentChanger() as InstrumentChanger:
        return Amvol.instrumentChanger

    public static def GetSaveSystem() as SaveSystem:
        return Amvol.saveSystem
