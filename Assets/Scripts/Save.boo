import UnityEngine

public class Save (MonoBehaviour): 
    
    public toggleButton as ToggleButton 


    def Click():
        saveSystem = Amvol.GetSaveSystem()

        if saveSystem.header.text == "" or saveSystem.header.text == "Amvol":
            toggleButton.Toggle()

        else:
            saveSystem.Save(saveSystem.header.text)
