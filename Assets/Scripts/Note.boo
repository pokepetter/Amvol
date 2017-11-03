import UnityEngine
import System.Collections

class Note (MonoBehaviour): 
    
    public audioSource as AudioSource
    public audioLerper as AudioLerper
    public targetPitch as single
    public instrument as Instrument
    public noteNumber as int
    public originalVolume as single

    private attackSoftening as single
    private isStopping as bool

    public def Play(newVolume as single):
        # print("play")
        if audioLerper == null:
            print("audioLerper is null")
        # audioLerper.LerpVolume(0, instrument.falloff)
        attackSoftening = instrument.attackSoftening * (instrument.attack * (1-newVolume))

        audioLerper.LerpVolume(newVolume, instrument.attack + attackSoftening)
        audioSource.Play()

    public def Stop():
        if isStopping:
            pass
        else:
            isStopping = true
            audioLerper.LerpVolume(0, instrument.falloff)
            audioSource.pitch = targetPitch
            Destroy(gameObject, instrument.falloff)

    def FixedUpdate(): 
        if instrument != null and audioLerper != null:
            if instrument.legatoSpeed < 49:
                audioSource.pitch = Mathf.Lerp(audioSource.pitch, targetPitch, Time.fixedDeltaTime * instrument.legatoSpeed)
            else:
                audioSource.pitch = targetPitch
