import UnityEngine
import System.Collections

class VolumeLerper (MonoBehaviour): 

    public lerpPitch as bool = false
    public newPitch as single
    private audioSource as AudioSource

    def Awake():
        audioSource = GetComponent(AudioSource)
    
    def FixedUpdate():
        audioSource.volume = Mathf.Lerp(audioSource.volume, 0, Time.deltaTime * 1f)

        if lerpPitch:
            audioSource.pitch = Mathf.Lerp(audioSource.pitch, newPitch, Time.deltaTime * 20f)
        
    public def SetPitch(incPitch as single):
        newPitch = incPitch
