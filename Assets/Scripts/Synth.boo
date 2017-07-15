import UnityEngine
# import UnityEditor
import System.Collections

class Synth (MonoBehaviour): 
    
    public position as single = 0f
    public samplerate as single = 44100f
    public frequency as single= 440f
    public amplitude as single = 1f
    private i as int = 0
    private hasRecorded as bool
    private allDataSources as (single)
    private aud as AudioSource
    public curve as AnimationCurve

    def Start():
        allDataSources = array(single, 0)
        myClip as AudioClip = AudioClip.Create("Synth", samplerate * 2, 1, samplerate, true, OnAudioRead, OnAudioSetPosition)
        aud = GetComponent(AudioSource)
        aud.clip = myClip
        aud.Play()

    
    def OnAudioRead(data as (single)):
        i = 0
        while i < data.Length:
            data[i] = Mathf.Sin(position * frequency) * amplitude
            position++
            i++
        allDataSources += data

    def OnAudioSetPosition(newPosition as int):
        position = newPosition

    def Update():
        amplitude = curve.Evaluate(Time.time * 0.1f)
        transform.position.y = Mathf.Sin((Time.fixedTime * 0.1f) * frequency) * amplitude



    # class SynthEditor (Editor):
    #     curve as AnimationCurve = AnimationCurve.Linear(0,0,10,10)

    #     def OnGUI():
    #         curve = EditorGUILayout.CurveField(curve)