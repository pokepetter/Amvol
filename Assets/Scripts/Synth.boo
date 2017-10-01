import UnityEngine
import System.Math

public class Synth (MonoBehaviour):
      // un-optimized version
    public frequency as single = 220
    public gain as single = 0.05
    public vibrato as single
    public vibratoSpeed as single = 20f
    public volume as AnimationCurve
    public waveOffset as AnimationCurve
    public pitchOffset as AnimationCurve
    public leftRight as AnimationCurve

    public indicator as RectTransform

    private increment as single
    private phase as single
    private sampling_frequency as single = 44100
    public t as single
    private originalFrequency as single

    def Awake():
        originalFrequency = frequency
        t = 0


    def OnAudioFilterRead(data as (single), channels as int):
        t++
        print(t)
        /*return*/
        // update increment in case frequency has changed
        increment = frequency * 2 * Math.PI / sampling_frequency
        for i in range (data.Length):
            phase += increment
            /*print(frequency / sampling_frequency)*/
            /*gain *= volume.Evaluate((i / data.Length))*/
            frequency = originalFrequency + (Mathf.Sin(t * vibratoSpeed * 0.01f) * vibrato)
            data[i] = gain*Math.Sin(phase)
        // if we have stereo, we copy the mono data to each channel
          /*if channels == 2:
            data[i + 1] = data[i];*/
            if phase > 2 * Math.PI:
                phase = 0

    def Update():
        if Input.GetKeyDown(KeyCode.W):
            originalFrequency = 110f
            StartCoroutine(LerpRoutine())
        if Input.GetKeyDown(KeyCode.E):
            originalFrequency = 220f
            StartCoroutine(LerpRoutine())


    def LerpRoutine() as IEnumerator:
        gain = .5f
        vibratoSpeed = 0f
        for i in range(50):
            yield WaitForSeconds(0.1f)
            gain += (.5f / 50f)
            vibratoSpeed += 1f
