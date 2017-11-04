import UnityEngine
import UnityEngine.UI
import MidiJack

class KeyboardPlayer (MonoBehaviour):

    public pianoRoll as Transform
    public noteOverlay as GameObject
    public noteOverlay1 as GameObject
    public noteOverlayInsideNoteSection as RectTransform
    public usingMidiKeyboard as bool = true
    public blockInput as bool

    private musicScore as MusicScore
    private instrumentChanger as InstrumentChanger
    private keys as (KeyCode)
    private noteNames as (string)
    private overlays as (GameObject)
    private overlays1 as (GameObject)
    private i as int = 0
    private j as int = 0
    private k as int
    private octaveOffset as int
    private octaveLength as int

    private lastVolumeKnob as single
    private rand as single

    def Awake():
        keys = (KeyCode.Z, KeyCode.X, KeyCode.C, KeyCode.V, KeyCode.B, KeyCode.N, KeyCode.M,
        KeyCode.A, KeyCode.S, KeyCode.D, KeyCode.F, KeyCode.G, KeyCode.H, KeyCode.J, KeyCode.K, KeyCode.L,
        KeyCode.Q, KeyCode.W, KeyCode.E, KeyCode.R, KeyCode.T, KeyCode.Y, KeyCode.U, KeyCode.I, KeyCode.O, KeyCode.P,
        KeyCode.Alpha1, KeyCode.Alpha2, KeyCode.Alpha3, KeyCode.Alpha4, KeyCode.Alpha5, KeyCode.Alpha6,
        KeyCode.Alpha7, KeyCode.Alpha8, KeyCode.Alpha9)

        noteNames = ("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B","C", "C#")

        InstantiateNoteOverlays()


    def Start():
        musicScore = Amvol.GetMusicScore()
        instrumentChanger = Amvol.GetInstrumentChanger()
        UpdateNoteNames()

    def Update():
        if Input.GetKeyDown(KeyCode.Comma):
            octaveOffset--
            octaveLength = Amvol.GetScaleChanger().GetScaleLength()

        if Input.GetKeyDown(KeyCode.Period):
            octaveOffset++
            octaveLength = Amvol.GetScaleChanger().GetScaleLength()

        if Input.GetKey(KeyCode.LeftShift) == false and blockInput == false:
            while i < keys.Length:
                if Input.GetKeyDown(keys[i]):
                    instrumentChanger.PlayNote(i + (octaveOffset * octaveLength), Random.Range(0.8f, 0.9f))
                    overlays[i + (octaveOffset * octaveLength)].SetActive(true)
                    overlays1[i + (octaveOffset * octaveLength)].SetActive(true)
                    if musicScore.recording and musicScore.playing:
                        musicScore.currentNoteSection.StartNote(i + (octaveOffset * octaveLength), 1f)

                if Input.GetKeyUp(keys[i]):
                    instrumentChanger.StopPlayingNote(i + (octaveOffset * octaveLength))
                    overlays[i + (octaveOffset * octaveLength)].SetActive(false)
                    overlays1[i + (octaveOffset * octaveLength)].SetActive(false)
                    if musicScore.recording and musicScore.playing:
                        musicScore.currentNoteSection.StopNote(i + (octaveOffset * octaveLength))
                i++
            if i >= keys.Length:
                i = 0
                j = 0


        if usingMidiKeyboard == true:
            for k in range(128):
                if MidiMaster.GetKeyDown(k):
                    /*rand = Random.Range(-1f, 1f)
                    print(rand)*/
                    instrumentChanger.PlayNote(k,MidiMaster.GetKey(k))
                    /*if rand > 0f:
                        instrumentChanger.PlayNote(k+2,MidiMaster.GetKey(k))
                    else:
                        instrumentChanger.PlayNote(k+3,MidiMaster.GetKey(k))*/

                    overlays[k].SetActive(true)
                    overlays1[k].SetActive(true)
                    if musicScore.recording and musicScore.playing:
                        musicScore.currentNoteSection.StartNote(k,MidiMaster.GetKey(k))

                if MidiMaster.GetKeyUp(k):
                    instrumentChanger.StopPlayingNote(k)
                    if rand > 0:
                        instrumentChanger.StopPlayingNote(k+2)
                    else:
                        instrumentChanger.StopPlayingNote(k+3)

                    if musicScore.recording and musicScore.playing:
                        musicScore.currentNoteSection.StopNote(k)
                    overlays[k].SetActive(false)
                    overlays1[k].SetActive(false)


            if MidiMaster.GetKnob(7, 0f) != lastVolumeKnob:
                lastVolumeKnob = MidiMaster.GetKnob(7, 0f)
                instrumentChanger.currentInstrument.dynamicVolumeSlider.value = lastVolumeKnob


    public def InstantiateNoteOverlays():
        overlays = array(GameObject, 128)
        overlays1 = array(GameObject, 128)
        
        for i in range(128):
            overlayElement = Instantiate(noteOverlay)
            overlayElement.transform.SetParent(pianoRoll, false)
            overlayElement.transform.localPosition = Vector2(0, i)
            rectTransform as RectTransform = overlayElement.GetComponent(RectTransform)
            rectTransform.anchorMin = Vector2(0f, 0f)
            rectTransform.anchorMax = Vector2(1f, 0f)
            overlays[i] = overlayElement.transform.GetChild(0).gameObject

            //overlays inside note section
            overlayElement1 = Instantiate(noteOverlay1)
            overlayElement1.transform.SetParent(noteOverlayInsideNoteSection, false)
            overlayElement1.gameObject.SetActive(false)
            # rectTransform = overlayElement1.AddComponent(RectTransform)
            # rectTransform.anchorMin = Vector2(0f, 0f)
            # rectTransform.anchorMax = Vector2(1f, 0f)

            overlayElement1.transform.localPosition = Vector2(0, i)
            overlays1[i] = overlayElement1

    public def UpdateNoteNames():
        scaleChanger = Amvol.GetScaleChanger()
        scaleLength as int = scaleChanger.GetScaleLength()

        for i in range(overlays.Length):
            # print(scaleChanger.NoteOffset(i - scaleChanger.noteOffset, true) +" / ")

            if i % scaleLength == 0:
                overlays[i].SetActive(true)
                overlays[i].GetComponent(Image).color = Color(1,1,1,0.05)
            else:
                overlays[i].SetActive(false)
                overlays[i].GetComponent(Image).color = Color(0.3, 0.5, 0.7, 0.5)
            overlays[i].transform.parent.GetChild(1).GetComponent(Text).text = noteNames[scaleChanger.NoteOffset(i, true)] + (i/scaleLength).ToString()
