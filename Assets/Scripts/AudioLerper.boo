import UnityEngine

class AudioLerper (MonoBehaviour): 
    
    public audioSource as AudioSource
    public elapsedTime as single
    public t as single
    public instrumentMultiplier as single = 1f
    public noteSectionMultiplier as single = 0.5f
    public newVolume as single = 0f


    def LerpVolume(targetValue as single, duration as single):
        StopAllCoroutines()

        if duration == 0f:
            newVolume = targetValue
        else:    
            StartCoroutine(LerpVolumeRoutine(targetValue, duration))

    private def LerpVolumeRoutine(targetValue as single, duration as single) as IEnumerator:
        elapsedTime = 0f
        t = 0f
        startValue as single = newVolume
        while elapsedTime < duration:
            yield WaitForSeconds(0.05f)
            elapsedTime += 0.05f
            t = elapsedTime/duration
            t = Mathf.Sin(t * Mathf.PI * 0.5f)
            newVolume = Mathf.Lerp(startValue, targetValue, t)
        yield

    def Update():
        audioSource.volume = newVolume * instrumentMultiplier * noteSectionMultiplier
