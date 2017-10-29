import UnityEngine
import UnityEngine.UI
import System.IO
import System.Collections
import System.Text.RegularExpressions

public class InstrumentFolderButton (MonoBehaviour): 

    public path as string

    def Awake():
        button = GetComponent(Button)
        button.onClick.AddListener({Click()})

    def Click():
        transform.GetComponentInParent(InstrumentList).ShowFolderContent(path)