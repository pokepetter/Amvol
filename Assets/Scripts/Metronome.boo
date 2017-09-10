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
        noteSection = musicScore.CreateMetronomeNoteSection(Vector2(0, 0), 64)
        noteSection.transform.parent = transform
        noteSection.transform.localPosition.y = -4
        Destroy(noteSection.transform.GetComponent(DerpLerp))
        noteSection.transform.localScale = Vector2.zero
        noteSection.instrument = instrument
        noteSection.loops = 100
        instrument.audioClips[0] = audioSource.clip
        for x in range(0, 64, 16):
            for i in range(8):
                noteSection.SetNote(x+i, 16, 1f)


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
