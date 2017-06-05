import UnityEngine

class InstrumentChanger (MonoBehaviour): 

    public musicScore as MusicScore
    public scaleChanger as ScaleChanger
    public instruments as List of Instrument
    public currentInstrument as Instrument
    public keys as (KeyCode)
    public instrumentIndex as int
    public instrumentPrefab as GameObject
    public instrumentsParent as Transform
    public addInstrumentButton as Transform
    public instrumentToChangeTo as Instrument
    private i as int = 0
    private j as int = 0
    private newInstrument as Instrument
    
    def Awake():
        Initialize()

    def Initialize():
        keys = (KeyCode.Keypad0, KeyCode.Keypad1, KeyCode.Keypad2, KeyCode.Keypad3, KeyCode.Keypad4, KeyCode.Keypad5, KeyCode.Keypad6, KeyCode.Keypad7, KeyCode.Keypad8, KeyCode.Keypad9) 
        instruments = List of Instrument()
        AddInstrumentFromButton()


    def Start():
        musicScore = Amvol.GetMusicScore()
        scaleChanger = Amvol.GetScaleChanger()

    def Update():

        if Input.GetKeyDown(KeyCode.KeypadPlus):
            if instrumentIndex < instruments.Count-1:
                SetCurrentInstrument(instruments[instrumentIndex+1])
        if Input.GetKeyDown(KeyCode.KeypadMinus):
            if instrumentIndex > 0:
                SetCurrentInstrument(instruments[instrumentIndex-1])

    def AddInstrumentFromButton():
        instrument = AddInstrument()
        instrumentList = instrument.transform.GetComponent(InstrumentList)
        instrumentList.OpenList()
        instrumentList.content.transform.GetChild(0).GetComponent(InstrumentButton).SelectFile()

    def AddInstrument() as Instrument:
        newInstrument as Instrument = Instantiate(instrumentPrefab).GetComponent(Instrument)
        newInstrument.transform.SetParent(instrumentsParent, false) 
        addInstrumentButton.SetParent(null, false)
        addInstrumentButton.SetParent(instrumentsParent, false)
        instruments.Add(newInstrument)
        SetCurrentInstrument(newInstrument)
        return newInstrument


    def SetCurrentInstrument(instrument as Instrument):
        i = 0
        for instrument in instruments:
            # print(instrument.gameObject.name)
            instrument.transform.GetComponent(Outline).enabled = false
        instrument.transform.GetComponent(Outline).enabled = true

        currentInstrument = instrument

    def ReplaceInstrument(audioClips as List of AudioClip, startNotes as List of int, attack as single, falloff as single, loop as bool, isDrumSet as bool, color as Color):
        ReplaceInstrument(currentInstrument, audioClips, startNotes, attack, falloff, loop, isDrumSet, color)

    def ReplaceInstrument(targetInstrument as Instrument, audioClips as List of AudioClip, startNotes as List of int, attack as single, falloff as single, loop as bool, isDrumSet as bool, color as Color):
        targetInstrument.transform.GetComponent(AudioSource).clip = audioClips[0]
        targetInstrument.transform.GetComponent(AudioSource).loop = loop
        targetInstrument.SetLerpSpeed(attack, falloff)
        targetInstrument.isDrumSet = isDrumSet
        targetInstrument.instrumentColor = color
        targetInstrument.SetAudioClips(array(AudioClip, audioClips), array(int, startNotes))  


    def PlayNote(y as int, z as single):
        if not currentInstrument.isDrumSet:
            y = scaleChanger.NoteOffset(y, false)
        currentInstrument.PlayNote(y, z)


    def StopPlayingNote(y as int):
        if not currentInstrument.isDrumSet:
            y = scaleChanger.NoteOffset(y, false)
        currentInstrument.StopPlayingNote(y)


    def ClearAllInstruments():
        if instruments != null:
            instruments.Clear()
        currentInstrument = null
        instrumentIndex = 0
        for instrument in instrumentsParent.GetComponentsInChildren(Instrument):
            Destroy(instrument.gameObject)