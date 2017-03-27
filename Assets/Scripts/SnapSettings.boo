    import UnityEngine
import UnityEngine.UI

class SnapSettings (MonoBehaviour): 
    
    public list as Transform
    public snapSettingsButton as GameObject

    public def Awake():
        snapOptions as List = [16, 8, 4, 2, 1]
        snapOptionNames as List = ["1/8", "1/16", "1/32", "1/64", "1/128"]

        for i in range(snapOptions.Count):
            clone = Instantiate(snapSettingsButton)
            clone.transform.SetParent(list, false)
            clone.GetComponent(SnapSettingsButton).SetSnapValue(snapOptions[i])
            clone.GetComponent(ToggleButton).toggledGraphic = snapSettingsButton.transform
            clone.GetComponentInChildren(Text).text = snapOptionNames[i]


