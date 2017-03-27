import UnityEngine
import UnityEngine.UI

class Metronome (MonoBehaviour): 
        
    public audioSource as AudioSource
    public musicScore as MusicScore
    public instrument as Instrument
    public playing as bool
    public delayLeft as int
    public currentTime as single
    public state as MetronomeState
    public stateText as Text

    private noteSection as NoteSection


    def Start():
        noteSection = musicScore.CreateMetronomeNoteSection(Vector2(0, 0), 128)
        noteSection.transform.localPosition = Vector2.zero
        Destroy(noteSection.transform.GetComponent(DerpLerp))
        noteSection.transform.localScale = Vector2.zero
        noteSection.instrument = instrument
        noteSection.loops = 100
        instrument.audioClips[16] = audioSource.clip
        # noteSection.ZoomOut() //this is a hack, it zooms in for som reason.
        x = 0
        while x < 128:
            for i in range(16):
                noteSection.SetNote(x+i, 16, 1f)
            x += 32


    def Update():
        
        if state == MetronomeState.MuteOnInput:
            if musicScore.playing:
                if Input.anyKeyDown:
                    # print("mute")
                    instrument.volume = 0f
            else:
                instrument.volume = 1f


    def ToggleMetronome():
        //infinite, four, muted
        if state == MetronomeState.Infinite:
            state = MetronomeState.MuteOnInput
            stateText.text = "Mute on input"
        elif state == MetronomeState.MuteOnInput:
            state = MetronomeState.Muted
            instrument.volume = 0f
            stateText.text = "Muted"
        elif state == MetronomeState.Muted:
            state = MetronomeState.Infinite
            instrument.volume = 1f
            stateText.text = "Infinite"

    public enum MetronomeState:
        MuteOnInput
        Muted
        Infinite