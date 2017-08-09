import UnityEngine
import UnityEngine.UI
import MidiJack

class KeyboardPlayer (MonoBehaviour):

    public pianoRoll as Transform
    public noteOverlay as GameObject
    public usingMidiKeyboard as bool = true
    public blockInput as bool

    private musicScore as MusicScore
    private instrumentChanger as InstrumentChanger
    private keys as (KeyCode)
    private noteNames as (string)
    private overlays as (GameObject)
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

        noteNames = ("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")

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
                    if musicScore.recording and musicScore.playing:
                        musicScore.currentNoteSection.StartNote(i + (octaveOffset * octaveLength), 1f)

                if Input.GetKeyUp(keys[i]):
                    instrumentChanger.StopPlayingNote(i + (octaveOffset * octaveLength))
                    overlays[i + (octaveOffset * octaveLength)].SetActive(false)
                    if musicScore.recording and musicScore.playing:
                        musicScore.currentNoteSection.StopNote(i + (octaveOffset * octaveLength))
                i++
            if i >= keys.Length:
                i = 0
                j = 0


        if usingMidiKeyboard == true:
            while k < 128:
                if MidiMaster.GetKeyDown(k):
                    /*rand = Random.Range(-1f, 1f)
                    print(rand)*/
                    instrumentChanger.PlayNote(k,MidiMaster.GetKey(k))
                    /*if rand > 0f:
                        instrumentChanger.PlayNote(k+2,MidiMaster.GetKey(k))
                    else:
                        instrumentChanger.PlayNote(k+3,MidiMaster.GetKey(k))*/

                    overlays[k].SetActive(true)
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
                k++

            if k >= 128:
                k = 0


            if MidiMaster.GetKnob(7, 0f) != lastVolumeKnob:
                lastVolumeKnob = MidiMaster.GetKnob(7, 0f)
                instrumentChanger.currentInstrument.dynamicVolumeSlider.value = lastVolumeKnob


    public def InstantiateNoteOverlays():
        overlays = array(GameObject, 128)
        k as int = 0
        while k < 128:
            overlayElement = Instantiate(noteOverlay)
            overlayElement.transform.SetParent(pianoRoll, false)
            overlayElement.transform.localPosition= Vector3(0,k,0)
            rectTransform as RectTransform = overlayElement.GetComponent(RectTransform)
            rectTransform.anchorMin = Vector2(0f, 0f)
            rectTransform.anchorMax = Vector2(1f, 0f)
            overlays[k] = overlayElement.transform.GetChild(0).gameObject
            k++

    public def UpdateNoteNames():
        scaleChanger = Amvol.GetScaleChanger()
        scaleLength as int = scaleChanger.GetScaleLength()

        e as int = 0
        while e < overlays.Length:
            # print(scaleChanger.NoteOffset(e - scaleChanger.noteOffset, true) +" / ")

            if e % scaleLength == 0:
                overlays[e].SetActive(true)
                overlays[e].GetComponent(Image).color = Color(1,1,1,0.05)
            else:
                overlays[e].SetActive(false)
                overlays[e].GetComponent(Image).color = Color(0.3, 0.5, 0.7, 0.5)
            overlays[e].transform.parent.GetChild(1).GetComponent(Text).text = noteNames[scaleChanger.NoteOffset(e, true)] + (e/scaleLength).ToString()
            e++
