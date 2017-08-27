import UnityEngine
import UnityEngine.UI

class SaveButton (MonoBehaviour):

    public inputField as Text
    public folderField as Text
    public fullPath as string
    public showOverwriteWarning as bool
    public fileBrowser as GameObject
    public warningWindow as GameObject
    private button as Button

    def Awake():
        button = GetComponent(Button)
        button.onClick.AddListener({Save()})

    private def Save() as callable:
        fileName = inputField.text
        if not fileName.EndsWith(".png"):
            fileName += ".png"

        filePath = Path.Combine(folderField.text, fileName)
        if showOverwriteWarning and File.Exists(filePath):
            print("overwrite warning")
            warningWindow.SetActive(true)
        else:
            Amvol.GetSaveSystem().Save(Path.Combine(folderField.text, fileName))
            fileBrowser.SetActive(false)
            warningWindow.SetActive(false)
