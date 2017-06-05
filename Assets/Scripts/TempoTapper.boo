import UnityEngine
import UnityEngine.UI

public class TempoTapper (MonoBehaviour): 
    
    public tempo as single = 60
    public tempTime as single
    public deltaTime as single
    public started as bool
    public deltaTapTimes as (single)

    public tempoText as Text
    public setBPM as SetBPM

    public i as int

    def Awake():
        deltaTapTimes = array(single, 4)

    def Update():
        if Input.GetKeyDown(KeyCode.LeftControl):
            Click()

    public def Click():
        if not started:
            tempTime = Time.fixedTime
            started = true
        else:
            print(i)
            deltaTapTimes[i] = Time.fixedTime - tempTime
            tempTime = Time.fixedTime
    
            i++

            if i >= 4:
                i = 0


        tempo = deltaTapTimes[0] + deltaTapTimes[1] + deltaTapTimes[2] + deltaTapTimes[3]
        tempo /= 4
        tempo = 60f /tempo

        tempoText.text = tempo.ToString()


    public def ApplyTempo():
        setBPM.SetBPM(tempo)