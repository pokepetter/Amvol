import UnityEngine

class PaintBucket (MonoBehaviour): 
    
    private instrument as Instrument
    private instrumentChanger as InstrumentChanger
    private button as Button


    def Start():
        instrument = transform.GetComponentInParent(Instrument)
        instrumentChanger = Amvol.GetInstrumentChanger()
        button = GetComponent(Button)
        button.onClick.AddListener({OnClick()})
        
    public def OnClick():
        instrumentChanger.instrumentToChangeTo = instrument