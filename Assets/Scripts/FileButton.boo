import UnityEngine
import UnityEngine.UI

class FileButton (MonoBehaviour): 

    private fullPath as string
    private button as Button
    public fileBrowser as FileBrowser

    def Awake():
        button = GetComponent(Button)
        button.onClick.AddListener({SelectFile()})

    public def SetPath(path as string):
        fullPath = path

    private def SelectFile() as callable:
        fileBrowser.SelectFile(fullPath)
        # fileBrowser.LoadFile()
