import UnityEngine
import System.Collections
import UnityEngine.UI


class Instrument (MonoBehaviour): 

    public volume as single = 1
    public legatoSpeed as single = 50
    public pan as single
    public attack as single = 0
    public falloff as single = 6
    public attackSoftening as single = 1
    public isDrumSet as bool
    public muted as bool = false
    public instrumentColor as Color

    public audioClips as (AudioClip)

    public attackSlider as CustomSlider
    public falloffSlider as CustomSlider
    public legatoSlider as CustomSlider

    public lastPitch as single = 1
    private maxNotes as int = 8 * 12
    private targetAudioSource as AudioSource
    private k as int = 0
    private notePitches as (double)
    private notePitchDelta as double = 1.05946309436f
    public noteParent as Transform
    private distance as int
    public layoutElement as LayoutElement
    public dynamicVolume as single = 1f
    public dynamicVolumeSlider as Slider 

    private viewAutomation as bool
    private originalGUIHeight as single

    def Start():
        audioClips = array(AudioClip, maxNotes)
        targetAudioSource = transform.GetComponent(AudioSource)
        
        instrumentChanger = Amvol.GetInstrumentChanger()
        i as int = 0
        while i < instrumentChanger.instruments.Count:
            if self == instrumentChanger.instruments[i]:
                break
            i++

        originalGUIHeight = layoutElement.preferredHeight

    # def Update():
    #     if Input.GetKey(KeyCode.Keypad2):
    #         legatoSpeed = 5f
    #     elif Input.GetKey(KeyCode.Keypad3):
    #         legatoSpeed = 10f
    #     elif Input.GetKey(KeyCode.Keypad4):
    #         legatoSpeed = 20f
    #     elif Input.GetKeyDown(KeyCode.Keypad5):
    #         legatoSpeed = 50f
    #     elif Input.GetKey(KeyCode.Keypad6):
    #         legatoSpeed = 100f
    #     elif Input.GetKey(KeyCode.Keypad7):
    #         legatoSpeed = 150f
    #     elif Input.GetKey(KeyCode.Keypad8):
    #         legatoSpeed = 200f
    #     else:
    #         legatoSpeed = 50


    def SetAudioClips(newAudioClips as (AudioClip), notes as (int)):
        for e in audioClips:
            e = null
        for i in range(newAudioClips.Length):
            audioClips[notes[i]] = newAudioClips[i]
            # print(notes[i] +" / "+ newAudioClips[i].ToString())

    def PlayNote(y as int, z as single) as Note:
        if muted:
            return null

        clone = GameObject(y.ToString())
        clone.transform.SetParent(noteParent, false)
        aS = clone.AddComponent(AudioSource)

        //find closest audioclip
        distanceUp = 0
        while y + distanceUp < audioClips.Length:
            if audioClips[y + distanceUp] == null:
                distanceUp++
            else:
                break

        distanceDown = 0
        while y + distanceDown > 0:
            if audioClips[y + distanceDown] == null:
                distanceDown--
            else:
                break

        # print("dist" + " / " + distanceUp + " / " + distanceDown + " / " + distance)
        distance = 0
        if distanceUp < -distanceDown:
            distance = distanceUp
        else:
            distance = distanceDown

        aS.clip = audioClips[y+distance]
        aS.outputAudioMixerGroup = targetAudioSource.outputAudioMixerGroup
        aS.mute = targetAudioSource.mute
        aS.bypassEffects = targetAudioSource.bypassEffects
        aS.bypassReverbZones = targetAudioSource.bypassReverbZones
        aS.playOnAwake = targetAudioSource.playOnAwake
        aS.loop = targetAudioSource.loop 
        aS.spatialBlend = targetAudioSource.spatialBlend
        aS.spread = targetAudioSource.spread
        aS.volume = 0f
        aS.panStereo = pan
        # if aS.loop:
        if legatoSpeed < 50:
            aS.pitch = lastPitch
        else:
            aS.pitch = Mathf.Pow(1/notePitchDelta, distance)

        aL = clone.AddComponent(AudioLerper)
        aL.audioSource = aS

        note = clone.AddComponent(Note)
        lastPitch = Mathf.Pow(1/notePitchDelta, distance)
        note.targetPitch = lastPitch
        note.audioSource = aS
        note.audioLerper = aL
        note.instrument = self
        # if exponentialVelocity:
        z *= z
        note.Play(z * volume * dynamicVolume)
        note.noteNumber = y
        return note

    def StopPlayingNote(y as int):
        # if targetAudioSource.loop:
        notes = noteParent.GetComponentsInChildren[of Note]()
        for n in notes:
            if n.noteNumber == y:
                n.Stop()
    

    def SetVolume(newVolume as single):
        volume = newVolume

    def SetDynamicVolume(newVolume as single):
        dynamicVolume = newVolume
        audioLerpers = noteParent.GetComponentsInChildren[of AudioLerper]()
        for l in audioLerpers:
            l.instrumentMultiplier = dynamicVolume
            
    def SetPan(newPan as single):
        pan = newPan

    def LoadAttack(newAttack as single):
        attack = newAttack
        attackSlider.SetValue(newAttack, false)

    def SetAttack(newAttack as single):
        attack = newAttack

    def LoadFalloff(newFalloff as single):
        falloff = newFalloff
        falloffSlider.SetValue(newFalloff, false)

    def SetFalloff(newFalloff as single):
        falloff = newFalloff

    def LoadLegatoSpeed(newLegatoSpeed as single):
        legatoSpeed = newLegatoSpeed
        legatoSlider.SetValue(newLegatoSpeed, false)

    def SetLegatoSpeed(newLegatoSpeed as single):
        legatoSpeed = newLegatoSpeed

    def SetLastPitch(pitch as single):
        lastPitch = pitch

    def Mute(newMuted as bool):
        muted = newMuted

    def ToggleviewAutomation():
        if viewAutomation:
            viewAutomation = false
            layoutElement.preferredHeight = originalGUIHeight
        else:
            viewAutomation = true
            layoutElement.preferredHeight = originalGUIHeight + 1f

    def Destroy():
        instrumentChanger = Amvol.instance.instrumentChanger
        instrumentChanger.instruments.Remove(self)
        if instrumentChanger.instruments.Count > 0:
            instrumentChanger.currentInstrument = instrumentChanger.instruments[0]
        else:
            instrumentChanger.currentInstrument = null

        if instrumentChanger.instrumentIndex > 0:
            instrumentChanger.instrumentIndex--

        Destroy(gameObject)