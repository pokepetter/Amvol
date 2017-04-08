import UnityEngine
import UnityEngine.UI
import System.IO
import System.Collections
import System.Text.RegularExpressions

public class InstrumentButton (MonoBehaviour): 

    public fullPaths as List of string
    public debugPaths as (string) 
    public startNotes as List of int
    public debugStartNotes as (int)
    public attack as single = 0.0f
    public falloff as single = 0.5f
    public looping as bool
    public isDrumSet as bool
    public color as Color
    public words as (string)
    public audioClips as List of AudioClip
    private numberOfAudioClips as int
    private musicScore as MusicScore
    private button as Button

    def Awake():
        button = GetComponent(Button)
        button.onClick.AddListener({SelectFile()})

        startNotes = List of int()
        color = Color.black

        //This gets called by InstrumentList
    public def SetPaths(paths as List of string, startNotesIn as List of int):
        fullPaths = paths
        debugPaths = array(string, fullPaths.Count)
        debugStartNotes = array(int, fullPaths.Count)
        for i in range(fullPaths.Count):
            debugPaths[i] = fullPaths[i]
            debugStartNotes[i] = startNotesIn[i]


        words = paths[0].Split(Char.Parse("-"), Char.Parse("."), Char.Parse("_"))
        for e in words:
            if e[0] == Char.Parse("a"): //attack
                attackString as string = e.Remove(0,1)
                attack = int.Parse(attackString) / 100f

            if e[0] == Char.Parse("f"): //falloff
                falloffString as string = e.Remove(0,1)
                falloff = int.Parse(falloffString) / 100f

            if e == "loop":
                looping = true

            if e == "drumset":
                isDrumSet = true

            if e[0] == Char.Parse("c"): //color
                colorString as string = e.Remove(0,1)
                r as single = single.Parse(colorString.Remove(3,0))
                g as single = single.Parse(colorString.Remove(6,0))
                b as single = single.Parse(colorString.Remove(9,0))
                color = Color(r,g,b)
                transform.GetComponent(Image).color = color

        if color == Color.black:
            color = (Color(Random.Range(0.0f,1.0f),Random.Range(0.0f,1.0f),Random.Range(0.0f,1.0f)) + Color.black + Color.white) /3
            # transform.GetComponent(Image).color = color

    public def SelectFile() as callable:
        StartCoroutine(LoadAudioClips())

    public def LoadAudioClips() as IEnumerator:
        # print(debugPaths.Length)
        audioClips = List of AudioClip()
        audioClips.Clear()
        startNotes.Clear()

        i as int = 0
        while i < debugPaths.Length:
            www  as WWW = WWW("file://" + debugPaths[i])
            audioClip as AudioClip = www.GetAudioClip()
            while not audioClip.isReadyToPlay:
                yield www
            audioClips.Add(audioClip)


            startNotes.Add(debugStartNotes[i])
            i++

        instrumentToReplace = transform.GetComponentInParent(Instrument)
        Amvol.GetInstrumentChanger().ReplaceInstrument(instrumentToReplace, audioClips, startNotes, attack, falloff, looping, isDrumSet, color)

        iL = transform.GetComponentsInParent[of InstrumentList]()
        instrumentName as string = words[0].Remove(0, iL[0].instrumentDirectory.Length+1)
        instrumentName = Regex.Split(instrumentName, "-")[0]
        iL[0].gameObject.name = instrumentName
        iL[0].transform.GetChild(0).GetComponent(Text).text = instrumentName
        iL[0].transform.GetComponent(Image).color = color
        iL[0].OpenList()

        musicScore = Amvol.GetMusicScore()
        for nS in musicScore.noteSections:
            if nS.instrument == iL[0].transform.GetComponent(Instrument):
                nS.GetComponent(Image).color = color